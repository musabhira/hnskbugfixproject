import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/subscription_page.dart';
import 'pocket_english_library_extra_books.dart';

class _BookPageContent {
  final String heading;
  final String body;
  final String keyPhrase;
  final String mlHint;
  final String taHint;
  final String hiHint;
  final String teHint;
  final String knHint;

  const _BookPageContent({
    required this.heading,
    required this.body,
    required this.keyPhrase,
    required this.mlHint,
    this.taHint = '',
    this.hiHint = '',
    this.teHint = '',
    this.knHint = '',
  });

  String get localizedHint => PocketLanguageService.localize(
        en: keyPhrase,
        ml: mlHint,
        ta: taHint.isNotEmpty ? taHint : mlHint,
        hi: hiHint.isNotEmpty ? hiHint : mlHint,
        te: teHint.isNotEmpty ? teHint : mlHint,
        kn: knHint.isNotEmpty ? knHint : mlHint,
      );
}

class _LibraryBook {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final Color accentColor;
  final List<_BookPageContent> pages;

  const _LibraryBook({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.accentColor,
    required this.pages,
  });
}

String _resolveLoggedInUserName() {
  try {
    final user = SupaFlow.client.auth.currentUser;
    final meta = user?.userMetadata;
    final raw = (meta?['full_name'] ??
            meta?['name'] ??
            meta?['display_name'] ??
            user?.email?.split('@').first ??
            '')
        .toString()
        .trim();
    if (raw.isEmpty) return 'Friend';
    return raw[0].toUpperCase() + raw.substring(1);
  } catch (_) {
    return 'Friend';
  }
}

