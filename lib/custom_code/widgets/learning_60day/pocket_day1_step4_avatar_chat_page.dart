import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';
import 'pocket_master_curriculum_90.dart';
import 'pocket_90day_vocab_curriculum.dart';
import 'pocket_pronunciation_evaluator.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';

/// 💬 Chat Message Model for Step 4 Spoken English
class Step4ChatMessage {
  final String id;
  final bool isAvatar;
  final String avatarName;
  final String avatarIcon;
  final Color avatarColor;
  final String textEn;
  final String? textNative;
  final String? audioText;
  final String? targetSentenceHint;
  final String? targetSentenceHintMl;
  final List<Step4InBubbleOption>? inBubbleOptions;
  final bool isVoiceMessage;
  final String? voiceTranscript;
  final PronunciationEvaluationResult? evaluationResult;

  Step4ChatMessage({
    required this.id,
    required this.isAvatar,
    this.avatarName = 'CyberCat',
    this.avatarIcon = '🐱',
    this.avatarColor = const Color(0xFF0284C7),
    required this.textEn,
    this.textNative,
    this.audioText,
    this.targetSentenceHint,
    this.targetSentenceHintMl,
    this.inBubbleOptions,
    this.isVoiceMessage = false,
    this.voiceTranscript,
    this.evaluationResult,
  });
}

class Step4InBubbleOption {
  final String labelEn;
  final String labelNative;
  final String icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final bool isHighlighted;
  final VoidCallback onTap;

  Step4InBubbleOption({
    required this.labelEn,
    required this.labelNative,
    required this.icon,
    this.backgroundColor = const Color(0xFF0F172A),
    this.borderColor = const Color(0xFF38BDF8),
    this.textColor = Colors.white,
    this.isHighlighted = false,
    required this.onTap,
  });
}

/// 🎙️ Step 4: Spoken English Conversational Chat Page
///
/// User Audio Directives:
/// 1. Natural conversation flow without shortcut answer buttons that bypass speaking.
/// 2. The child speaks into the microphone; their reply appears as a realistic Voice Note bubble (like WhatsApp/Instagram).
/// 3. Continuous ambient background music (BGM) with BGM toggle & TTS toggle in the top bar.
/// 4. Friendly, warm, natural TTS voice configuration.
/// 5. Simple, encouraging beginner-friendly questions.
/// 6. Fully responsive text wrapping with zero clipping or overflow.
class PocketDay1Step4AvatarChatPage extends StatefulWidget {
  final int day;
  final String? userId;
  final Function(int stepIndex)? onStepFinished;

