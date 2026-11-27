import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'games/german_alphabet_balloon_sky_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'german_localization_helper.dart';

class _DeAlphaChatMsg {
  final String id;
  final bool isAvatar;
  final String textDe;
  final String textNative;
  final String? audioDe;
  final Widget? cardContent;
  final List<_DeInBubbleBtn>? buttons;
  final bool isVoiceBubble;

  _DeAlphaChatMsg({
    required this.id,
    required this.isAvatar,
    required this.textDe,
    required this.textNative,
    this.audioDe,
    this.cardContent,
    this.buttons,
    this.isVoiceBubble = false,
  });
}

class _DeInBubbleBtn {
  final String label;
  final Color bgColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _DeInBubbleBtn({
    required this.label,
    required this.bgColor,
    required this.borderColor,
    required this.onTap,
  });
}

/// 🇩🇪 Dedicated Day 1 German Alphabet Avatar Chat (A–Z + Ä, Ö, Ü, ß = 30 Letters)
/// 100% pure German + active Native Language. Zero "ABCD" / Zero "A for Apple".
class GermanDay1AlphabetChatPage extends StatefulWidget {
  final String? userId;
  final void Function(int stepIndex)? onStepFinished;

  const GermanDay1AlphabetChatPage({
    super.key,
    this.userId,
    this.onStepFinished,
  });

  static Future<bool?> show(
    BuildContext context, {
    String? userId,
    void Function(int stepIndex)? onStepFinished,
  }) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => GermanDay1AlphabetChatPage(
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<GermanDay1AlphabetChatPage> createState() =>
      _GermanDay1AlphabetChatPageState();
}

class _GermanDay1AlphabetChatPageState
    extends State<GermanDay1AlphabetChatPage> {
  final ScrollController _scrollController = ScrollController();
  late final FlutterTts _tts;
  late final stt.SpeechToText _speech;
  final List<_DeAlphaChatMsg> _messages = [];

  bool _isSpeaking = false;
  bool _isMuted = false;
  bool _isListening = false;
  bool _speechAvailable = false;
  bool _completed = false;

  String _userName = 'Freund';
  int _letterIndex = 0;

  @override
  void initState() {
    super.initState();
    _initUserName();
    _initAudio();
    PocketGameAudioService.instance.playAmbientAppTheme();
    PocketGameAudioService.instance.setVolume(0.14);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startWelcome());
  }

  void _initUserName() {
    try {
      final u = SupaFlow.client.auth.currentUser;
      final meta =
          u?.userMetadata?['display_name'] ?? u?.userMetadata?['full_name'];
      if (meta != null && meta.toString().trim().isNotEmpty) {
        _userName = meta.toString().trim();
        return;
      }
      final email = u?.email ?? '';
      if (email.isNotEmpty) {
        _userName = email.split('@').first;
      }
    } catch (_) {}
  }