List<_LibraryBook> _buildLibraryBooks(String userName) => [
      // ── INTERVIEW & SELF-INTRODUCTION FIRST ──────────────────────────────
      _LibraryBook(
        id: 'self_intro',
        title: 'Self-Introduction That Wins',
        subtitle: 'Introduce yourself calmly and clearly anywhere',
        category: 'Interview',
        accentColor: const Color(0xFF2563EB),
        pages: [
          _BookPageContent(
            heading: 'Start With Your Name',
            body:
                'When someone asks you to introduce yourself, keep your voice steady and warm. Start simply:\n\n"Hello, my name is $userName. Thank you for this opportunity to speak with you today."\n\nA clear opening shows confidence immediately, without needing complicated words.',
            keyPhrase: 'Hello, my name is $userName.',
            mlHint: 'ഹലോ, എന്റെ പേര് $userName എന്നാണ്.',
            taHint: 'வணக்கம், என் பெயர் $userName.',
            hiHint: 'नमस्ते, मेरा नाम $userName है।',
          ),
          const _BookPageContent(
            heading: 'Your Background in Two Lines',
            body:
                'Next, share what you do or studied in two short lines: "I have a strong interest in learning new skills and working well with people. Currently, I am focused on growing my communication and career."\n\nShort sentences are easier for listeners to remember.',
            keyPhrase: 'I enjoy learning and growing.',
            mlHint: 'പുതിയ കാര്യങ്ങൾ പഠിക്കാനും വളരാനും എനിക്കിഷ്ടമാണ്.',
            taHint: 'புதிய விஷயங்களைக் கற்று வளர எனக்குப் பிடிக்கும்.',
            hiHint: 'मुझे नई चीजें सीखना और आगे बढ़ना पसंद है।',
          ),
          const _BookPageContent(
            heading: 'Closing With Confidence',
            body:
                'End your introduction smoothly instead of stopping awkwardly: "That is a little about me. I would be happy to answer any questions you have."\n\nSmile, pause, and listen calmly.',
            keyPhrase: 'I would be happy to answer any questions.',
            mlHint: 'നിങ്ങളുടെ ചോദ്യങ്ങൾക്ക് ഉത്തരം നൽകാൻ എനിക്ക് സന്തോഷമുണ്ട്.',
            taHint: 'உங்கள் கேள்விகளுக்குப் பதிலளிக்க மகிழ்ச்சியடைகிறேன்.',
            hiHint: 'मुझे आपके सवालों का जवाब देने में खुशी होगी।',
          ),
        ],
      ),
      _LibraryBook(
        id: 'first_interview',
        title: 'The First Interview',
        subtitle: 'Calm answers when it matters most',
        category: 'Interview',
        accentColor: const Color(0xFF1D4ED8),
        pages: [
          _BookPageContent(
            heading: 'The First Thirty Seconds',
            body:
                '$userName sits outside the interview room. Palms are slightly cold, but breathing is steady. When called inside, $userName knocks lightly and says, "Good morning. Thank you for having me."\n\nA calm greeting sets a respectful tone before a single question is asked.',
            keyPhrase: 'Good morning. Thank you for having me.',
            mlHint: 'സുപ്രഭാതം. എന്നെ ക്ഷണിച്ചതിന് നന്ദി.',
            taHint: 'காலை வணக்கம். அழைத்ததற்கு நன்றி.',
            hiHint: 'सुप्रभात। मुझे आमंत्रित करने के लिए धन्यवाद।',
          ),
          const _BookPageContent(
            heading: 'When You Need Time to Think',
            body:
                'If an interviewer asks a tough question, never panic or rush. Say calmly: "That is a great question. Let me think for a second."\n\nTaking two seconds shows maturity and clarity.',
            keyPhrase: 'Let me think for a second.',
            mlHint: 'ഒരു നിമിഷം ആലോചിക്കട്ടെ.',
            taHint: 'ஒரு நொடி யோசிக்கிறேன்.',
            hiHint: 'मुझे एक सेकंड सोचने दें।',
          ),
        ],
      ),
      _LibraryBook(
        id: 'tell_me_about_yourself',
        title: 'Tell Me About Yourself',
        subtitle: 'The 3-step formula for the most common question',
        category: 'Interview',
        accentColor: const Color(0xFF0284C7),
        pages: [
          _BookPageContent(
            heading: 'Present, Past, Future',
            body:
                'Great answers follow three steps:\n1. Present: "Hi, I am $userName. Right now I am building my skills in..."\n2. Past: "Earlier, I worked on..."\n3. Future: "Now I am looking for a role where I can contribute and grow."',
            keyPhrase: 'I am looking for a role where I can grow.',
            mlHint: 'എനിക്ക് വളരാനും സംഭാവന ചെയ്യാനും കഴിയുന്ന ഒരു റോളാണ് ഞാൻ തേടുന്നത്.',
            taHint: 'நான் வளரக்கூடிய ஒரு பணியைத் தேடுகிறேன்.',
            hiHint: 'मैं एक ऐसी भूमिका की तलाश में हूँ जहाँ मैं आगे बढ़ सकूँ।',
          ),
          const _BookPageContent(
            heading: 'Keep It Under 60 Seconds',
            body:
                'Do not recite your entire life story. Focus on strengths, reliability, and willingness to learn. Clean and brief always beats long and rushed.',
            keyPhrase: 'I am eager to learn and contribute.',
            mlHint: 'പഠിക്കാനും മികച്ച സംഭാവന നൽകാനും ഞാൻ തയ്യാറാണ്.',
            taHint: 'கற்றுக்கொண்டு பங்களிக்க ஆர்வமாக உள்ளேன்.',
            hiHint: 'मैं सीखने और योगदान देने के लिए उत्सुक हूँ।',
          ),
        ],
      ),
      const _LibraryBook(
        id: 'salary_hr',
        title: 'HR & Salary Questions',
        subtitle: 'Polite ways to talk about pay and expectations',
        category: 'Interview',
        accentColor: Color(0xFF0F766E),
        pages: [
          _BookPageContent(
            heading: 'Answering Salary Expectations',
            body:
                'When asked about expected salary, stay polite and open: "I am open to a fair package based on the role and company standards."\n\nIt keeps the door open without sounding rigid.',
            keyPhrase: 'I am open to a fair package.',
            mlHint: 'ന്യായമായ ഒരു ശമ്പള പാക്കേജിന് ഞാൻ തയ്യാറാണ്.',
            taHint: 'நியாயமான சம்பளத்திற்கு நான் தயாராக இருக்கிறேன்.',
            hiHint: 'मैं एक उचित पैकेज के लिए तैयार हूँ।',
          ),
          _BookPageContent(
            heading: 'Asking Good Questions Back',
            body:
                'At the end of an interview, ask: "What does success look like in the first three months?"\n\nThis shows genuine interest in doing the job well.',
            keyPhrase: 'What does success look like in this role?',
            mlHint: 'ഈ റോളിൽ വിജയം എന്നത് എങ്ങനെയാണ് വിലയിരുത്തപ്പെടുന്നത്?',
            taHint: 'இந்தப் பணியில் வெற்றி எவ்வாறு அளவிடப்படுகிறது?',
            hiHint: 'इस भूमिका में सफलता कैसी दिखती है?',
          ),
        ],
      ),
      const _LibraryBook(
        id: 'talking_manager',
        title: 'Talking to Your Manager',
        subtitle: 'Clear updates, requests, and workplace respect',
        category: 'Career',
        accentColor: Color(0xFF4F46E5),
        pages: [
          _BookPageContent(
            heading: 'Giving a Quick Status Update',
            body:
                'Managers love clarity. Instead of a long story, say: "I have completed the first part, and I will share the final draft by 4 PM."\n\nClear timelines build trust fast.',
            keyPhrase: 'I will share the update by 4 PM.',
            mlHint: 'വൈകിട്ട് 4 മണിക്ക് മുമ്പ് ഞാൻ അപ്ഡേറ്റ് പങ്കിടാം.',
            taHint: 'மாலை 4 மணிக்குள் அப்டேட்டைப் பகிர்கிறேன்.',
            hiHint: 'मैं शाम 4 बजे तक अपडेट साझा कर दूँगा।',
          ),
        ],
      ),
      const _LibraryBook(
        id: 'phone_video_calls',
        title: 'Phone & Video Call Etiquette',
        subtitle: 'Sound sharp and polite on Zoom or phone calls',
        category: 'Career',
        accentColor: Color(0xFF7C3AED),
        pages: [
          _BookPageContent(
            heading: 'Checking Audio Politely',
            body:
                'At the start of a call, ask: "Hi, am I audible clearly?" If the connection breaks, say: "Sorry, your voice broke up for a moment. Could you repeat that, please?"',
            keyPhrase: 'Am I audible clearly?',
            mlHint: 'എന്റെ ശബ്ദം വ്യക്തമായി കേൾക്കാമോ?',
            taHint: 'என் குரல் தெளிவாகக் கேட்கிறதா?',
            hiHint: 'क्या मेरी आवाज़ साफ सुनाई दे रही है?',
          ),
        ],
      ),
      const _LibraryBook(
        id: 'emails_that_work',
        title: 'Emails That Work',
        subtitle: 'Write clean, polite messages in 30 seconds',
        category: 'Career',
        accentColor: Color(0xFFE11D48),
        pages: [
          _BookPageContent(
            heading: 'Clear Subject Lines',
            body:
                'A busy person reads the subject line first. Instead of "Hi" or "Urgent", write "Leave Request: Friday" or "Project Update: Ready".',
            keyPhrase: 'Thank you for your time.',
            mlHint: 'നിങ്ങളുടെ സമയത്തിന് നന്ദി.',
            taHint: 'உங்கள் நேரத்திற்கு நன்றி.',
            hiHint: 'आपके समय के लिए धन्यवाद।',
          ),
        ],
      ),
      const _LibraryBook(
        id: 'quiet_leader',
        title: 'The Quiet Leader',
        subtitle: 'How listening makes your English sharper',
        category: 'Career',
        accentColor: Color(0xFF0D9488),
        pages: [
          _BookPageContent(
            heading: 'Listen First, Reply Calmly',
            body:
                'Strong speakers listen carefully first. In a meeting, say: "I see your point, and I would like to add one idea." Polite phrasing earns respect.',
            keyPhrase: 'I see your point.',
            mlHint: 'നിങ്ങൾ പറയുന്നത് എനിക്ക് മനസ്സിലായി.',
            taHint: 'நீங்கள் சொல்வது எனக்குப் புரிகிறது.',
            hiHint: 'मैं आपकी बात समझ रहा हूँ।',
          ),
        ],
      ),
      const _LibraryBook(
        id: 'morning_habit',
        title: 'The Morning Habit',
        subtitle: 'Small daily routines that build fluency',
        category: 'Beginner',
        accentColor: Color(0xFFD97706),
        pages: [
          _BookPageContent(
            heading: 'Before the Phone',
            body:
                'Every morning starts with a quiet choice. Drink water, open the window, and say one simple English sentence aloud: "Today will be a good day."',
            keyPhrase: 'Today will be a good day.',
            mlHint: 'ഇന്ന് ഒരു നല്ല ദിവസമായിരിക്കും.',
            taHint: 'இன்று ஒரு நல்ல நாளாக இருக்கும்.',
            hiHint: 'आज एक अच्छा दिन होगा।',
          ),
          _BookPageContent(
            heading: 'Five Minutes a Day',
            body:
                'Read one short page while your tea cools. Small steps never feel heavy. Repeated daily, English stops feeling like an exam.',
            keyPhrase: 'Small steps never feel heavy.',
            mlHint: 'ചെറിയ ചുവടുകൾ ഒരിക്കലും ഭാരമായി തോന്നില്ല.',
            taHint: 'சிறிய அடிகள் ஒருபோதும் சுமையாகத் தெரியாது.',
            hiHint: 'छोटे कदम कभी भारी नहीं लगते।',
          ),
        ],
      ),
      const _LibraryBook(
        id: 'coffee_kochi',
        title: 'Coffee at Fort Kochi',
        subtitle: 'Everyday café conversations without hesitation',
        category: 'Daily Life',
        accentColor: Color(0xFF059669),
        pages: [
          _BookPageContent(
            heading: 'Ordering Politely',
            body:
                'Meera walks into a small café near the sea and smiles: "Hi, could I get a medium black coffee, please?"\n\nSimple phrases like "Could I get..." sound warm and natural.',
            keyPhrase: 'Could I get..., please?',
            mlHint: 'ദയവായി എനിക്ക് ... കിട്ടുമോ?',
            taHint: 'தயவுசெய்து எனக்கு ... கிடைக்குமா?',
            hiHint: 'क्या मुझे कृपया ... मिल सकता है?',
          ),
          _BookPageContent(
            heading: 'Leaving With a Smile',
            body:
                'Before leaving, say: "It was lovely talking to you. Have a great day!" Real English is about warmth, not speed.',
            keyPhrase: 'It was lovely talking to you.',
            mlHint: 'നിങ്ങളോട് സംസാരിക്കാൻ കഴിഞ്ഞത് സന്തോഷമായി.',
            taHint: 'உங்களுடன் பேசியது மகிழ்ச்சியாக இருந்தது.',
            hiHint: 'आपसे बात करके बहुत अच्छा लगा।',
          ),
        ],
      ),
      const _LibraryBook(
        id: 'midnight_train',
        title: 'Midnight Train to Bengaluru',
        subtitle: 'Storytelling in the past tense with natural flow',
        category: 'Stories',
        accentColor: Color(0xFF7C3AED),
        pages: [
          _BookPageContent(
            heading: 'The Platform Whistle',
            body:
                'The train arrived ten minutes late as rain tapped on the roof. I found my window seat and watched the station lights blur into golden lines.',
            keyPhrase: 'The train arrived on time.',
            mlHint: 'ട്രെയിൻ കൃത്യസമയത്ത് എത്തി.',
            taHint: 'ரயில் சரியான நேரத்திற்கு வந்தது.',
            hiHint: 'ट्रेन समय पर आ गई।',
          ),
          _BookPageContent(
            heading: 'A Cup of Tea at Salem',
            body:
                'An elderly watchmaker offered me hot tea from his flask. "Where are you headed?" he asked. A short chat with a stranger builds real confidence.',
            keyPhrase: 'Where are you headed?',
            mlHint: 'നിങ്ങൾ എവിടേക്കാണ് പോകുന്നത്?',
            taHint: 'நீங்கள் எங்கே செல்கிறீர்கள்?',
            hiHint: 'आप कहाँ जा रहे हैं?',
          ),
        ],
      ),
      const _LibraryBook(
        id: 'asking_help',
        title: 'Asking for Help Without Fear',
        subtitle: 'Simple, polite ways to ask anyone for assistance',
        category: 'Daily Life',
        accentColor: Color(0xFF0EA5E9),
        pages: [
          _BookPageContent(
            heading: 'Excuse Me, Could You Help?',
            body:
                'Never hesitate to ask. Say: "Excuse me, could you help me find the nearest metro station?" People appreciate politeness.',
            keyPhrase: 'Excuse me, could you help me?',
            mlHint: 'ക്ഷമിക്കണം, എന്നെ ഒന്ന് സഹായിക്കാമോ?',
            taHint: 'மன்னிக்கவும், எனக்கு உதவ முடியுமா?',
            hiHint: 'माफ़ कीजिए, क्या आप मेरी मदद कर सकते हैं?',
          ),
        ],
      ),
      const _LibraryBook(
        id: 'elevator_small_talk',
        title: 'Small Talk in an Elevator',
        subtitle: 'Friendly 10-second chats with colleagues',
        category: 'Daily Life',
        accentColor: Color(0xFFF59E0B),
        pages: [
          _BookPageContent(
            heading: 'Light & Friendly',
            body:
                'Break awkward silence easily: "Good morning! How is your week going so far?" or "Looks like it might rain today!"',
            keyPhrase: 'How is your week going?',
            mlHint: 'ഈ ആഴ്ച എങ്ങനെ പോകുന്നു?',
            taHint: 'இந்த வாரம் எப்படிப் போகிறது?',
            hiHint: 'आपका यह सप्ताह कैसा चल रहा है?',
          ),
        ],
      ),
      const _LibraryBook(
        id: 'ordering_food',
        title: 'Ordering Food Like a Pro',
        subtitle: 'Restaurant phrases for dine-in and takeaway',
        category: 'Daily Life',
        accentColor: Color(0xFFEA580C),
        pages: [
          _BookPageContent(
            heading: 'Asking for Recommendations',
            body:
                'Not sure what to pick? Ask the server: "What would you recommend here?" and "Could we have the bill, please?" when done.',
            keyPhrase: 'What would you recommend?',
            mlHint: 'ഇവിടെ എന്താണ് നിങ്ങൾ ശുപാർശ ചെയ്യുന്നത്?',
            taHint: 'இங்கே எதைப் பரிந்துரைப்பீர்கள்?',
            hiHint: 'आप यहाँ क्या सलाह देंगे?',
          ),
        ],
      ),
      const _LibraryBook(
        id: 'airport_travel',
        title: 'At the Airport & Customs',
        subtitle: 'Travel English for check-in, boarding, and arrival',
        category: 'Daily Life',
        accentColor: Color(0xFF2563EB),
        pages: [
          _BookPageContent(
            heading: 'Check-In Counter',
            body:
                'At the counter, hand over your passport and say: "Hi, I would like a window seat if available, please."',
            keyPhrase: 'I would like a window seat, please.',
            mlHint: 'ദയവായി എനിക്ക് ഒരു വിൻഡോ സീറ്റ് തരാമോ?',
            taHint: 'தயவுசெய்து எனக்கு ஜன்னல் இருக்கை கிடைக்குமா?',
            hiHint: 'कृपया मुझे विंडो सीट मिल सकती है?',
          ),
        ],
      ),
      const _LibraryBook(
        id: 'visiting_doctor',
        title: 'Visiting a Doctor',
        subtitle: 'Describe symptoms clearly and calmly',
        category: 'Daily Life',
        accentColor: Color(0xFFDC2626),
        pages: [
          _BookPageContent(
            heading: 'Explaining How You Feel',
            body:
                'Keep it direct: "I have had a mild fever and headache since yesterday morning. How many days should I take this medicine?"',
            keyPhrase: 'I have had this since yesterday.',
            mlHint: 'ഇന്നലെ മുതൽ എനിക്ക് ഇത് ഉണ്ട്.',
            taHint: 'நேற்று முதல் எனக்கு இது உள்ளது.',
            hiHint: 'मुझे यह कल से है।',
          ),
        ],
      ),
      const _LibraryBook(
        id: 'making_friends',
        title: 'Making New Friends',
        subtitle: 'Start warm conversations in a new city',
        category: 'Beginner',
        accentColor: Color(0xFF10B981),
        pages: [
          _BookPageContent(
            heading: 'Finding Common Ground',
            body:
                'Ask open questions: "Where are you from?" and "What do you enjoy doing on weekends?" Listening carefully makes people feel valued.',
            keyPhrase: 'What do you enjoy doing on weekends?',
            mlHint: 'വാരാന്ത്യങ്ങളിൽ എന്താണ് ചെയ്യാൻ ഇഷ്ടം?',
            taHint: 'வார இறுதியில் என்ன செய்யப் பிடிக்கும்?',
            hiHint: 'वीकेंड पर आपको क्या करना पसंद है?',
          ),
        ],
      ),
      const _LibraryBook(
        id: 'handling_mistakes',
        title: 'Handling Mistakes Gracefully',
        subtitle: 'What to say when you forget a word or slip up',
        category: 'Beginner',
        accentColor: Color(0xFF9333EA),
        pages: [
          _BookPageContent(
            heading: 'Never Freeze Over a Word',
            body:
                'Even fluent speakers pause. Simply say: "Sorry, let me rephrase that," or "What I mean is..." Keep moving forward.',
            keyPhrase: 'Let me rephrase that.',
            mlHint: 'ഞാൻ അത് മറ്റൊരു രീതിയിൽ പറയാം.',
            taHint: 'நான் அதை வேறு விதமாகச் சொல்கிறேன்.',
            hiHint: 'मैं इसे दूसरे शब्दों में कहता हूँ।',
          ),
        ],
      ),
      const _LibraryBook(
        id: 'team_meetings',
        title: 'Team Meetings Made Simple',
        subtitle: 'Speak up clearly in group discussions',
        category: 'Career',
        accentColor: Color(0xFF0284C7),
        pages: [
          _BookPageContent(
            heading: 'Sharing Your Idea',
            body:
                'Enter the discussion smoothly: "Could I add something here?" or "I agree with that, and we can also try..."',
            keyPhrase: 'Could I add something here?',
            mlHint: 'ഞാൻ ഇവിടെ ഒരു കാര്യം കൂടി കൂട്ടിച്ചേർക്കട്ടെ?',
            taHint: 'நான் இங்கே ஒரு விஷயத்தைச் சேர்க்கலாமா?',
            hiHint: 'क्या मैं यहाँ कुछ जोड़ सकता हूँ?',
          ),
        ],
      ),
      const _LibraryBook(
        id: 'rainy_bus_stop',
        title: 'The Rainy Bus Stop',
        subtitle: 'A short monsoon story about unexpected kindness',
        category: 'Stories',
        accentColor: Color(0xFF0F766E),
        pages: [
          _BookPageContent(
            heading: 'Sharing an Umbrella',
            body:
                'Heavy June rain poured over the street. A college student offered half of his umbrella to an old man waiting beside him. "Thank you, son," the man smiled.',
            keyPhrase: 'Would you like to share?',
            mlHint: 'നമുക്ക് ഇത് പങ്കിടാമോ?',
            taHint: 'நாம் இதைப் பகிர்ந்து கொள்ளலாமா?',
            hiHint: 'क्या आप इसे साझा करना चाहेंगे?',
          ),
        ],
      ),
      const _LibraryBook(
        id: 'lost_umbrella',
        title: 'The Lost Umbrella',
        subtitle: 'A light story about honesty and small miracles',
        category: 'Stories',
        accentColor: Color(0xFFB45309),
        pages: [
          _BookPageContent(
            heading: 'Found at the Bakery',
            body:
                'Maya forgot her yellow umbrella at the bakery. Two days later, the baker handed it back with a warm smile: "We kept it safe for you!"',
            keyPhrase: 'We kept it safe for you.',
            mlHint: 'ഞങ്ങൾ അത് നിങ്ങൾക്കായി സുരക്ഷിതമായി സൂക്ഷിച്ചു.',
            taHint: 'நாங்கள் அதை உங்களுக்காகப் பத்திரமாக வைத்திருந்தோம்.',
            hiHint: 'हमने इसे आपके लिए सुरक्षित रखा था।',
          ),
        ],
      ),
      const _LibraryBook(
        id: 'five_minutes_stage',
        title: 'Five Minutes Before Stage',
        subtitle: 'Overcoming stage fear with slow breathing',
        category: 'Beginner',
        accentColor: Color(0xFFDB2777),
        pages: [
          _BookPageContent(
            heading: 'Breathe, Smile, Begin',
            body:
                'Before speaking to a group, take one deep breath. Look at one friendly face, smile, and say your first line slowly. Confidence grows after the first sentence.',
            keyPhrase: 'Take one deep breath and begin.',
            mlHint: 'ഒന്ന് ദീർഘമായി ശ്വാസമെടുത്ത് തുടങ്ങുക.',
            taHint: 'ஆழமாக மூச்சு எடுத்துத் தொடங்குங்கள்.',
            hiHint: 'एक गहरी साँस लें और शुरू करें।',
          ),
        ],
      ),
      for (final extra in kExtraEnglishLibraryBooks)
        _LibraryBook(
          id: extra.id,
          title: extra.title,
          subtitle: extra.subtitle,
          category: extra.category,
          accentColor: extra.accentColor,
          pages: [
            for (final p in extra.pages)
              _BookPageContent(
                heading: p.heading,
                body: p.body,
                keyPhrase: p.keyPhrase,
                mlHint: p.mlHint,
              ),
          ],
        ),
    ];