  const PocketDay1Step4AvatarChatPage({
    super.key,
    this.day = 1,
    this.userId,
    this.onStepFinished,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    String? userId,
    Function(int stepIndex)? onStepFinished,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketDay1Step4AvatarChatPage(
          day: day,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketDay1Step4AvatarChatPage> createState() =>
      _PocketDay1Step4AvatarChatPageState();
}

class _PocketDay1Step4AvatarChatPageState
    extends State<PocketDay1Step4AvatarChatPage> with TickerProviderStateMixin {
  late final ScrollController _scrollController = ScrollController();
  late final FlutterTts _tts;
  late final stt.SpeechToText _speech;

  late final AnimationController _pulseController;
  late final AnimationController _waveController;

  final List<Step4ChatMessage> _messages = [];

  bool _isSpeaking = false;
  bool _isSoundMuted = false;
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  String _spokenText = '';
  bool _speechAvailable = false;

  String _userName = 'Hira';
  int _currentDialogueIndex = 0;

  /// 🎙️ 90-Day Progressive Spoken English Conversational Exchanges (User Audio Directive!)
  static List<Map<String, dynamic>> getSpokenDrillsForDay(int day) {
    if (day == 1) {
      return const [
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Hello! How are you feeling today? 🌅',
          'questionMl': 'ഹലോ! ഇന്ന് സുഖമാണോ?',
          'targetReply': 'I am fine, thank you.',
          'targetReplyMl': 'എനിക്ക് സുഖമാണ്, നന്ദി.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'What is your name, my friend? 🤝',
          'questionMl': 'നിന്റെ പേരെന്താണ്?',
          'targetReply': 'My name is Alex.',
          'targetReplyMl': 'എന്റെ പേര് അലക്സ് എന്നാണ്.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Are you a student? 🎒',
          'questionMl': 'നീ ഒരു വിദ്യാർത്ഥിയാണോ?',
          'targetReply': 'Yes, I am a student.',
          'targetReplyMl': 'അതെ, ഞാൻ ഒരു വിദ്യാർത്ഥിയാണ്.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Do you like sweet green grapes? 🍇',
          'questionMl': 'നിനക്ക് മധുരമുള്ള മുന്തിരി ഇഷ്ടമാണോ?',
          'targetReply': 'Yes, I like grapes.',
          'targetReplyMl': 'അതെ, എനിക്ക് മുന്തിരി ഇഷ്ടമാണ്.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Are you feeling thirsty? 💧',
          'questionMl': 'നിനക്ക് ദാഹിക്കുന്നുണ്ടോ?',
          'targetReply': 'Yes, please give me water.',
          'targetReplyMl': 'അതെ, എനിക്ക് വെള്ളം തരൂ.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'What is on your study table? 📖',
          'questionMl': 'നിന്റെ മേശപ്പുറത്ത് എന്താണുള്ളത്?',
          'targetReply': 'This is a book.',
          'targetReplyMl': 'ഇത് ഒരു പുസ്തകമാണ്.',
        },
      ];
    }

    if (day == 2) {
      return const [
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Hello! Where are you from, my friend? 🌍',
          'questionMl': 'ഹലോ! നിങ്ങൾ എവിടെ നിന്നാണ്?',
          'targetReply': 'I am from Kerala.',
          'targetReplyMl': 'ഞാൻ കേരളത്തിൽ നിന്നാണ്.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Do you live in a city or a peaceful town? 🏙️',
          'questionMl': 'നിങ്ങൾ നഗരത്തിലാണോ അതോ പട്ടണത്തിലാണോ താമസിക്കുന്നത്?',
          'targetReply': 'I live in a beautiful city.',
          'targetReplyMl': 'ഞാൻ മനോഹരമായ ഒരു നഗരത്തിലാണ് താമസിക്കുന്നത്.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Tell me about your home. Who do you stay with? 👨‍👩‍👦',
          'questionMl': 'നിങ്ങൾ ആരുടെ കൂടെയാണ് താമസിക്കുന്നത്?',
          'targetReply': 'I stay with my family.',
          'targetReplyMl': 'ഞാൻ എന്റെ കുടുംബത്തോടൊപ്പമാണ് താമസിക്കുന്നത്.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Do you like staying at home in the evening? 🏡',
          'questionMl': 'വൈകുന്നേരങ്ങളിൽ വീട്ടിൽ സമയം ചെലവഴിക്കാൻ ഇഷ്ടമാണോ?',
          'targetReply': 'My home is cozy and warm.',
          'targetReplyMl': 'എന്റെ വീട് സുഖകരവും സന്തോഷം നിറഞ്ഞതുമാണ്.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Do you come home on time after work or study? ⏰',
          'questionMl': 'ജോലി അല്ലെങ്കിൽ പഠനം കഴിഞ്ഞ് കൃത്യസമയത്ത് വീട്ടിൽ എത്താറുണ്ടോ?',
          'targetReply': 'I reach home on time.',
          'targetReplyMl': 'ഞാൻ കൃത്യസമയത്ത് വീട്ടിൽ എത്താറുണ്ട്.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'You spoke with such confidence today! See you tomorrow! 🌟',
          'questionMl': 'വളരെ ആത്മവിശ്വാസത്തോടെ സംസാരിച്ചു! നാളെ വീണ്ടും കാണാം!',
          'targetReply': 'Thank you, see you tomorrow!',
          'targetReplyMl': 'നന്ദി, നാളെ കാണാം!',
        },
      ];
    }

    if (day == 3) {
      return const [
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Hello! Welcome to Day 3! Who is this standing with you? 👨‍👩‍👦',
          'questionMl': 'ഹലോ! ഡേ 3 ലേക്ക് സ്വാഗതം! നിന്റെ കൂടെ നിൽക്കുന്ന ഈ ആൾ ആരാണ്?',
          'targetReply': 'This is my elder brother.',
          'targetReplyMl': 'ഇത് എന്റെ മൂത്ത സഹോദരനാണ്.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'What kind of work does he do? 💻',
          'questionMl': 'അവൻ എന്ത് ജോലിയാണ് ചെയ്യുന്നത്?',
          'targetReply': 'He works in an IT company.',
          'targetReplyMl': 'അവൻ ഒരു ഐടി കമ്പനിയിൽ ജോലി ചെയ്യുന്നു.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Wonderful! Can you introduce your parents to me? 🤝',
          'questionMl': 'വളരെ നല്ലത്! നിന്റെ മാതാപിതാക്കളെ എനിക്ക് പരിചയപ്പെടുത്താമോ?',
          'targetReply': 'Meet my mother and father.',
          'targetReplyMl': 'എന്റെ അമ്മയെയും അച്ഛനെയും പരിചയപ്പെടൂ.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'What does your mother do? Tell me about her! 👩‍🏫',
          'questionMl': 'നിന്റെ അമ്മ എന്ത് ചെയ്യുന്നു? അമ്മയെക്കുറിച്ച് പറയൂ!',
          'targetReply': 'She is a kind school teacher.',
          'targetReplyMl': 'അവൾ ദയയുള്ള ഒരു സ്കൂൾ അധ്യാപികയാണ്.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Is his office located far away from here? 🏢',
          'questionMl': 'അവന്റെ ഓഫീസ് ഇവിടെ നിന്ന് വളരെ ദൂരെയാണോ?',
          'targetReply': 'His office is near our home.',
          'targetReplyMl': 'അവന്റെ ഓഫീസ് ഞങ്ങളുടെ വീടിനടുത്താണ്.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'How do you spend your free time as a family? 🏡',
          'questionMl': 'കുടുംബത്തോടൊപ്പം നിങ്ങൾ എങ്ങനെയാണ് സമയം ചെലവഴിക്കുന്നത്?',
          'targetReply': 'We love spending time together.',
          'targetReplyMl': 'ഞങ്ങൾ ഒരുമിച്ച് സമയം ചിലവഴിക്കാൻ ഇഷ്ടപ്പെടുന്നു.',
        },
      ];
    }

    if (day == 4) {
      return const [
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Hello! Welcome to Day 4! What do you have on your wrist? ⌚',
          'questionMl': 'ഹലോ! ഡേ 4 ലേക്ക് സ്വാഗതം! നിന്റെ കയ്യിൽ എന്താണുള്ളത്?',
          'targetReply': 'This is my new wristwatch.',
          'targetReplyMl': 'ഇത് എന്റെ പുതിയ കൈഘടികാരമാണ്.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Look at the wall over there! What is hanging high up? ⏰',
          'questionMl': 'അവിടെ ആ ചുമരിലേക്ക് നോക്കൂ! എന്താണ് തൂക്കിയിട്ടിരിക്കുന്നത്?',
          'targetReply': 'That is a big wall clock.',
          'targetReplyMl': 'അത് വലിയൊരു ചുമർ ക്ലോക്കാണ്.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'What are those colorful items on your reading table? 📚',
          'questionMl': 'നിന്റെ മേശപ്പുറത്തിരിക്കുന്ന ആ വർണ്ണാഭമായ വസ്തുക്കൾ എന്തൊക്കെയാണ്?',
          'targetReply': 'These are my favorite story books.',
          'targetReplyMl': 'ഇവ എന്റെ പ്രിയപ്പെട്ട കഥാപുസ്തകങ്ങളാണ്.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Look outside the window at the tall tree! What can you see? 🌳',
          'questionMl': 'ജനലിലൂടെ പുറത്തുള്ള ആ വലിയ മരത്തിലേക്ക് നോക്കൂ! എന്താണ് കാണുന്നത്?',
          'targetReply': 'Those are bright birds on the tree.',
          'targetReplyMl': 'അവ മരത്തിലിരിക്കുന്ന തിളങ്ങുന്ന പക്ഷികളാണ്.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Tell me about your morning habit! What time do you wake up? 🌅',
          'questionMl': 'നിന്റെ പ്രഭാത ശീലത്തെക്കുറിച്ച് പറയൂ! എപ്പോഴാണ് ഉണരുന്നത്?',
          'targetReply': 'I wake up early every morning.',
          'targetReplyMl': 'ഞാൻ എല്ലാ ദിവസവും രാവിലെ നേരത്തെ ഉണരുന്നു.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Can you ask me what time it is right now? ⏱️',
          'questionMl': 'ഇപ്പോൾ സമയം എത്രയാണെന്ന് എന്നോട് ചോദിക്കാമോ?',
          'targetReply': 'What is the time right now?',
          'targetReplyMl': 'ഇപ്പോൾ സമയം എത്രയാണ്?',
        },
      ];
    }

