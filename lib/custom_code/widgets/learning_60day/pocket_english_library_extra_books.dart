import 'package:flutter/material.dart';

class ExtraLibraryPageData {
  final String heading;
  final String body;
  final String keyPhrase;
  final String mlHint;

  const ExtraLibraryPageData({
    required this.heading,
    required this.body,
    required this.keyPhrase,
    required this.mlHint,
  });
}

class ExtraLibraryBookData {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final Color accentColor;
  final List<ExtraLibraryPageData> pages;

  const ExtraLibraryBookData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.accentColor,
    required this.pages,
  });
}

const List<ExtraLibraryBookData> kExtraEnglishLibraryBooks = [
  // ── COMMUNICATION & RANDOM CONVERSATIONS ──
  ExtraLibraryBookData(
    id: 'comm_cafe_smalltalk',
    title: 'Everyday Cafe & Street Small Talk',
    subtitle: 'Natural random conversations with strangers and friends',
    category: 'Communication',
    accentColor: Color(0xFF0EA5E9),
    pages: [
      ExtraLibraryPageData(
        heading: 'Breaking the Ice Naturally',
        body:
            'You do not need big words to start a friendly chat. A simple observation works best: "Excuse me, is this seat taken?" or "It is really busy today, isn\'t it?"\n\nKeep your tone light and relaxed.',
        keyPhrase: 'Excuse me, is this seat taken?',
        mlHint: 'ക്ഷമിക്കണം, ഈ സീറ്റിൽ ആരെങ്കിലും ഉണ്ടോ?',
      ),
      ExtraLibraryPageData(
        heading: 'Keeping the Chat Flowing',
        body:
            'Follow up with an open question: "How has your week been so far?" or "Do you come here often?" People love talking when someone listens with interest.',
        keyPhrase: 'How has your week been so far?',
        mlHint: 'ഈ ആഴ്ച ഇതുവരെ എങ്ങനെയുണ്ട്?',
      ),
    ],
  ),
  ExtraLibraryBookData(
    id: 'comm_phone_calls',
    title: 'Smart Phone & Voice Call English',
    subtitle: 'Sound clear and polite on calls even with bad signal',
    category: 'Communication',
    accentColor: Color(0xFF0284C7),
    pages: [
      ExtraLibraryPageData(
        heading: 'Answering & Clarifying',
        body:
            'Start calls warmly: "Hello, this is me speaking. How can I help?" If the audio breaks up, say calmly: "Sorry, your voice is breaking up. Could you repeat that please?"',
        keyPhrase: 'Could you repeat that, please?',
        mlHint: 'ദയവായി അത് ഒന്നുകൂടി പറയാമോ?',
      ),
      ExtraLibraryPageData(
        heading: 'Ending a Call Smoothly',
        body:
            'Never hang up abruptly. Wrap up clearly: "Thanks for calling. I will message you the details shortly. Have a great day!"',
        keyPhrase: 'I will message you the details shortly.',
        mlHint: 'വിവരങ്ങൾ ഞാൻ ഉടൻ മെസ്സേജ് അയക്കാം.',
      ),
    ],
  ),
  ExtraLibraryBookData(
    id: 'comm_polite_disagree',
    title: 'How to Disagree Politely',
    subtitle: 'Express a different opinion without sounding rude',
    category: 'Communication',
    accentColor: Color(0xFF6366F1),
    pages: [
      ExtraLibraryPageData(
        heading: 'Acknowledge First',
        body:
            'Instead of saying "You are wrong," start with respect: "I see your point, however I look at it a bit differently." This keeps conversations friendly and mature.',
        keyPhrase: 'I see your point, however...',
        mlHint: 'നിങ്ങൾ പറയുന്നത് എനിക്ക് മനസ്സിലായി, പക്ഷെ...',
      ),
    ],
  ),
  ExtraLibraryBookData(
    id: 'comm_asking_help',
    title: 'Asking for Help & Favors Gracefully',
    subtitle: 'Polite requests at work, shops, and daily errands',
    category: 'Communication',
    accentColor: Color(0xFF0891B2),
    pages: [
      ExtraLibraryPageData(
        heading: 'Soften Your Requests',
        body:
            'Use "Could you" or "Would you mind" instead of commands: "Could you give me a quick hand with this?" or "Would you mind checking this for a moment?"',
        keyPhrase: 'Could you give me a quick hand?',
        mlHint: 'ഇതൊന്ന് സഹായിക്കാമോ?',
      ),
    ],
  ),
  ExtraLibraryBookData(
    id: 'comm_compliments',
    title: 'Giving Genuine Compliments',
    subtitle: 'Warm phrases that brighten someone\'s day in English',
    category: 'Communication',
    accentColor: Color(0xFFEC4899),
    pages: [
      ExtraLibraryPageData(
        heading: 'Specific Praise Works Best',
        body:
            'Specific compliments feel real: "I really liked how clearly you explained that!" or "That color suits you really well."',
        keyPhrase: 'I really liked how you explained that.',
        mlHint: 'നിങ്ങൾ അത് വിശദീകരിച്ച രീതി എനിക്ക് വളരെ ഇഷ്ടപ്പെട്ടു.',
      ),
    ],
  ),
  ExtraLibraryBookData(
    id: 'comm_awkward_silence',
    title: 'Handling Awkward Silences',
    subtitle: 'Simple filler bridges to keep conversations alive',
    category: 'Communication',
    accentColor: Color(0xFF8B5CF6),
    pages: [
      ExtraLibraryPageData(
        heading: 'Bridge Phrases',
        body:
            'When a chat pauses, use easy bridges: "By the way, did you hear about..." or "That reminds me, what are your plans for the weekend?"',
        keyPhrase: 'What are your plans for the weekend?',
        mlHint: 'വാരാന്ത്യത്തിൽ എന്തൊക്കെയാണ് പ്ലാൻ?',
      ),
    ],
  ),
  ExtraLibraryBookData(
    id: 'comm_apology_repair',
    title: 'Sincere Apologies & Fixing Mistakes',
    subtitle: 'Own up calmly and rebuild trust in English',
    category: 'Communication',
    accentColor: Color(0xFFF43F5E),
    pages: [
      ExtraLibraryPageData(
        heading: 'Clear & Honest Apologies',
        body:
            'Keep it direct: "I am sorry for the delay. Let me fix that right away." People respect action right after an apology.',
        keyPhrase: 'Let me fix that right away.',
        mlHint: 'ഞാൻ അത് ഉടൻ തന്നെ ശരിയാക്കാം.',
      ),
    ],
  ),

  // ── SPEAKING KEYS & PUBLIC SPEAKING ──
  ExtraLibraryBookData(
    id: 'speech_pacing_pause',
    title: 'Speech Keys: The Power of the Pause',
    subtitle: 'Why slowing down makes your English sound fluent',
    category: 'Speaking Keys',
    accentColor: Color(0xFFF59E0B),
    pages: [
      ExtraLibraryPageData(
        heading: 'Pause Instead of "Umm"',
        body:
            'Fast speech causes mistakes. When you finish a key point, pause for one full second instead of saying "umm" or "uh." Silence makes you sound thoughtful and confident.',
        keyPhrase: 'Pause for one second after each point.',
        mlHint: 'ഓരോ പോയിന്റിനും ശേഷം ഒരു സെക്കൻഡ് നിർത്തുക.',
      ),
      ExtraLibraryPageData(
        heading: 'Stress the Important Word',
        body:
            'Give slightly more energy to the main word in your sentence: "This is OUR best chance today." Word stress brings life to your voice.',
        keyPhrase: 'Stress the main word in your line.',
        mlHint: 'വാക്യത്തിലെ പ്രധാന വാക്കിന് ഊന്നൽ നൽകുക.',
      ),
    ],
  ),
  ExtraLibraryBookData(
    id: 'speech_story_hook',
    title: 'Speech Keys: Opening With a Hook',
    subtitle: 'Grab attention in the first 10 seconds of any speech',
    category: 'Speaking Keys',
    accentColor: Color(0xFFD97706),
    pages: [
      ExtraLibraryPageData(
        heading: 'Start With a Question or Story',
        body:
            'Skip boring openings like "Today I will talk about..." Instead try: "Have you ever wondered why one simple sentence can change your day?"',
        keyPhrase: 'Have you ever wondered why...',
        mlHint: 'നിങ്ങൾ എപ്പോഴെങ്കിലും ചിന്തിച്ചിട്ടുണ്ടോ എന്തുകൊണ്ടാണ്...',
      ),
    ],
  ),
  ExtraLibraryBookData(
    id: 'speech_group_discussion',
    title: 'Group Discussion & Debate Keys',
    subtitle: 'Enter a busy discussion smoothly and hold the floor',
    category: 'Speaking Keys',
    accentColor: Color(0xFFEAB308),
    pages: [
      ExtraLibraryPageData(
        heading: 'Jumping In Politely',
        body:
            'To join an active group talk, say: "May I add a quick point here?" or "Building on what she just said, I think..."',
        keyPhrase: 'May I add a quick point here?',
        mlHint: 'ഇവിടെ ഒരു ചെറിയ പോയിന്റ് കൂടി ചേർക്കട്ടെ?',
      ),
    ],
  ),
  ExtraLibraryBookData(
    id: 'speech_voice_tone',
    title: 'Voice Clarity & Mouth Warmups',
    subtitle: 'Speak clearly so nobody asks you to repeat',
    category: 'Speaking Keys',
    accentColor: Color(0xFFEA580C),
    pages: [
      ExtraLibraryPageData(
        heading: 'Open Your Vowels',
        body:
            'Mumbling happens when we barely move our lips. Read five lines aloud every morning, pronouncing the ending sounds like -t, -d, and -s clearly.',
        keyPhrase: 'Pronounce the ending sounds clearly.',
        mlHint: 'വാക്കുകളുടെ അവസാന ശബ്ദങ്ങൾ വ്യക്തമായി ഉച്ചരിക്കുക.',
      ),
    ],
  ),
  ExtraLibraryBookData(
    id: 'speech_persuasion',
    title: 'Persuasive Speaking in 3 Steps',
    subtitle: 'Convince listeners with Problem, Solution, Benefit',
    category: 'Speaking Keys',
    accentColor: Color(0xFFDC2626),
    pages: [
      ExtraLibraryPageData(
        heading: 'Problem -> Solution -> Benefit',
        body:
            'Structure any pitch in 3 lines: "Right now we lose time on X. If we try Y, we will save two hours every day."',
        keyPhrase: 'If we try this, we will save time.',
        mlHint: 'നമ്മൾ ഇത് പരീക്ഷിച്ചാൽ സമയം ലാഭിക്കാം.',
      ),
    ],
  ),

  // ── LIFESTYLE & CONFIDENCE ──
  ExtraLibraryBookData(
    id: 'life_morning_english',
    title: 'English Morning Lifestyle Habits',
    subtitle: 'Think in English from your first cup of tea',
    category: 'Lifestyle',
    accentColor: Color(0xFF10B981),
    pages: [
      ExtraLibraryPageData(
        heading: 'Narrate Your Morning',
        body:
            'Describe your actions silently in English: "I am making coffee. Today I have three main tasks. First, I will finish my reading." Thinking in English builds natural speed.',
        keyPhrase: 'Today I have three main tasks.',
        mlHint: 'ഇന്ന് എനിക്ക് മൂന്ന് പ്രധാന കാര്യങ്ങൾ ചെയ്യാനുണ്ട്.',
      ),
    ],
  ),
  ExtraLibraryBookData(
    id: 'life_travel_airport',
    title: 'Travel, Airport & Hotel English',
    subtitle: 'Move through check-in, taxis, and hotels effortlessly',
    category: 'Lifestyle',
    accentColor: Color(0xFF059669),
    pages: [
      ExtraLibraryPageData(
        heading: 'At Check-in & Boarding',
        body:
            'Useful lines: "Here is my passport and boarding pass. Could I get a window seat if available?" Keep documents ready and smile.',
        keyPhrase: 'Could I get a window seat, please?',
        mlHint: 'ദയവായി ഒരു വിൻഡോ സീറ്റ് കിട്ടുമോ?',
      ),
    ],
  ),
  ExtraLibraryBookData(
    id: 'life_dining_hosting',
    title: 'Dining Out & Hosting Guests',
    subtitle: 'Order food, ask for bills, and welcome guests warmly',
    category: 'Lifestyle',
    accentColor: Color(0xFF14B8A6),
    pages: [
      ExtraLibraryPageData(
        heading: 'Ordering & Hospitality',
        body:
            'At a restaurant: "Could we see the menu, please? What do you recommend?" When hosting at home: "Make yourself comfortable. Would you like water or tea?"',
        keyPhrase: 'Make yourself comfortable.',
        mlHint: 'സൗകര്യമായി ഇരിക്കൂ.',
      ),
    ],
  ),
  ExtraLibraryBookData(
    id: 'life_fitness_wellness',
    title: 'Health, Gym & Wellness Talk',
    subtitle: 'Talk about workouts, sleep, and healthy routines',
    category: 'Lifestyle',
    accentColor: Color(0xFF22C55E),
    pages: [
      ExtraLibraryPageData(
        heading: 'Daily Fitness Phrases',
        body:
            '"I am trying to stay consistent with my evening walks." "Getting eight hours of sleep really boosts my focus."',
        keyPhrase: 'I am trying to stay consistent.',
        mlHint: 'ഞാൻ സ്ഥിരത നിലനിർത്താൻ ശ്രമിക്കുകയാണ്.',
      ),
    ],
  ),
  ExtraLibraryBookData(
    id: 'life_shopping_smart',
    title: 'Smart Shopping & Polite Bargaining',
    subtitle: 'Ask sizes, compare prices, and return items politely',
    category: 'Lifestyle',
    accentColor: Color(0xFF0D9488),
    pages: [
      ExtraLibraryPageData(
        heading: 'In Any Store',
        body:
            '"Do you have this in a medium size?" "Is there any discount on this item?" "Could I exchange this if it does not fit?"',
        keyPhrase: 'Do you have this in another size?',
        mlHint: 'ഇതിന്റെ വേറെ സൈസ് ലഭ്യമാണോ?',
      ),
    ],
  ),
  ExtraLibraryBookData(
    id: 'life_digital_etiquette',
    title: 'Modern Digital & Texting Etiquette',
    subtitle: 'Sound crisp and respectful on WhatsApp and emails',
    category: 'Lifestyle',
    accentColor: Color(0xFF3B82F6),
    pages: [
      ExtraLibraryPageData(
        heading: 'Clear Messages Save Time',
        body:
            'Avoid sending just "Hi" and waiting. Send context together: "Hi! Quick question about tomorrow\'s plan — are we meeting at 5 PM?"',
        keyPhrase: 'Quick question about tomorrow\'s plan.',
        mlHint: 'നാളത്തെ പ്ലാനിനെക്കുറിച്ച് ഒരു ചെറിയ ചോദ്യം.',
      ),
    ],
  ),

  // ── HISTORY & WORLD KNOWLEDGE IN ENGLISH ──
  ExtraLibraryBookData(
    id: 'hist_printing_press',
    title: 'History: The Printing Press Revolution',
    subtitle: 'How one invention made books available to everyone',
    category: 'History',
    accentColor: Color(0xFFB45309),
    pages: [
      ExtraLibraryPageData(
        heading: 'Before 1440',
        body:
            'Before Johannes Gutenberg built the movable-type printing press in 1440, every book had to be copied by hand. Only kings and scholars owned books.\n\nOnce printing began, ideas traveled across Europe in months instead of centuries, sparking education for ordinary people.',
        keyPhrase: 'Ideas traveled faster than ever before.',
        mlHint: 'ആശയങ്ങൾ മുൻപത്തേക്കാൾ വേഗത്തിൽ സഞ്ചരിച്ചു.',
      ),
    ],
  ),
  ExtraLibraryBookData(
    id: 'hist_global_english',
    title: 'History: How English Became Global',
    subtitle: 'A journey from a small island to every continent',
    category: 'History',
    accentColor: Color(0xFF92400E),
    pages: [
      ExtraLibraryPageData(
        heading: 'A Language That Borrowed Everything',
        body:
            'English grew by borrowing words from Latin, French, Greek, Arabic, and Indian languages—like "jungle", "shampoo", "pajamas", and "bungalow".\n\nToday, over 1.5 billion people use English as a bridge to connect across cultures.',
        keyPhrase: 'Language is a bridge between cultures.',
        mlHint: 'ഭാഷ സംസ്കാരങ്ങൾ തമ്മിലുള്ള ഒരു പാലമാണ്.',
      ),
    ],
  ),
  ExtraLibraryBookData(
    id: 'hist_silk_road',
    title: 'History: Traders of the Silk Road',
    subtitle: 'How ancient merchants communicated across borders',
    category: 'History',
    accentColor: Color(0xFFA16207),
    pages: [
      ExtraLibraryPageData(
        heading: 'Trade Created Shared Words',
        body:
            'For over a thousand years, caravans carried silk, spices, paper, and stories between Asia and Europe. Merchants learned key phrases from every town they visited—proving that communication opens every door.',
        keyPhrase: 'Communication opens every door.',
        mlHint: 'ആശയവിനിമയം എല്ലാ വാതിലുകളും തുറക്കുന്നു.',
      ),
    ],
  ),
  ExtraLibraryBookData(
    id: 'hist_kitty_hawk',
    title: 'History: Twelve Seconds at Kitty Hawk',
    subtitle: 'The Wright brothers and the power of persistence',
    category: 'History',
    accentColor: Color(0xFF78350F),
    pages: [
      ExtraLibraryPageData(
        heading: 'December 17, 1903',
        body:
            'The first powered flight lasted only twelve seconds and covered 120 feet. Yet those twelve seconds proved humans could fly. Every big skill—including fluent English—starts with small daily flights.',
        keyPhrase: 'Every big skill starts small.',
        mlHint: 'എല്ലാ വലിയ കഴിവുകളും ചെറുതിൽ നിന്നാണ് തുടങ്ങുന്നത്.',
      ),
    ],
  ),
  ExtraLibraryBookData(
    id: 'hist_alexandria',
    title: 'History: The Great Library of Alexandria',
    subtitle: 'The ancient world\'s dream of collecting all knowledge',
    category: 'History',
    accentColor: Color(0xFFB91C1C),
    pages: [
      ExtraLibraryPageData(
        heading: 'Hundreds of Thousands of Scrolls',
        body:
            'Scholars traveled from across the Mediterranean to read, translate, and debate in Alexandria. Reading has always been the fastest way to borrow wisdom from the greatest minds in history.',
        keyPhrase: 'Reading lets us borrow wisdom.',
        mlHint: 'വായന മറ്റുള്ളവരുടെ അറിവ് സ്വന്തമാക്കാൻ സഹായിക്കുന്നു.',
      ),
    ],
  ),
  ExtraLibraryBookData(
    id: 'career_workplace_updates',
    title: 'Giving Crisp Work Updates',
    subtitle: 'Share progress in meetings without rambling',
    category: 'Career',
    accentColor: Color(0xFF4F46E5),
    pages: [
      ExtraLibraryPageData(
        heading: 'Done, Doing, Next',
        body:
            'Keep status updates to 3 lines: "Yesterday I completed X. Today I am working on Y. Next I will check Z." Managers love clarity.',
        keyPhrase: 'Today I am working on...',
        mlHint: 'ഇന്ന് ഞാൻ ... എന്ന കാര്യത്തിലാണ് പ്രവർത്തിക്കുന്നത്.',
      ),
    ],
  ),
  ExtraLibraryBookData(
    id: 'career_networking',
    title: 'Networking & LinkedIn Conversations',
    subtitle: 'Connect with professionals naturally and respectfully',
    category: 'Career',
    accentColor: Color(0xFF4338CA),
    pages: [
      ExtraLibraryPageData(
        heading: 'Warm First Messages',
        body:
            '"Hello! I really admire your work in design. I am currently building my skills and would love to stay connected."',
        keyPhrase: 'I would love to stay connected.',
        mlHint: 'നിങ്ങളുമായി ബന്ധപ്പെട്ടിരിക്കാൻ എനിക്ക് സന്തോഷമുണ്ട്.',
      ),
    ],
  ),
];
