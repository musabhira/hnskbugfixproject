import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum DesignPosterFormat { story9x16, portrait4x5, square1x1 }

enum DesignPosterStyle {
  kraftScrapbook,
  obsidianGold,
  creamMinimal,
  terracottaCard,
}

class MarketingPosterTemplate {
  final String id;
  final String category; // 'Update', 'Phrases', 'Quiz', 'Download', 'Brand'
  final String badge;
  final String title;
  final String subtitle;
  final String? nativeLine;
  final List<Map<String, String>>? rows; // e.g. [{'en': '...', 'native': '...'}]
  final List<String>? options; // for Quiz posters
  final String ctaText;
  final DesignPosterStyle style;

  const MarketingPosterTemplate({
    required this.id,
    required this.category,
    required this.badge,
    required this.title,
    required this.subtitle,
    this.nativeLine,
    this.rows,
    this.options,
    this.ctaText = 'Download PoketMates',
    this.style = DesignPosterStyle.kraftScrapbook,
  });
}

class AdminDesignPostersTab extends StatefulWidget {
  const AdminDesignPostersTab({super.key});

  @override
  State<AdminDesignPostersTab> createState() => _AdminDesignPostersTabState();
}

class _AdminDesignPostersTabState extends State<AdminDesignPostersTab> {
  String _selectedCategory = 'All';
  DesignPosterFormat _selectedFormat = DesignPosterFormat.story9x16;

  static const List<String> _categories = [
    'All',
    'Update',
    'Phrases',
    'Quiz',
    'Download',
    'Brand',
  ];