    if (day == 5) {
      return const [
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Welcome to Day 5! Do you want to ask me something? 🙋‍♂️',
          'questionMl': 'ഡേ 5 ലേക്ക് സ്വാഗതം! എന്നോട് എന്തെങ്കിലും ചോദിക്കാനുണ്ടോ?',
          'targetReply': 'I have a question for you.',
          'targetReplyMl': 'എനിക്ക് നിങ്ങളോട് ഒരു ചോദ്യമുണ്ട്.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Tell me about your best friend or teacher! What special skill do they have? ✨',
          'questionMl': 'നിന്റെ സുഹൃത്തിനെക്കുറിച്ചോ അധ്യാപകനെക്കുറിച്ചോ പറയൂ! എന്ത് പ്രത്യേക കഴിവാണ് അവർക്കുള്ളത്?',
          'targetReply': 'She has great communication skills.',
          'targetReplyMl': 'അവൾക്ക് മികച്ച ആശയവിനിമയ ശേഷിയുണ്ട്.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'What gadget does your brother or teammate use for coding? 💻',
          'questionMl': 'നിന്റെ സഹോദരൻ കോഡിംഗിനായി ഏത് ഗാഡ്‌ജെറ്റാണ് ഉപയോഗിക്കുന്നത്?',
          'targetReply': 'He has a fast new laptop.',
          'targetReplyMl': 'അവന്റെ പക്കൽ വേഗതയേറിയ പുതിയൊരു ലാപ്ടോപ്പ് ഉണ്ട്.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'What is scheduled on your calendar for today? 📅',
          'questionMl': 'ഇന്ന് നിങ്ങളുടെ കലണ്ടറിൽ എന്താണ് നിശ്ചയിച്ചിരിക്കുന്നത്?',
          'targetReply': 'We have an important team meeting.',
          'targetReplyMl': 'ഞങ്ങൾക്ക് ഇന്ന് ഒരു പ്രധാന ടീം മീറ്റിങ് ഉണ്ട്.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Can you politely ask someone if they are free to talk? ⏳',
          'questionMl': 'ഒരാളോട് സംസാരിക്കാൻ സമയമുണ്ടോ എന്ന് മാന്യമായി എങ്ങനെ ചോദിക്കും?',
          'targetReply': 'Do you have a few minutes?',
          'targetReplyMl': 'നിങ്ങൾക്ക് കുറച്ചു സമയം ഉണ്ടോ?',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Does your team have all the documents needed for work? 📂',
          'questionMl': 'ജോലിക്ക് ആവശ്യമായ എല്ലാ രേഖകളും നിങ്ങളുടെ ടീമിന്റെ പക്കലുണ്ടോ?',
          'targetReply': 'They have all the project files.',
          'targetReplyMl': 'അവരുടെ പക്കൽ എല്ലാ പ്രൊജക്റ്റ് ഫയലുകളും ഉണ്ട്.',
        },
      ];
    }

    if (day == 6) {
      return const [
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Hello! Welcome to Day 6! What do you like to drink every morning? ☕',
          'questionMl': 'ഹലോ! ഡേ 6 ലേക്ക് സ്വാഗതം! എല്ലാ ദിവസവും രാവിലെ എന്താണ് കുടിക്കാൻ ഇഷ്ടപ്പെടുന്നത്?',
          'targetReply': 'I drink black coffee every morning.',
          'targetReplyMl': 'ഞാൻ എല്ലാ ദിവസവും രാവിലെ ബ്ലാക്ക് കോഫി കുടിക്കുന്നു.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'How does your friend travel to his office? 🚇',
          'questionMl': 'നിന്റെ സുഹൃത്ത് എങ്ങനെയാണ് ഓഫീസിലേക്ക് പോകുന്നത്?',
          'targetReply': 'He goes to the office by metro.',
          'targetReplyMl': 'അവൻ മെട്രോയിലാണ് ഓഫീസിൽ പോകുന്നത്.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Tell me about your teacher or mentor! How do they speak English? 🗣️',
          'questionMl': 'നിന്റെ ടീച്ചറെക്കുറിച്ച് പറയൂ! അവർ എങ്ങനെയാണ് ഇംഗ്ലീഷ് സംസാരിക്കുന്നത്?',
          'targetReply': 'She speaks English very fluently.',
          'targetReplyMl': 'അവൾ വളരെ ഒഴുക്കോടെ ഇംഗ്ലീഷ് സംസാരിക്കുന്നു.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'Where does your brother or friend stay active and fit? 🏋️',
          'questionMl': 'നിന്റെ സഹോദരൻ എവിടെയാണ് വ്യായാമം ചെയ്യുന്നത്?',
          'targetReply': 'My brother exercises in the gym.',
          'targetReplyMl': 'എന്റെ സഹോദരൻ ജിമ്മിൽ വ്യായാമം ചെയ്യുന്നു.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'What do you and your family enjoy doing together in the kitchen? 🍳',
          'questionMl': 'നിങ്ങളും കുടുംബവും അടുക്കളയിൽ ഒരുമിച്ച് എന്താണ് ചെയ്യാൻ ഇഷ്ടപ്പെടുന്നത്?',
          'targetReply': 'We cook delicious food together.',
          'targetReplyMl': 'ഞങ്ങൾ ഒരുമിച്ച് രുചികരമായ ഭക്ഷണം പാകം ചെയ്യുന്നു.',
        },
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': Color(0xFF0284C7),
          'questionEn': 'How do your housemates keep their space neat and tidy? 🧹',
          'questionMl': 'നിങ്ങളുടെ പഠനമുറി എങ്ങനെയാണ് വൃത്തിയായി സൂക്ഷിക്കുന്നത്?',
          'targetReply': 'They clean their study room daily.',
          'targetReplyMl': 'അവർ അവരുടെ പഠനമുറി ദിവസേന വൃത്തിയാക്കുന്നു.',
        },
      ];
    }

    // Days 7–90: Progressively synthesized from PocketMasterCurriculum90 & Pocket90DayVocabCurriculum
    final master = PocketMasterCurriculum90.getDay(day);
    final vocab = Pocket90DayVocabCurriculum.getVocabForDay(day);

    final v0 = vocab.isNotEmpty ? vocab[0] : null;
    final v1 = vocab.length > 1 ? vocab[1] : null;

    final evo = master.sentenceEvolution.isNotEmpty
        ? master.sentenceEvolution.first.replaceAll(RegExp(r'^[🟢🟡🟣]\s*Basic:\s*'), '').trim()
        : 'I practice speaking English with confidence.';

    return [
      {
        'avatar': 'CyberCat',
        'icon': '🐱',
        'color': const Color(0xFF0284C7),
        'questionEn': 'Hello! Welcome to Day $day! Are you ready to practice ${master.grammarConcept}? 🌟',
        'questionMl': 'ഹലോ! ഡേ $day ലേക്ക് സ്വാഗതം! നമുക്ക് ${master.grammarConcept} ഇന്ന് പരിശീലിക്കാം!',
        'targetReply': 'Yes, I am ready to practice ${master.grammarConcept}.',
        'targetReplyMl': 'അതെ, ഞാൻ പരിശീലിക്കാൻ തയ്യാറാണ്.',
      },
      if (v0 != null)
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': const Color(0xFF0284C7),
          'questionEn': 'Let\'s use our new word "${v0.word}" (${v0.definition}). Speak this sentence aloud: 💬',
          'questionMl': '"${v0.word}" (${v0.localizedMeaning}) ഉപയോഗിച്ചുള്ള വാചകം ഉറക്കെ പറയൂ:',
          'targetReply': v0.exampleSentence.isNotEmpty ? v0.exampleSentence : 'This is ${v0.word}.',
          'targetReplyMl': v0.localizedMeaning,
        },
      if (v1 != null)
        {
          'avatar': 'CyberCat',
          'icon': '🐱',
          'color': const Color(0xFF0284C7),
          'questionEn': 'Wonderful! How about our word "${v1.word}" (${v1.definition})? Try saying: ✨',
          'questionMl': '"${v1.word}" ഉൾപ്പെടുത്തിയുള്ള അടുത്ത വാചകം പറയൂ:',
          'targetReply': v1.exampleSentence.isNotEmpty ? v1.exampleSentence : 'I understand ${v1.word}.',
          'targetReplyMl': v1.localizedMeaning,
        },
      {
        'avatar': 'CyberCat',
        'icon': '🐱',
        'color': const Color(0xFF0284C7),
        'questionEn': 'Now try today\'s core fluency drill: "${master.focusArea}". Speak clearly into the mic: 🎙️',
        'questionMl': 'ഇന്നത്തെ പ്രധാന സംഭാഷണ പരിശീലന വാചകം മൈക്കിലൂടെ വ്യക്തമായി പറയൂ:',
        'targetReply': master.speakingDrill.isNotEmpty ? master.speakingDrill : 'I communicate with clarity.',
        'targetReplyMl': 'വ്യക്തമായി സംസാരിക്കുന്നു.',
      },
      {
        'avatar': 'CyberCat',
        'icon': '🐱',
        'color': const Color(0xFF0284C7),
        'questionEn': 'Terrific! ${master.peerChatMission.isNotEmpty ? master.peerChatMission : "Now speak this natural conversation phrase:"} 🗣️',
        'questionMl': 'മികച്ച താളം! ഈ വാചകം കൂടി ഉറക്കെ സംസാരിക്കൂ:',
        'targetReply': evo,
        'targetReplyMl': 'സമ്പൂർണ്ണ വാചകം.',
      },
      {
        'avatar': 'CyberCat',
        'icon': '🐱',
        'color': const Color(0xFF0284C7),
        'questionEn': 'Outstanding speaking today on Day $day! Your fluency grows stronger every single day! 🏆',
        'questionMl': 'ഡേ $day-ൽ മികച്ച പ്രകടനം! നിന്റെ സംസാരശേഷി വളരെ മെച്ചപ്പെടുന്നുണ്ട്!',
        'targetReply': 'Thank you, CyberCat! I will keep practicing every day!',
        'targetReplyMl': 'നന്ദി, ഞാൻ എന്നും തുടർന്ന് സംസാരിക്കും!',
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _initAnimationControllers();
    _initAudioEngines();
    _loadUserData();

    // 🎵 Start pleasant ambient BGM immediately as requested
    PocketGameAudioService.instance.playAmbientAppTheme();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSpokenChatIntro();
    });
  }

  void _initAnimationControllers() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  Future<void> _initAudioEngines() async {
    _tts = FlutterTts();
    try {
      await PocketVoiceService.instance.configureOptimalFemaleVoice(_tts);
    } catch (_) {
      try {
        await _tts.setLanguage('en-IN');
        await _tts.setSpeechRate(0.46);
        await _tts.setPitch(1.08);
      } catch (_) {}
    }

    try {
      _tts.setStartHandler(() {
        if (mounted) setState(() => _isSpeaking = true);
      });
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
      _tts.setErrorHandler((_) {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (_) {}

    _speech = stt.SpeechToText();
    try {
      _speechAvailable = await _speech.initialize(
        onError: (_) {
          if (mounted) setState(() => _isRecording = false);
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isRecording = false);
          }
        },
      );
    } catch (_) {
      _speechAvailable = false;
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_display_name') ?? 'Hira';
      if (mounted) setState(() => _userName = name);
    } catch (_) {}
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _scrollController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (_isSoundMuted) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
    // Smooth micro catch-up after layout pass to eliminate sudden jumps
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      final current = _scrollController.position.pixels;
      if ((max - current).abs() > 4) {
        _scrollController.animateTo(
          max,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  // =========================================================================
  // 🎙️ SPOKEN CONVERSATION FLOW (No shortcut buttons during drills!)
  // =========================================================================

  void _startSpokenChatIntro() {
    final introEn =
        'Welcome to Day ${widget.day} Step 4: Spoken English Chat, $_userName! 🎙️\n\n'
        'We learn spoken English by speaking! Tap the Start button below to begin.';
    final introMl =
        'ഡേ ${widget.day} സ്റ്റെപ്പ് 4: സ്പോക്കൺ ഇംഗ്ലീഷ് ചാറ്റിലേക്ക് സ്വാഗതം, $_userName! 🎙️\n\n'
        'ഇംഗ്ലീഷ് സംസാരിച്ചു തന്നെ പഠിക്കാം! താഴെയുള്ള ബട്ടൺ ടാപ്പ് ചെയ്ത് ആരംഭിക്കാം!';

    setState(() {
      _messages.clear();
      _messages.add(
        Step4ChatMessage(
          id: 'spoken_intro',
          isAvatar: true,
          avatarName: 'CyberCat',
          avatarIcon: '🐱',
          avatarColor: const Color(0xFF0284C7),
          textEn: introEn,
          textNative: introMl,
          audioText: 'Welcome to Day ${widget.day} Step 4: Spoken English Chat! Let\'s speak English together!',
          inBubbleOptions: [
            Step4InBubbleOption(
              labelEn: '🎙️ START SPEAKING PRACTICE ➔',
              labelNative: 'സംഭാഷണം ആരംഭിക്കുക',
              icon: '🚀',
              isHighlighted: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFF34D399),
              textColor: Colors.white,
              onTap: _sendNextSpokenDrill,
            ),
          ],
        ),
      );
    });

    _speak('Welcome to Day ${widget.day} Step 4: Spoken English Chat! Let\'s speak English together!');
    _scrollToBottom();
  }

  void _sendNextSpokenDrill() {
    final activeDrills = getSpokenDrillsForDay(widget.day);
    if (_currentDialogueIndex >= activeDrills.length) {
      _showSpokenCompletionDialogue();
      return;
    }

    final drill = activeDrills[_currentDialogueIndex];
    final avatar = drill['avatar'] as String;
    final icon = drill['icon'] as String;
    final color = drill['color'] as Color;
    final qEn = drill['questionEn'] as String;
    final qMl = drill['questionMl'] as String;
    final target = drill['targetReply'] as String;
    final targetMl = drill['targetReplyMl'] as String;

    // 🛑 Note: As explicitly instructed by user, DO NOT add answer buttons inside bubble!
    setState(() {
      _messages.add(
        Step4ChatMessage(
          id: 'spoken_drill_$_currentDialogueIndex',
          isAvatar: true,
          avatarName: avatar,
          avatarIcon: icon,
          avatarColor: color,
          textEn: qEn,
          textNative: qMl,
          audioText: qEn,
          targetSentenceHint: target,
          targetSentenceHintMl: targetMl,
        ),
      );
    });

    _speak(qEn);
    _scrollToBottom();
  }

  int _failedDrillAttempts = 0;

  void _handleUserVoiceSubmission(String voiceText) {
    HapticFeedback.mediumImpact();

    final activeDrills = getSpokenDrillsForDay(widget.day);
    final drill = activeDrills[_currentDialogueIndex.clamp(0, activeDrills.length - 1)];
    final target = drill['targetReply'] as String;

    final evalResult = PocketPronunciationEvaluator.evaluate(
      targetSentence: target.isNotEmpty ? target : voiceText,
      spokenText: voiceText,
    );

    // 🟢 Posts as realistic WhatsApp/Instagram-style Voice Note Message on the right!
    setState(() {
      _messages.add(
        Step4ChatMessage(
          id: 'user_voice_${DateTime.now().millisecondsSinceEpoch}',
          isAvatar: false,
          textEn: voiceText,
          isVoiceMessage: true,
          voiceTranscript: voiceText,
          evaluationResult: evalResult,
        ),
      );
    });
    _scrollToBottom();
    final targetMl = drill['targetReplyMl'] as String;
    final avatar = drill['avatar'] as String;
    final icon = drill['icon'] as String;
    final color = drill['color'] as Color;

    final isCorrect = PocketSpeechNormalizer.isFuzzyMatch(
      voiceText,
      target,
      thresholdPercentage: 35,
    );

    // Natural conversation pause before avatar replies
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      if (isCorrect || _failedDrillAttempts >= 1) {
        // Correct or gentle advance after coaching
        _failedDrillAttempts = 0;
        PocketGameAudioService.instance.playCoinSound();
        _handleSpokenAnswerSuccess();
      } else {
        // Gentle correction for mistakes without breaking conversation
        _failedDrillAttempts++;
        HapticFeedback.lightImpact();

        final retryEn = 'Good try, $_userName! Let\'s say it like this:\n\n"$target"\n\nTap the mic below and try again! 🎙️';
        final retryMl = 'നല്ല ശ്രമം! നമുക്ക് ഒന്നുകൂടി പറഞ്ഞു നോക്കാം:\n"$targetMl"';

        setState(() {
          _messages.add(
            Step4ChatMessage(
              id: 'spoken_retry_${DateTime.now().millisecondsSinceEpoch}',
              isAvatar: true,
              avatarName: avatar,
              avatarIcon: icon,
              avatarColor: color,
              textEn: retryEn,
              textNative: retryMl,
              audioText: 'Good try, $_userName! Let\'s say it like this: $target. Try again!',
            ),
          );
        });

        _speak('Good try, $_userName! Let\'s say it like this: $target. Try again!');
        _scrollToBottom();
      }
    });
  }

  void _handleSpokenAnswerSuccess() {
    _currentDialogueIndex++;

    final praises = [
      'Well said! Perfect tone and confidence! 🌟',
      'Excellent pronunciation! 👏',
      'Very natural English! Keep going! 🚀',
      'Spot on! That sounded so fluent! ✨',
      'Awesome reply! 💯',
    ];
    final praiseEn = praises[_currentDialogueIndex % praises.length];
    final praiseMl = 'വളരെ മികച്ച ഉച്ചാരണം! അഭിനന്ദനങ്ങൾ!';

    final activeDrills = getSpokenDrillsForDay(widget.day);
    final drill = activeDrills[(_currentDialogueIndex - 1).clamp(0, activeDrills.length - 1)];
    final avatar = drill['avatar'] as String;
    final icon = drill['icon'] as String;
    final color = drill['color'] as Color;

    setState(() {
      _messages.add(
        Step4ChatMessage(
          id: 'spoken_praise_$_currentDialogueIndex',
          isAvatar: true,
          avatarName: avatar,
          avatarIcon: icon,
          avatarColor: color,
          textEn: praiseEn,
          textNative: praiseMl,
          audioText: praiseEn,
        ),
      );
    });

    _speak(praiseEn);
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      _sendNextSpokenDrill();
    });
  }

  bool _isStep4Completed = false;

  Future<void> _recordStep4Completion() async {
    _isStep4Completed = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUid = widget.userId ?? Supabase.instance.client.auth.currentUser?.id;
      if (currentUid != null && currentUid.isNotEmpty) {
        await prefs.setBool('pocket_day_${currentUid}_${widget.day}_step_4_done', true);
      }
      await prefs.setBool('pocket_day_guest_${widget.day}_step_4_done', true);
    } catch (_) {}
    try {
      widget.onStepFinished?.call(4);
    } catch (_) {}
  }

  void _showSpokenCompletionDialogue() {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCoinSound();

    // 🟢 Immediately persist Step 4 completion
    _recordStep4Completion();

    final replyEn =
        '🎉 BRILLIANT CONVERSATION, $_userName!\n\n'
        'You spoke every sentence into the mic with confidence! Step 4 is complete!\n\n'
        'Now let\'s proceed to Step 5: Reading Room! 📖';
    final replyMl =
        'ഗംഭീരം, $_userName! നിങ്ങൾ എല്ലാ സംഭാഷണങ്ങളും മൈക്കിലൂടെ ഉറക്കെ പറഞ്ഞു പരിശീലിച്ചു!\n\n'
        'ഇനി നമുക്ക് സ്റ്റെപ്പ് 5: റീഡിംഗ് റൂമിലേക്ക് കടക്കാം! 📖';

    setState(() {
      _messages.add(
        Step4ChatMessage(
          id: 'spoken_finish',
          isAvatar: true,
          avatarName: 'CyberCat',
          avatarIcon: '🐱',
          avatarColor: const Color(0xFF0284C7),
          textEn: replyEn,
          textNative: replyMl,
          audioText: 'Brilliant conversation, $_userName! You completed Step 4! Now let\'s go to Step 5 Reading Room!',
          inBubbleOptions: [
            Step4InBubbleOption(
              labelEn: 'Step 5: Reading Room ➔',
              labelNative: 'സ്റ്റെപ്പ് 5: റീഡിംഗ് റൂം',
              icon: '📖',
              isHighlighted: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFFFFD700),
              textColor: Colors.white,
              onTap: _completeStep4AndProceedToStep5,
            ),
          ],
        ),
      );
    });

    _speak('Brilliant conversation, $_userName! You completed Step 4! Now let\'s go to Step 5 Reading Room!');
    _scrollToBottom();
  }

  Future<void> _completeStep4AndProceedToStep5() async {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCoinSound();

    await _recordStep4Completion();
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _startListeningToCentralMic() async {
    HapticFeedback.mediumImpact();

    // 🛑 If currently recording: user taps to STOP & SEND!
    if (_isRecording) {
      _recordingTimer?.cancel();
      if (_speechAvailable) {
        try {
          await _speech.stop();
        } catch (_) {}
      }
      final phraseToSend = _spokenText.trim();

      setState(() {
        _isRecording = false;
      });

      if (phraseToSend.isEmpty) {
        _speak('I could not hear you clearly, $_userName. Tap the mic and speak aloud.');
        return;
      }

      _handleUserVoiceSubmission(phraseToSend);
      return;
    }

    // 🔴 If not recording: start recording mode!
    try {
      await _tts.stop();
    } catch (_) {}

    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
      _spokenText = '';
    });

    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _recordingSeconds++);
    });

    if (_speechAvailable) {
      try {
        await _speech.listen(
          onResult: (result) {
            if (!mounted) return;
            final recognized = result.recognizedWords.trim();
            if (recognized.isNotEmpty) {
              setState(() {
                _spokenText = recognized;
              });
            }
          },
        );
      } catch (_) {}
    }
  }

  void _cancelRecording() async {
    HapticFeedback.lightImpact();
    _recordingTimer?.cancel();
    try {
      if (_speechAvailable) await _speech.stop();
    } catch (_) {}
    setState(() {
      _isRecording = false;
      _recordingSeconds = 0;
      _spokenText = '';
    });
  }

  // =========================================================================
  // 🎨 UI BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (_isStep4Completed || _currentDialogueIndex >= getSpokenDrillsForDay(widget.day).length) {
          _recordStep4Completion();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF070B11),
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 96),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageItem(_messages[index]);
                  },
                ),
              ),
              _buildMinimalFloatingMicBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
            onPressed: () async {
              if (_isStep4Completed || _currentDialogueIndex >= getSpokenDrillsForDay(widget.day).length) {
                await _recordStep4Completion();
              }
              if (mounted) Navigator.pop(context, _isStep4Completed);
            },
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Text('🎙️', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DAY ${widget.day} • STEP 4: SPOKEN ENGLISH 🎙️',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Interactive Voice Practice',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // 🎵 BGM Music Toggle (User Audio Directive!)
          ValueListenableBuilder<bool>(
            valueListenable: PocketGameAudioService.instance.isMutedNotifier,
            builder: (context, isMuted, _) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  PocketGameAudioService.instance.toggleMute();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: !isMuted ? const Color(0xFF10B981).withValues(alpha: 0.2) : Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: !isMuted ? const Color(0xFF10B981) : Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        !isMuted ? Icons.music_note_rounded : Icons.music_off_rounded,
                        color: !isMuted ? const Color(0xFF10B981) : Colors.white60,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        !isMuted ? 'BGM' : 'MUTED',
                        style: GoogleFonts.outfit(
                          color: !isMuted ? const Color(0xFF10B981) : Colors.white60,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
          // 🔊 TTS Speaker Toggle
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _isSoundMuted = !_isSoundMuted;
                if (_isSoundMuted) _tts.stop();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: !_isSoundMuted ? const Color(0xFF38BDF8).withValues(alpha: 0.2) : Colors.white10,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: !_isSoundMuted ? const Color(0xFF38BDF8) : Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isSoundMuted
                        ? Icons.volume_off_rounded
                        : (_isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined),
                    color: !_isSoundMuted ? const Color(0xFF38BDF8) : Colors.white60,
                    size: 14,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    !_isSoundMuted ? 'TTS' : 'OFF',
                    style: GoogleFonts.outfit(
                      color: !_isSoundMuted ? const Color(0xFF38BDF8) : Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Step4ChatMessage msg) {
    if (msg.isAvatar) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: msg.avatarColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: msg.avatarColor, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(msg.avatarIcon, style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 3),
                Text(
                  msg.avatarName,
                  style: GoogleFonts.outfit(color: Colors.white60, fontSize: 9.5, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.textEn,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                        if (!PocketLanguageService.isEnglish &&
                            (PocketLanguageService.isMalayalam || msg.textNative != msg.textEn) &&
                            msg.textNative != null &&
                            msg.textNative!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            msg.textNative!,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFBAE6FD),
                              fontSize: 12.5,
                              height: 1.3,
                            ),
                          ),
                        ],
                        // Target sentence guidance banner (informative, NOT a clickable cheat button)
                        if (msg.targetSentenceHint != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.mic_none_rounded, color: Color(0xFFFFD700), size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Speak into the mic:',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFFFD700),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '"${msg.targetSentenceHint!}"',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    height: 1.3,
                                  ),
                                ),
                                if (PocketLanguageService.isMalayalam && msg.targetSentenceHintMl != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    msg.targetSentenceHintMl!,
                                    style: GoogleFonts.inter(
                                      color: Colors.white60,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (msg.inBubbleOptions != null && msg.inBubbleOptions!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: msg.inBubbleOptions!.map((opt) {
                        return GestureDetector(
                          onTap: opt.onTap,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width - 90,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: opt.backgroundColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: opt.borderColor, width: opt.isHighlighted ? 2 : 1),
                              boxShadow: opt.isHighlighted
                                  ? [
                                      BoxShadow(
                                        color: opt.borderColor.withValues(alpha: 0.35),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(opt.icon, style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        opt.labelEn,
                                        style: GoogleFonts.outfit(
                                          color: opt.textColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        softWrap: true,
                                      ),
                                      if (opt.labelNative.isNotEmpty)
                                        Text(
                                          opt.labelNative,
                                          style: GoogleFonts.inter(
                                            color: opt.textColor.withValues(alpha: 0.8),
                                            fontSize: 10,
                                          ),
                                          softWrap: true,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // User Message Bubble: Either Text Bubble or Voice Note Bubble
      if (!msg.isVoiceMessage) {
        // 💬 User Text Bubble (When user taps an option or text button)
        return Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0369A1), Color(0xFF075985)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(4),
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                        border: Border.all(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        msg.textEn,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    if (msg.evaluationResult != null) ...[
                      PocketPronunciationInlineBadge(result: msg.evaluationResult!),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                  ),
                ),
                child: const Center(
                  child: Text('👤', style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        );
      }

      // 🎙️ REALISTIC WHATSAPP / INSTAGRAM STYLE VOICE NOTE BUBBLE (User Audio Directive!)
      // Strictly NO transcription text displayed inside or below the bubble!
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.74),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF047857), Color(0xFF10B981)],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _speak(msg.textEn);
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Animated audio waveform simulation
                        Row(
                          children: [8, 16, 22, 14, 26, 18, 24, 12, 20, 10, 16, 22, 10].map((h) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1.5),
                              width: 3,
                              height: h.toDouble(),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '0:03',
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.mic_rounded, color: Color(0xFFFFD700), size: 14),
                      ],
                    ),
                  ),
                  if (msg.evaluationResult != null) ...[
                    PocketPronunciationInlineBadge(result: msg.evaluationResult!),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('👤', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildMinimalFloatingMicBar() {
    final mins = (_recordingSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_recordingSeconds % 60).toString().padLeft(2, '0');

    if (_isRecording) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF8B5CF6), width: 1.8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: _cancelRecording,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'RECORDING ($mins:$secs)',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFEF4444),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Listening... Speak clearly into mic 🎙️',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _startListeningToCentralMic,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.6),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SEND',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.send_rounded, color: Colors.white, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🎙️ Spoken English Practice',
            style: GoogleFonts.outfit(
              color: const Color(0xFFFFD700),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Tap the mic below to speak your answer',
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Center(
            child: GestureDetector(
              onTap: _startListeningToCentralMic,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.55),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mic_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