/// 📚 Minimal Editorial English Library & Book-Style Page-Flip Reader
class PocketEnglishLibraryView extends StatefulWidget {
  const PocketEnglishLibraryView({super.key});

  @override
  State<PocketEnglishLibraryView> createState() =>
      _PocketEnglishLibraryViewState();
}

class _PocketEnglishLibraryViewState extends State<PocketEnglishLibraryView> {
  static const int _freeBookLimit = 3;
  String _selectedCategory = 'All';
  bool _isVip = false;
  static const List<String> _categories = [
    'All',
    'Communication',
    'Speaking Keys',
    'Lifestyle',
    'History',
    'Interview',
    'Career',
    'Beginner',
    'Daily Life',
    'Stories',
  ];

  @override
  void initState() {
    super.initState();
    _checkVip();
  }

  Future<void> _checkVip() async {
    final vip = await PocketAdMobService.instance.isUserVip();
    if (mounted) setState(() => _isVip = vip);
  }

  void _showPremiumLibraryPrompt(_LibraryBook book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141B26),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Icon(Icons.lock_rounded, color: Color(0xFFFFD700), size: 36),
              const SizedBox(height: 10),
              Text(
                'Unlock "${book.title}"',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'First $_freeBookLimit books are free! Upgrade to Premium for just ₹99 to unlock all 35+ Communication, Speaking Keys, Lifestyle & History books.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SubscriptionPage()),
                    );
                    _checkVip();
                  },
                  child: Text(
                    'Unlock Full Library • ₹99',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = _resolveLoggedInUserName();
    final allBooks = _buildLibraryBooks(userName);
    final books = _selectedCategory == 'All'
        ? allBooks
        : allBooks.where((b) => b.category == _selectedCategory).toList();

    return Container(
      color: const Color(0xFF0A1118),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              physics: const BouncingScrollPhysics(),
              children: [
          // Minimal Daily Update & Reading Quote Banner
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF141B26),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFD4A373).withValues(alpha: 0.30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📚 Daily Updated Library',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFD4A373),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Read daily, speak clearly — 5 minutes of reading every day transforms your English.',
                  style: GoogleFonts.lora(
                    color: const Color(0xFFE5DEC9),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Minimal Category Chips
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final cat = _categories[idx];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategory = cat);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFD700)
                          : const Color(0xFF141B26),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFFD700)
                            : Colors.white12,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.outfit(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Ultra-Minimal Book Cards (First 3 Free, Rest ₹99 Premium) + Banner every 4 books
          for (int i = 0; i < books.length; i++) ...[
            Builder(
              builder: (context) {
                final book = books[i];
                final globalIdx = allBooks.indexWhere((b) => b.id == book.id);
                final isLocked = !_isVip && globalIdx >= _freeBookLimit;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (isLocked) {
                        _showPremiumLibraryPrompt(book);
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _BookReaderPage(book: book),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141B26),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isLocked
                              ? Colors.white12
                              : book.accentColor.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: GoogleFonts.playfairDisplay(
                                    color: isLocked
                                        ? Colors.white70
                                        : const Color(0xFFFDF8EE),
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  book.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isLocked
                                  ? const Color(0xFFFFD700).withValues(alpha: 0.14)
                                  : const Color(0xFF10B981).withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isLocked
                                    ? const Color(0xFFFFD700).withValues(alpha: 0.45)
                                    : const Color(0xFF10B981).withValues(alpha: 0.45),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              isLocked ? '🔒 ₹99' : 'FREE',
                              style: GoogleFonts.outfit(
                                color: isLocked
                                    ? const Color(0xFFFFD700)
                                    : const Color(0xFF34D399),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if ((i + 1) % 4 == 0)
              const PocketBannerAdWidget(
                margin: EdgeInsets.only(bottom: 10),
              ),
          ],
              ],
            ),
          ),
          const SafeArea(
            top: false,
            child: PocketBannerAdWidget(
              margin: EdgeInsets.symmetric(vertical: 4),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookReaderPage extends StatefulWidget {
  final _LibraryBook book;
  const _BookReaderPage({required this.book});

  @override
  State<_BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<_BookReaderPage> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool _paperMode = true;
  double _fontSize = 16.5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        _paperMode ? const Color(0xFF141210) : const Color(0xFF0A0E14);
    final pageBg =
        _paperMode ? const Color(0xFFFDF8EE) : const Color(0xFF141B26);
    final textColor =
        _paperMode ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);
    final mutedColor =
        _paperMode ? const Color(0xFF6B7280) : Colors.white60;
    final total = widget.book.pages.length;

    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: const SafeArea(
        top: false,
        child: PocketBannerAdWidget(),
      ),
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFFE5DEC9), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.book.title,
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFFFDF8EE),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Text Size',
            icon: const Icon(Icons.format_size_rounded,
                color: Color(0xFFD4A373), size: 20),
            onPressed: () {
              setState(() {
                _fontSize = _fontSize >= 19.5 ? 15.0 : _fontSize + 1.5;
              });
            },
          ),
          IconButton(
            tooltip: 'Toggle Paper / Night',
            icon: Icon(
              _paperMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: const Color(0xFFD4A373),
              size: 20,
            ),
            onPressed: () => setState(() => _paperMode = !_paperMode),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Horizontal Page-Flip Book View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: total,
                onPageChanged: (idx) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentPage = idx);
                },
                itemBuilder: (context, idx) {
                  final page = widget.book.pages[idx];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: pageBg,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: _paperMode
                              ? const Color(0xFFE6D5B8)
                              : Colors.white12,
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              page.heading,
                              style: GoogleFonts.playfairDisplay(
                                color: textColor,
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              page.body,
                              style: GoogleFonts.lora(
                                color: textColor,
                                fontSize: _fontSize,
                                height: 1.72,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: widget.book.accentColor
                                    .withValues(alpha: _paperMode ? 0.10 : 0.16),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: widget.book.accentColor
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'KEY PHRASE',
                                    style: GoogleFonts.outfit(
                                      color: widget.book.accentColor,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '"${page.keyPhrase}"',
                                    style: GoogleFonts.outfit(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    page.localizedHint,
                                    style: GoogleFonts.outfit(
                                      color: mutedColor,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Minimal Bottom Page Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _currentPage > 0
                        ? () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOutCubic,
                            )
                        : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                    label: const Text('Previous'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFE5DEC9),
                    ),
                  ),
                  Text(
                    '${_currentPage + 1} / $total',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFD4A373),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  _currentPage + 1 < total
                      ? ElevatedButton.icon(
                          onPressed: () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOutCubic,
                          ),
                          icon: const Icon(Icons.chevron_right_rounded,
                              size: 18),
                          label: const Text('Next'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4A373),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text('Finish'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