  static final List<MarketingPosterTemplate> _posters = [
    // ================= 1. UPDATE POSTERS (6) =================
    const MarketingPosterTemplate(
      id: 'upd_1',
      category: 'Update',
      badge: 'NEW UPDATE LIVE',
      title: 'Update Now!',
      subtitle: '1,400+ Daily English Phrases & Voice Lessons Added.',
      nativeLine: 'Play Store & App Store • Update in 10 Seconds',
      ctaText: 'UPDATE POKETMATES',
      style: DesignPosterStyle.obsidianGold,
    ),
    const MarketingPosterTemplate(
      id: 'upd_2',
      category: 'Update',
      badge: 'APP UPDATE',
      title: 'Speak English Faster.',
      subtitle: 'New Scrapbook Daily English Cards are now live in Homes & Vibes!',
      nativeLine: 'Malayalam • Tamil • Hindi • Kannada • Telugu',
      ctaText: 'UPDATE NOW',
      style: DesignPosterStyle.kraftScrapbook,
    ),
    const MarketingPosterTemplate(
      id: 'upd_3',
      category: 'Update',
      badge: 'VERSION 1.0.312',
      title: 'Huge English Update!',
      subtitle: 'Tap any phrase to hear clear English pronunciation & learn faster.',
      nativeLine: 'Available on Android & iOS',
      ctaText: 'GET THE UPDATE',
      style: DesignPosterStyle.creamMinimal,
    ),
    const MarketingPosterTemplate(
      id: 'upd_4',
      category: 'Update',
      badge: 'DON\'T MISS OUT',
      title: 'Have You Updated?',
      subtitle: '165+ fresh Daily English decks with zero-repeat learning await you.',
      nativeLine: 'Open Play Store / App Store',
      ctaText: 'UPDATE TODAY',
      style: DesignPosterStyle.terracottaCard,
    ),
    const MarketingPosterTemplate(
      id: 'upd_5',
      category: 'Update',
      badge: 'FRESH RELEASE',
      title: 'Better English Rooms.',
      subtitle: 'Cleaner Human & AI Robot practice rooms for uninterrupted speaking.',
      nativeLine: 'Update PoketMates Now',
      ctaText: 'UPDATE APP',
      style: DesignPosterStyle.obsidianGold,
    ),
    const MarketingPosterTemplate(
      id: 'upd_6',
      category: 'Update',
      badge: 'FREE UPDATE',
      title: 'Level Up Your English',
      subtitle: 'New Daily English Phrases, Interactive Quizzes & HD Story Cards.',
      nativeLine: 'Play Store & App Store',
      ctaText: 'UPDATE NOW',
      style: DesignPosterStyle.kraftScrapbook,
    ),

    // ================= 2. DAILY PHRASES / VOCAB (10) =================
    const MarketingPosterTemplate(
      id: 'phr_1',
      category: 'Phrases',
      badge: 'DAILY ENGLISH PHRASES',
      title: "Phrases with 'WHO'",
      subtitle: 'English - Malayalam',
      rows: [
        {'en': 'Who is this?', 'native': 'ഇതാരാണ്?'},
        {'en': 'Who are you?', 'native': 'നിങ്ങൾ ആരാണ്?'},
        {'en': 'Who said that?', 'native': 'അതാരാണ് പറഞ്ഞത്?'},
        {'en': 'Who knows?', 'native': 'ആർക്കറിയാം?'},
        {'en': 'Who called?', 'native': 'ആരാണ് വിളിച്ചത്?'},
      ],
      ctaText: 'Learn on PoketMates',
      style: DesignPosterStyle.kraftScrapbook,
    ),
    const MarketingPosterTemplate(
      id: 'phr_2',
      category: 'Phrases',
      badge: 'DAILY ENGLISH PHRASES',
      title: "Phrases with 'HOW'",
      subtitle: 'English - Tamil',
      rows: [
        {'en': 'How are you?', 'native': 'எப்படி இருக்கிறீர்கள்?'},
        {'en': 'How much is this?', 'native': 'இதன் விலை என்ன?'},
        {'en': 'How do you know?', 'native': 'உங்களுக்கு எப்படி தெரியும்?'},
        {'en': 'How was your day?', 'native': 'உங்கள் நாள் எப்படி இருந்தது?'},
        {'en': 'How can I help?', 'native': 'நான் எப்படி உதவ முடியும்?'},
      ],
      ctaText: 'Learn on PoketMates',
      style: DesignPosterStyle.kraftScrapbook,
    ),
    const MarketingPosterTemplate(
      id: 'phr_3',
      category: 'Phrases',
      badge: 'DAILY ENGLISH PHRASES',
      title: "Phrases with 'WHERE'",
      subtitle: 'English - Hindi',
      rows: [
        {'en': 'Where are you?', 'native': 'आप कहाँ हैं?'},
        {'en': 'Where are you going?', 'native': 'आप कहाँ जा रहे हैं?'},
        {'en': 'Where did you go?', 'native': 'आप कहाँ गए थे?'},
        {'en': 'Where is it?', 'native': 'यह कहाँ है?'},
        {'en': 'Where do you live?', 'native': 'आप कहाँ रहते हैं?'},
      ],
      ctaText: 'Learn on PoketMates',
      style: DesignPosterStyle.kraftScrapbook,
    ),
    const MarketingPosterTemplate(
      id: 'phr_4',
      category: 'Phrases',
      badge: 'DAILY ENGLISH PHRASES',
      title: "Phrases with 'WHAT'",
      subtitle: 'English - Kannada',
      rows: [
        {'en': 'What is this?', 'native': 'ಇದೇನು?'},
        {'en': 'What happened?', 'native': 'ಏನಾಯಿತು?'},
        {'en': 'What do you mean?', 'native': 'ನಿಮ್ಮ ಅರ್ಥವೇನು?'},
        {'en': 'What time is it?', 'native': 'ಸಮಯ ಎಷ್ಟು?'},
        {'en': 'What should I do?', 'native': 'ನಾನು ಏನು ಮಾಡಬೇಕು?'},
      ],
      ctaText: 'Learn on PoketMates',
      style: DesignPosterStyle.kraftScrapbook,
    ),
    const MarketingPosterTemplate(
      id: 'phr_5',
      category: 'Phrases',
      badge: 'DAILY ENGLISH PHRASES',
      title: "Phrases with 'CAN'",
      subtitle: 'English - Telugu',
      rows: [
        {'en': 'Can you help me?', 'native': 'నాకు సహాయం చేయగలరా?'},
        {'en': 'Can I come in?', 'native': 'నేను లోపలికి రావచ్చా?'},
        {'en': 'Can you hear me?', 'native': 'నా మాట వినిపిస్తోందా?'},
        {'en': 'Can you repeat that?', 'native': 'దాన్ని మళ్ళీ చెప్పగలరా?'},
        {'en': 'I can do it!', 'native': 'నేను ఇది చేయగలను!'},
      ],
      ctaText: 'Learn on PoketMates',
      style: DesignPosterStyle.kraftScrapbook,
    ),
    const MarketingPosterTemplate(
      id: 'phr_6',
      category: 'Phrases',
      badge: 'POLITE ENGLISH',
      title: 'Sound Polite & Confident',
      subtitle: 'Everyday Respectful Phrases',
      rows: [
        {'en': 'Excuse me, please.', 'native': 'ക്ഷമിക്കണം, ഒന്ന് ശ്രദ്ധിക്കാമോ?'},
        {'en': 'No problem at all.', 'native': 'ഒരു കുഴപ്പവുമില്ല.'},
        {'en': 'Thank you so much!', 'native': 'വളരെയധികം നന്ദി!'},
        {'en': 'Have a nice day!', 'native': 'നല്ലൊരു ദിവസം ആശംസിക്കുന്നു!'},
      ],
      ctaText: 'Speak English Daily',
      style: DesignPosterStyle.creamMinimal,
    ),
    const MarketingPosterTemplate(
      id: 'phr_7',
      category: 'Phrases',
      badge: 'TRAVEL ENGLISH',
      title: 'Travel & Directions',
      subtitle: 'Must-Know Phrases',
      rows: [
        {'en': 'How far is it?', 'native': 'ഇവിടെ നിന്ന് എത്ര ദൂരമുണ്ട്?'},
        {'en': 'Stop right here.', 'native': 'ഇവിടെ നിർത്തൂ.'},
        {'en': 'One ticket, please.', 'native': 'ദയവായി ഒരു ടിക്കറ്റ് തരൂ.'},
        {'en': 'Have a safe trip!', 'native': 'സുരക്ഷിതമായ യാത്ര ആശംസിക്കുന്നു!'},
      ],
      ctaText: 'PoketMates App',
      style: DesignPosterStyle.kraftScrapbook,
    ),
    const MarketingPosterTemplate(
      id: 'phr_8',
      category: 'Phrases',
      badge: 'SHOPPING ENGLISH',
      title: 'Shopping & Prices',
      subtitle: 'Speak Clearly at Shops',
      rows: [
        {'en': 'How much is this?', 'native': 'ഇതിന് എത്ര വിലയാകും?'},
        {'en': 'Any discount available?', 'native': 'വല്ല ഡിസ്കൗണ്ടും ഉണ്ടോ?'},
        {'en': 'I am just looking.', 'native': 'ഞാൻ ജസ്റ്റ് നോക്കുകയാണ്.'},
        {'en': 'Give me the bill, please.', 'native': 'ദയവായി ബിൽ തരൂ.'},
      ],
      ctaText: 'PoketMates App',
      style: DesignPosterStyle.creamMinimal,
    ),
    const MarketingPosterTemplate(
      id: 'phr_9',
      category: 'Phrases',
      badge: 'OFFICE ENGLISH',
      title: 'Workplace Essentials',
      subtitle: 'Professional Daily Phrases',
      rows: [
        {'en': 'Let me check.', 'native': 'ഞാൻ ഒന്ന് പരിശോധിക്കട്ടെ.'},
        {'en': 'I will update you.', 'native': 'ഞാൻ നിങ്ങളെ അറിയിക്കാം.'},
        {'en': 'Sounds good to me.', 'native': 'അത് നല്ല ആശയമാണ്.'},
        {'en': 'Please send the file.', 'native': 'ദയവായി ഫയൽ അയക്കൂ.'},
      ],
      ctaText: 'Practice on PoketMates',
      style: DesignPosterStyle.obsidianGold,
    ),
    const MarketingPosterTemplate(
      id: 'phr_10',
      category: 'Phrases',
      badge: 'PHONE CALLS',
      title: 'Phone Call English',
      subtitle: 'Speak Clearly on Calls',
      rows: [
        {'en': 'Who is speaking?', 'native': 'ആരാണ് സംസാരിക്കുന്നത്?'},
        {'en': 'Hold on a second.', 'native': 'ഒരു നിമിഷം വെയിറ്റ് ചെയ്യൂ.'},
        {'en': 'Call me back later.', 'native': 'പിന്നീട് തിരിച്ചു വിളിക്കൂ.'},
        {'en': 'Your voice is breaking.', 'native': 'നിങ്ങളുടെ ശബ്ദം കട്ടാകുന്നുണ്ട്.'},
      ],
      ctaText: 'Practice on PoketMates',
      style: DesignPosterStyle.kraftScrapbook,
    ),

    // ================= 3. QUIZ & QUESTIONS (8) =================
    const MarketingPosterTemplate(
      id: 'quiz_1',
      category: 'Quiz',
      badge: 'ENGLISH QUIZ',
      title: 'Which one is correct?',
      subtitle: 'Test your daily English grammar!',
      options: [
        'A) She don\'t know',
        'B) She doesn\'t know',
        'C) She not know',
      ],
      ctaText: 'Comment your answer! 👇',
      style: DesignPosterStyle.obsidianGold,
    ),
    const MarketingPosterTemplate(
      id: 'quiz_2',
      category: 'Quiz',
      badge: 'ASKING THE TIME',
      title: 'How do you ask the time politely?',
      subtitle: 'Choose the natural English phrase:',
      options: [
        'A) Tell me time.',
        'B) Excuse me, what time is it?',
        'C) What is clock now?',
      ],
      ctaText: 'Learn Daily on PoketMates',
      style: DesignPosterStyle.kraftScrapbook,
    ),
    const MarketingPosterTemplate(
      id: 'quiz_3',
      category: 'Quiz',
      badge: 'QUICK QUESTION',
      title: 'How do you say "എനിക്ക് മനസ്സിലായില്ല" in English?',
      subtitle: 'Pick the best natural response:',
      options: [
        'A) I didn\'t understand.',
        'B) I am no understand.',
        'C) Understand not.',
      ],
      ctaText: 'Practice on PoketMates',
      style: DesignPosterStyle.creamMinimal,
    ),
    const MarketingPosterTemplate(
      id: 'quiz_4',
      category: 'Quiz',
      badge: 'SPOKEN TEST',
      title: 'Fill in the blank:',
      subtitle: '"I am looking forward ___ meeting you."',
      options: [
        'A) for',
        'B) to',
        'C) at',
      ],
      ctaText: 'Reply A, B, or C 👇',
      style: DesignPosterStyle.obsidianGold,
    ),
    const MarketingPosterTemplate(
      id: 'quiz_5',
      category: 'Quiz',
      badge: 'DAILY CHALLENGE',
      title: 'Fix the sentence:',
      subtitle: '"I am having two brothers." ❌',
      nativeLine: 'Correct: "I have two brothers." ✅',
      ctaText: 'Learn 1,400+ Tips on PoketMates',
      style: DesignPosterStyle.terracottaCard,
    ),
    const MarketingPosterTemplate(
      id: 'quiz_6',
      category: 'Quiz',
      badge: 'COMMON MISTAKE',
      title: 'Stop saying "Myself Rahul" ❌',
      subtitle: 'Say this instead:',
      nativeLine: '"I am Rahul." or "My name is Rahul." ✅',
      ctaText: 'Speak Confident English',
      style: DesignPosterStyle.creamMinimal,
    ),
    const MarketingPosterTemplate(
      id: 'quiz_7',
      category: 'Quiz',
      badge: 'COMMON MISTAKE',
      title: 'Stop saying "Revert back" ❌',
      subtitle: 'Say this instead:',
      nativeLine: '"Please reply" or "Get back to me" ✅',
      ctaText: 'PoketMates English Hub',
      style: DesignPosterStyle.obsidianGold,
    ),
    const MarketingPosterTemplate(
      id: 'quiz_8',
      category: 'Quiz',
      badge: 'QUICK QUESTION',
      title: 'Can you translate this?',
      subtitle: '"അത് എന്റെ തെറ്റല്ല"',
      nativeLine: '"It is not my fault." ✅',
      ctaText: 'Download PoketMates',
      style: DesignPosterStyle.kraftScrapbook,
    ),

    // ================= 4. MULTI-LANGUAGE DOWNLOAD PROMOS (6) =================
    const MarketingPosterTemplate(
      id: 'dl_ml',
      category: 'Download',
      badge: 'MALAYALAM ➔ ENGLISH',
      title: 'മലയാളത്തിലൂടെ ഇംഗ്ലീഷ് പഠിക്കാം!',
      subtitle: 'Speak English confidently with 1,400+ Daily Phrases, AI & Real Mates.',
      nativeLine: 'Free on Play Store & App Store',
      ctaText: 'DOWNLOAD POKETMATES',
      style: DesignPosterStyle.kraftScrapbook,
    ),
    const MarketingPosterTemplate(
      id: 'dl_ta',
      category: 'Download',
      badge: 'TAMIL ➔ ENGLISH',
      title: 'தமிழ் வழியில் ஆங்கிலம் பேசுங்கள்!',
      subtitle: 'Learn Spoken English easily with daily phrases, voice practice & games.',
      nativeLine: 'Free on Play Store & App Store',
      ctaText: 'DOWNLOAD POKETMATES',
      style: DesignPosterStyle.obsidianGold,
    ),
    const MarketingPosterTemplate(
      id: 'dl_te',
      category: 'Download',
      badge: 'TELUGU ➔ ENGLISH',
      title: 'తెలుగు ద్వారా ఇంగ్లీష్ నేర్చుకోండి!',
      subtitle: 'Master everyday English conversations with instant Telugu meanings.',
      nativeLine: 'Free on Play Store & App Store',
      ctaText: 'DOWNLOAD POKETMATES',
      style: DesignPosterStyle.creamMinimal,
    ),
    const MarketingPosterTemplate(
      id: 'dl_kn',
      category: 'Download',
      badge: 'KANNADA ➔ ENGLISH',
      title: 'ಕನ್ನಡದ ಮೂಲಕ ಇಂಗ್ಲಿಷ್ ಕಲಿಯಿರಿ!',
      subtitle: 'Practice speaking English daily with AI Robots & real learners.',
      nativeLine: 'Free on Play Store & App Store',
      ctaText: 'DOWNLOAD POKETMATES',
      style: DesignPosterStyle.terracottaCard,
    ),
    const MarketingPosterTemplate(
      id: 'dl_hi',
      category: 'Download',
      badge: 'HINDI ➔ ENGLISH',
      title: 'हिंदी से आसानी से इंग्लिश बोलें!',
      subtitle: '1,400+ Daily English Phrases with Hindi meanings & audio.',
      nativeLine: 'Free on Play Store & App Store',
      ctaText: 'DOWNLOAD POKETMATES',
      style: DesignPosterStyle.obsidianGold,
    ),
    const MarketingPosterTemplate(
      id: 'dl_all',
      category: 'Download',
      badge: 'INDIA\'S ENGLISH APP',
      title: 'Learn English in Your Language.',
      subtitle: 'Malayalam • Tamil • Telugu • Kannada • Hindi',
      nativeLine: 'Chat. Connect. Practice English.',
      ctaText: 'GET POKETMATES FREE',
      style: DesignPosterStyle.kraftScrapbook,
    ),

    // ================= 5. BRAND & MINIMAL FEATURE POSTERS (6) =================
    const MarketingPosterTemplate(
      id: 'brd_1',
      category: 'Brand',
      badge: 'POKETMATES',
      title: 'Speak English.\nMeet Your PoketMates.',
      subtitle: 'Chat. Connect. Practice English.',
      nativeLine: 'Available on iOS & Android',
      ctaText: 'JOIN TODAY',
      style: DesignPosterStyle.kraftScrapbook,
    ),
    const MarketingPosterTemplate(
      id: 'brd_2',
      category: 'Brand',
      badge: 'NO FEAR. JUST SPEAK.',
      title: 'Shy to Speak English?',
      subtitle: 'Practice 1-on-1 with friendly AI Robots before talking to people.',
      nativeLine: 'Safe • Friendly • Effective',
      ctaText: 'TRY POKETMATES',
      style: DesignPosterStyle.obsidianGold,
    ),
    const MarketingPosterTemplate(
      id: 'brd_3',
      category: 'Brand',
      badge: '90-DAY MISSION',
      title: '10 Minutes a Day.',
      subtitle: 'Build a daily English speaking habit and watch your confidence grow.',
      nativeLine: 'Day 1 to Day 90',
      ctaText: 'START YOUR STREAK',
      style: DesignPosterStyle.creamMinimal,
    ),
    const MarketingPosterTemplate(
      id: 'brd_4',
      category: 'Brand',
      badge: 'ENGLISH HUB',
      title: 'Find Practice Partners.',
      subtitle: 'Join level-matched English speaking rooms with learners like you.',
      nativeLine: 'Beginner to Fluent',
      ctaText: 'JOIN ENGLISH HUB',
      style: DesignPosterStyle.terracottaCard,
    ),
    const MarketingPosterTemplate(
      id: 'brd_5',
      category: 'Brand',
      badge: 'TAP & LISTEN',
      title: 'Hear Real Pronunciation.',
      subtitle: 'Every phrase includes clear voice audio so you never guess how to say it.',
      nativeLine: 'Daily English Phrases',
      ctaText: 'LEARN WITH POKETMATES',
      style: DesignPosterStyle.kraftScrapbook,
    ),
    const MarketingPosterTemplate(
      id: 'brd_6',
      category: 'Brand',
      badge: 'BUILD & LEARN',
      title: 'Learn English.\nGrow Your Citadel.',
      subtitle: 'Complete daily English tasks, earn Pocket Score & defend your Citadel.',
      nativeLine: 'Gamified English Learning',
      ctaText: 'PLAY & LEARN',
      style: DesignPosterStyle.obsidianGold,
    ),
  ];