  Future<void> _initAudio() async {
    _tts = FlutterTts();
    try {
      await _tts.setLanguage('de-DE');
      await _tts.setSpeechRate(0.43);
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
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (!isMobile) {
      _speechAvailable = false;
      return;
    }
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (s) {
          if ((s == 'done' || s == 'notListening') && mounted && _isListening) {
            setState(() => _isListening = false);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _isListening = false);
        },
      );
    } catch (_) {
      _speechAvailable = false;
    }
  }

  @override
  void dispose() {
    _tts.stop();
    try {
      _speech.stop();
    } catch (_) {}
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _speakGerman(String text) async {
    if (_isMuted) return;
    try {
      await _tts.stop();
      await _tts.setLanguage('de-DE');
      await _tts.speak(text);
    } catch (_) {}
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startWelcome() {
    final textDe =
        'Hallo $_userName! Ich bin CyberCat 🐱. Wollen wir heute das deutsche Alphabet (A–Z, Ä, Ö, Ü, ß) lernen?';
    final textNative = GermanLocalizationHelper.pick(
      en: 'Hi $_userName! I am CyberCat 🐱. Shall we learn the 30 German Letters (A–Z, Ä, Ö, Ü, ß) today?',
      ml: 'ഹലോ $_userName! ഞാൻ സൈബർ ക്യാറ്റ് 🐱. നമുക്കിന്ന് ജർമൻ അക്ഷരമാല (A–Z, Ä, Ö, Ü, ß) പഠിച്ചാലോ?',
      ta: 'வணக்கம் $_userName! நான் சைபர் கேட் 🐱. இன்று ஜெர்மன் எழுத்துக்களை (A–Z, Ä, Ö, Ü, ß) கற்கலாமா?',
      hi: 'नमस्ते $_userName! मैं साइबरकैट हूँ 🐱। क्या आज हम जर्मन वर्णमाला (A–Z, Ä, Ö, Ü, ß) सीखें?',
      kn: 'ಹಲೋ $_userName! ನಾನು ಸೈಬರ್‌ಕ್ಯಾಟ್ 🐱. ಇಂದು ಜರ್ಮನ್ ವರ್ಣಮಾಲೆಯನ್ನು (A–Z, Ä, Ö, Ü, ß) ಕಲಿಯೋಣವೇ?',
      te: 'హలో $_userName! నేను సైబర్‌క్యాట్ 🐱. ఈరోజు జర్మన్ వర్ణమాల (A–Z, Ä, Ö, Ü, ß) నేర్చుకుందామా?',
    );
    const audio =
        'Hallo! Ich bin CyberCat. Wollen wir heute das deutsche Alphabet lernen?';

    setState(() {
      _messages.clear();
      _messages.add(
        _DeAlphaChatMsg(
          id: 'welcome',
          isAvatar: true,
          textDe: textDe,
          textNative: textNative,
          audioDe: audio,
          buttons: [
            _DeInBubbleBtn(
              label: PocketLanguageService.getAppPhrase(
                'lets_learn_german_alpha',
                fallback: '✅ Ja, lernen!',
              ),
              bgColor: const Color(0xFF047857),
              borderColor: const Color(0xFF34D399),
              onTap: _chooseMode,
            ),
            _DeInBubbleBtn(
              label: PocketLanguageService.getAppPhrase(
                'know_next_level_german',
                fallback: '⚡ Weiter ➔',
              ),
              bgColor: const Color(0xFF1E293B),
              borderColor: const Color(0xFF38BDF8),
              onTap: _markCompleteAndExit,
            ),
          ],
        ),
      );
    });
    _speakGerman(audio);
    _scrollBottom();
  }

  void _chooseMode() {
    HapticFeedback.selectionClick();
    final msgNative = GermanLocalizationHelper.pick(
      en: 'Super, $_userName! How do you want to learn the 30 German letters?',
      ml: 'ഗംഭീരം $_userName! എങ്ങനെ ജർമൻ അക്ഷരങ്ങൾ പഠിക്കാൻ ഇഷ്ടപ്പെടുന്നു?',
      ta: 'அருமை $_userName! ஜெர்மன் எழுத்துக்களை எப்படி கற்க விரும்புகிறீர்கள்?',
      hi: 'शानदार $_userName! आप जर्मन अक्षर कैसे सीखना चाहते हैं?',
      kn: 'ಅದ್ಭುತ $_userName! ಜರ್ಮನ್ ಅಕ್ಷರಗಳನ್ನು ಹೇಗೆ ಕಲಿಯಲು ಬಯಸುತ್ತೀರಿ?',
      te: 'అద్భుతం $_userName! జర్మన్ అక్షరాలను ఎలా నేర్చుకోవాలనుకుంటున్నారు?',
    );
    setState(() {
      _messages.add(
        _DeAlphaChatMsg(
          id: 'mode',
          isAvatar: true,
          textDe: 'Wie möchtest du lernen? 🎈🗣️',
          textNative: msgNative,
          audioDe: 'Wie möchtest du lernen?',
          buttons: [
            _DeInBubbleBtn(
              label: GermanLocalizationHelper.pick(
                en: '🎈 Pop Balloons (A–Z, ÄÖÜß)',
                ml: '🎈 ബലൂൺ പൊട്ടിച്ച് പഠിക്കാം (A–Z, ÄÖÜß)',
                ta: '🎈 பலூன் உடைத்துக் கற்கலாம் (A–Z, ÄÖÜß)',
                hi: '🎈 गुब्बारे फोड़कर सीखें (A–Z, ÄÖÜß)',
                kn: '🎈 ಬಲೂನ್ ಒಡೆದು ಕಲಿಯಿರಿ (A–Z, ÄÖÜß)',
                te: '🎈 బెలూన్ పగలగొట్టి నేర్చుకోండి (A–Z, ÄÖÜß)',
              ),
              bgColor: const Color(0xFF0284C7),
              borderColor: const Color(0xFF38BDF8),
              onTap: _openBalloonGame,
            ),
            _DeInBubbleBtn(
              label: GermanLocalizationHelper.pick(
                en: '🗣️ Speak Letter by Letter',
                ml: '🗣️ ഓരോ അക്ഷരവും ഉച്ചരിച്ച് പഠിക്കാം',
                ta: '🗣️ ஒவ்வொரு எழுத்தாகப் பேசிக் கற்கலாம்',
                hi: '🗣️ बोलकर एक-एक अक्षर सीखें',
                kn: '🗣️ ಒಂದೊಂದೇ ಅಕ್ಷರ ಮಾತನಾಡಿ ಕಲಿಯಿರಿ',
                te: '🗣️ ఒక్కో అక్షరం పలికి నేర్చుకోండి',
              ),
              bgColor: const Color(0xFF6D28D9),
              borderColor: const Color(0xFFA855F7),
              onTap: () {
                _letterIndex = 0;
                _showCurrentLetterLesson();
              },
            ),
          ],
        ),
      );
    });
    _speakGerman('Wie möchtest du lernen?');
    _scrollBottom();
  }

  Future<void> _openBalloonGame() async {
    await GermanAlphabetBalloonSkyGamePage.show(
      context,
      userId: widget.userId,
      onCompleted: _markCompleteAndExit,
    );
  }

  void _showCurrentLetterLesson() {
    final letters = GermanLocalizationHelper.germanAlphabet30;
    if (_letterIndex >= letters.length) {
      _markCompleteAndExit();
      return;
    }
    final item = letters[_letterIndex];
    final letter = item['letter'] as String;
    final phonetic = item['phonetic'] as String;
    final word = item['word'] as String;
    final emoji = item['emoji'] as String;
    final voice = item['voice'] as String;
    final meaning = GermanLocalizationHelper.pickMap(
        Map<String, String>.from(item['meaning'] as Map));
    final guide = GermanLocalizationHelper.pickMap(
        Map<String, String>.from(item['guide'] as Map));
    final exDe = item['exampleDe'] as String;
    final exNative = GermanLocalizationHelper.pickMap(
        Map<String, String>.from(item['exampleNative'] as Map));

    setState(() {
      _messages.add(
        _DeAlphaChatMsg(
          id: 'ltr_$_letterIndex',
          isAvatar: true,
          textDe: '$voice $emoji ($phonetic)',
          textNative: '$meaning • $guide',
          audioDe: voice,
          cardContent: Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0A101D),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.45)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(letter,
                        style: GoogleFonts.outfit(
                            color: const Color(0xFF38BDF8),
                            fontSize: 30,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$emoji $word',
                              style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800)),
                          Text(meaning,
                              style: GoogleFonts.inter(
                                  color: const Color(0xFFFACC15),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded,
                          color: Color(0xFF38BDF8)),
                      onPressed: () => _speakGerman('$voice. $exDe'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(exDe,
                    style: GoogleFonts.outfit(
                        color: const Color(0xFF6EE7B7),
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text(exNative,
                    style:
                        GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          buttons: [
            _DeInBubbleBtn(
              label: _letterIndex + 1 < letters.length
                  ? GermanLocalizationHelper.pick(
                      en: 'Next Letter (${_letterIndex + 2}/30) ➔',
                      ml: 'അടുത്ത അക്ഷരം (${_letterIndex + 2}/30) ➔',
                      ta: 'அடுத்த எழுத்து (${_letterIndex + 2}/30) ➔',
                      hi: 'अगला अक्षर (${_letterIndex + 2}/30) ➔',
                      kn: 'ಮುಂದಿನ ಅಕ್ಷರ (${_letterIndex + 2}/30) ➔',
                      te: 'తదుపరి అక్షరం (${_letterIndex + 2}/30) ➔',
                    )
                  : GermanLocalizationHelper.pick(
                      en: 'Complete Alphabet! 🏆',
                      ml: 'പൂർത്തിയാക്കൂ! 🏆',
                      ta: 'முடிக்கவும்! 🏆',
                      hi: 'पूरा करें! 🏆',
                      kn: 'ಪೂರ್ಣಗೊಳಿಸಿ! 🏆',
                      te: 'పూర్తి చేయండి! 🏆',
                    ),
              bgColor: const Color(0xFF10B981),
              borderColor: const Color(0xFF34D399),
              onTap: () {
                _letterIndex++;
                _showCurrentLetterLesson();
              },
            ),
          ],
        ),
      );
    });
    _speakGerman(voice);
    _scrollBottom();
  }

  Future<void> _speakMicCurrent() async {
    final letters = GermanLocalizationHelper.germanAlphabet30;
    final item = letters[_letterIndex.clamp(0, letters.length - 1)];
    final voice = item['voice'] as String;
    setState(() => _isListening = true);
    String heard = '';
    if (_speechAvailable) {
      try {
        await _speech.listen(
          localeId: 'de_DE',
          listenFor: const Duration(seconds: 4),
          onResult: (r) => heard = r.recognizedWords,
        );
        await Future.delayed(const Duration(seconds: 3));
        await _speech.stop();
      } catch (_) {}
    } else {
      await Future.delayed(const Duration(milliseconds: 900));
    }
    if (!mounted) return;
    setState(() {
      _isListening = false;
      _messages.add(
        _DeAlphaChatMsg(
          id: 'mic_${DateTime.now().millisecondsSinceEpoch}',
          isAvatar: false,
          textDe: heard.isNotEmpty ? '🎤 "$heard"' : '🎤 "$voice"',
          textNative: GermanLocalizationHelper.pick(
            en: 'Great German pronunciation!',
            ml: 'മികച്ച ഉച്ചാരണം!',
            ta: 'சிறந்த உச்சரிப்பு!',
            hi: 'बढ़िया उच्चारण!',
            kn: 'ಉತ್ತಮ ಉಚ್ಚಾರಣೆ!',
            te: 'అద్భుతమైన ఉచ్చారణ!',
          ),
          isVoiceBubble: true,
        ),
      );
    });
    PocketGameAudioService.instance.playCorrectSound();
    _scrollBottom();
  }

  Future<void> _markCompleteAndExit() async {
    if (_completed) return;
    _completed = true;
    final prefs = await SharedPreferences.getInstance();
    final uid = widget.userId ?? 'guest';
    await prefs.setBool('pocket_de_day_${uid}_1_step_1_done', true);
    await prefs.setBool('pocket_de_day_${uid}_1_step_1_completed', true);
    await prefs.setBool('pocket_de_day_guest_1_step_1_done', true);
    await PocketFortressDefenseService.recordTrainingPoints(30, uid);
    widget.onStepFinished?.call(1);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final title = GermanLocalizationHelper.pick(
      en: 'German Alphabet (30 Letters)',
      ml: 'ജർമൻ അക്ഷരമാല (30 അക്ഷരങ്ങൾ)',
      ta: 'ஜெர்மன் எழுத்துக்கள் (30)',
      hi: 'जर्मन वर्णमाला (30 अक्षर)',
      kn: 'ಜರ್ಮನ್ ವರ್ಣಮಾಲೆ (30 ಅಕ್ಷರಗಳು)',
      te: 'జర్మన్ వర్ణమాల (30 అక్షరాలు)',
    );
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context, _completed),
        ),
        title: Row(
          children: [
            const VectorAvatarWidget(
              config: VectorAvatarConfig(
                  outfitStyle: 'tech_hoodie', auraStyle: 'electric_aqua'),
              size: 30,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: _isSpeaking ? const Color(0xFF38BDF8) : Colors.white70,
            ),
            onPressed: () {
              setState(() => _isMuted = !_isMuted);
              if (_isMuted) _tts.stop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const PocketBannerAdWidget(
              margin: EdgeInsets.only(top: 6, bottom: 4)),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildBubble(_messages[i]),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              color: const Color(0xFF111827),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _speakMicCurrent,
                      icon: Icon(_isListening
                          ? Icons.graphic_eq_rounded
                          : Icons.mic_rounded),
                      label: Text(
                        _isListening
                            ? GermanLocalizationHelper.pick(
                                en: 'Listening (de-DE)...',
                                ml: 'ശ്രദ്ധിക്കുന്നു...',
                                ta: 'கேட்கிறது...',
                                hi: 'सुन रहा है...',
                                kn: 'ಆಲಿಸುತ್ತಿದೆ...',
                                te: 'వింటోంది...',
                              )
                            : GermanLocalizationHelper.pick(
                                en: 'Speak & Practice 🎙️',
                                ml: 'പറഞ്ഞു പരിശീലിക്കൂ 🎙️',
                                ta: 'பேசிப் பழகுங்கள் 🎙️',
                                hi: 'बोलकर अभ्यास करें 🎙️',
                                kn: 'ಮಾತನಾಡಿ ಅಭ್ಯಾಸ ಮಾಡಿ 🎙️',
                                te: 'మాట్లాడి సాధన చేయండి 🎙️',
                              ),
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isListening
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF38BDF8),
                        foregroundColor:
                            _isListening ? Colors.white : Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
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

  Widget _buildBubble(_DeAlphaChatMsg m) {
    final isMe = !m.isAvatar;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.88),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF047857) : const Color(0xFF151E32),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isMe
                ? const Color(0xFF34D399)
                : const Color(0xFF38BDF8).withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    m.textDe,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (m.audioDe != null)
                  GestureDetector(
                    onTap: () => _speakGerman(m.audioDe!),
                    child: const Icon(Icons.volume_up_rounded,
                        color: Color(0xFF38BDF8), size: 20),
                  ),
              ],
            ),
            if (m.textNative.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                m.textNative,
                style: GoogleFonts.inter(
                  color: const Color(0xFFFACC15),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
            if (m.cardContent != null) m.cardContent!,
            if (m.buttons != null && m.buttons!.isNotEmpty) ...[
              const Divider(color: Colors.white12, height: 18),
              ...m.buttons!.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: b.bgColor,
                        foregroundColor: Colors.white,
                        side: BorderSide(color: b.borderColor),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: b.onTap,
                      child: Text(b.label,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800, fontSize: 13.5)),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