  double get _aspectRatio {
    switch (_selectedFormat) {
      case DesignPosterFormat.story9x16:
        return 9 / 16;
      case DesignPosterFormat.portrait4x5:
        return 4 / 5;
      case DesignPosterFormat.square1x1:
        return 1 / 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? _posters
        : _posters.where((p) => p.category == _selectedCategory).toList();

    return Column(
      children: [
        // Top Controls: Aspect Ratio + Category Filter
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          decoration: const BoxDecoration(
            color: Color(0xFF0D1117),
            border: Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Design Studio (${filtered.length} Posters)',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  _buildFormatChip('Story 9:16', DesignPosterFormat.story9x16),
                  const SizedBox(width: 6),
                  _buildFormatChip('Portrait 4:5', DesignPosterFormat.portrait4x5),
                  const SizedBox(width: 6),
                  _buildFormatChip('Square 1:1', DesignPosterFormat.square1x1),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, idx) {
                    final cat = _categories[idx];
                    final selected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFFFD700)
                              : const Color(0xFF161B22),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFFFFD700)
                                : Colors.white12,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: GoogleFonts.outfit(
                            color: selected ? Colors.black : Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Grid of Minimal Marketing Posters
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth > 900
                  ? 4
                  : (constraints.maxWidth > 600 ? 3 : 2);
              return GridView.builder(
                padding: const EdgeInsets.all(14),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: _aspectRatio * 0.92,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final poster = filtered[index];
                  return GestureDetector(
                    onTap: () => _openPosterPreview(poster),
                    child: Column(
                      children: [
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: _aspectRatio,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _MinimalMarketingPosterCard(
                                poster: poster,
                                isCompact: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          poster.title.replaceAll('\n', ' '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFormatChip(String label, DesignPosterFormat format) {
    final active = _selectedFormat == format;
    return GestureDetector(
      onTap: () => setState(() => _selectedFormat = format),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFD95D39) : const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? const Color(0xFFD95D39) : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _openPosterPreview(MarketingPosterTemplate poster) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _PosterExportPreviewDialog(
        poster: poster,
        initialFormat: _selectedFormat,
      ),
    );
  }
}

class _PosterExportPreviewDialog extends StatefulWidget {
  final MarketingPosterTemplate poster;
  final DesignPosterFormat initialFormat;

  const _PosterExportPreviewDialog({
    required this.poster,
    required this.initialFormat,
  });

  @override
  State<_PosterExportPreviewDialog> createState() =>
      _PosterExportPreviewDialogState();
}

class _PosterExportPreviewDialogState
    extends State<_PosterExportPreviewDialog> {
  final GlobalKey _posterKey = GlobalKey();
  late DesignPosterFormat _format;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _format = widget.initialFormat;
  }

  double get _ratio {
    switch (_format) {
      case DesignPosterFormat.story9x16:
        return 9 / 16;
      case DesignPosterFormat.portrait4x5:
        return 4 / 5;
      case DesignPosterFormat.square1x1:
        return 1 / 1;
    }
  }

  Future<File?> _renderPosterFile({double pixelRatio = 6.0}) async {
    final boundary =
        _posterKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    final bytes = byteData.buffer.asUint8List();
    final tempDir = await getTemporaryDirectory();
    final file = File(
        '${tempDir.path}/PoketMates_Poster_${widget.poster.id}_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> _saveUltraHd() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final file = await _renderPosterFile(pixelRatio: 6.0);
      if (file == null) throw Exception('Failed to render poster');

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await Gal.putImage(file.path, album: 'PoketMates');
      } else if (Platform.isWindows) {
        final dl = await getDownloadsDirectory();
        if (dl != null) {
          final outPath =
              '${dl.path}${Platform.pathSeparator}${file.uri.pathSegments.last}';
          await file.copy(outPath);
          Process.run('explorer.exe', ['/select,', outPath]);
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved Ultra HD Poster!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _sharePoster() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final file = await _renderPosterFile(pixelRatio: 4.5);
      if (file == null) return;
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${widget.poster.title} — Download PoketMates!',
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0D1117),
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 740),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Poster Preview (Ultra HD)',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _formatBtn('Story 9:16', DesignPosterFormat.story9x16),
                  const SizedBox(width: 8),
                  _formatBtn('Portrait 4:5', DesignPosterFormat.portrait4x5),
                  const SizedBox(width: 8),
                  _formatBtn('Square 1:1', DesignPosterFormat.square1x1),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _ratio,
                    child: RepaintBoundary(
                      key: _posterKey,
                      child: _MinimalMarketingPosterCard(
                        poster: widget.poster,
                        isCompact: false,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isExporting ? null : _saveUltraHd,
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: Text(
                        _isExporting ? 'Saving...' : 'Save Ultra HD',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD95D39),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isExporting ? null : _sharePoster,
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: Text(
                        'Share',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formatBtn(String label, DesignPosterFormat f) {
    final active = _format == f;
    return GestureDetector(
      onTap: () => setState(() => _format = f),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFFD700) : const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: active ? Colors.black : Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MinimalMarketingPosterCard extends StatelessWidget {
  final MarketingPosterTemplate poster;
  final bool isCompact;

  const _MinimalMarketingPosterCard({
    required this.poster,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isKraft = poster.style == DesignPosterStyle.kraftScrapbook;
    final bool isCream = poster.style == DesignPosterStyle.creamMinimal;
    final bool isTerra = poster.style == DesignPosterStyle.terracottaCard;

    final Color bgColor = isKraft
        ? const Color(0xFFDECDB4)
        : (isCream
            ? const Color(0xFFFAF7F0)
            : (isTerra ? const Color(0xFF231815) : const Color(0xFF0D1117)));

    final Color cardBg = (isKraft || isCream)
        ? const Color(0xFFFAF7F0)
        : const Color(0xFF161B22);

    final Color textPrimary =
        (isKraft || isCream) ? const Color(0xFF1E140F) : Colors.white;

    final Color textSecondary =
        (isKraft || isCream) ? const Color(0xFF6B5744) : Colors.white70;

    final Color accent = isTerra
        ? const Color(0xFFD95D39)
        : ((isKraft || isCream)
            ? const Color(0xFF8B2500)
            : const Color(0xFFFFD700));

    final double s = isCompact ? 0.62 : 1.0;

    return Container(
      color: bgColor,
      padding: EdgeInsets.all(16 * s),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(16 * s),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14 * s),
            border: Border.all(
              color: (isKraft || isCream)
                  ? const Color(0xFFE2D6C5)
                  : Colors.white12,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 12 * s,
                offset: Offset(0, 5 * s),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Badge
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10 * s, vertical: 4 * s),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20 * s),
                    border: Border.all(color: accent.withValues(alpha: 0.45)),
                  ),
                  child: Text(
                    poster.badge,
                    style: GoogleFonts.outfit(
                      color: accent,
                      fontSize: 10 * s,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.9,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10 * s),

              // Main Title
              Text(
                poster.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: textPrimary,
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              SizedBox(height: 6 * s),

              // Subtitle
              Text(
                poster.subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: textSecondary,
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Phrase Rows (if Phrases Poster)
              if (poster.rows != null && poster.rows!.isNotEmpty) ...[
                SizedBox(height: 10 * s),
                ...poster.rows!.take(isCompact ? 4 : 5).map((r) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.5 * s),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '• ${r['en']}',
                            style: GoogleFonts.outfit(
                              color: textPrimary,
                              fontSize: 11.5 * s,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: 6 * s),
                        Expanded(
                          child: Text(
                            r['native'] ?? '',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: accent,
                              fontSize: 11.5 * s,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              // Quiz Options (if Quiz Poster)
              if (poster.options != null && poster.options!.isNotEmpty) ...[
                SizedBox(height: 10 * s),
                ...poster.options!.map((opt) => Container(
                      margin: EdgeInsets.only(bottom: 5 * s),
                      padding: EdgeInsets.symmetric(
                          horizontal: 10 * s, vertical: 6 * s),
                      decoration: BoxDecoration(
                        color: textPrimary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8 * s),
                        border: Border.all(
                            color: textPrimary.withValues(alpha: 0.12)),
                      ),
                      child: Text(
                        opt,
                        style: GoogleFonts.outfit(
                          color: textPrimary,
                          fontSize: 11.5 * s,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )),
              ],

              // Native / Highlight Line
              if (poster.nativeLine != null &&
                  poster.nativeLine!.isNotEmpty) ...[
                SizedBox(height: 8 * s),
                Text(
                  poster.nativeLine!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: accent,
                    fontSize: 11.5 * s,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],

              SizedBox(height: 12 * s),

              // Minimal Footer CTA
              Container(
                padding: EdgeInsets.symmetric(vertical: 7 * s),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(8 * s),
                ),
                child: Text(
                  poster.ctaText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: (isKraft || isCream || isTerra)
                        ? Colors.white
                        : Colors.black,
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(height: 6 * s),
              Text(
                'PoketMates • Speak English Every Day',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: textSecondary.withValues(alpha: 0.75),
                  fontSize: 9 * s,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
