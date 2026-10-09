import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pocket_syllabus_repository.dart';

/// 🧠 Premium Cinematic Screen that displays the personalized AI curriculum generation animation
class PocketGeneratingSyllabusPage extends StatefulWidget {
  final LearnerLevel level;
  final String nativeLanguage;
  final VoidCallback onContinue;

  const PocketGeneratingSyllabusPage({
    super.key,
    required this.level,
    required this.nativeLanguage,
    required this.onContinue,
  });

  @override
  State<PocketGeneratingSyllabusPage> createState() =>
      _PocketGeneratingSyllabusPageState();
}

class _PocketGeneratingSyllabusPageState
    extends State<PocketGeneratingSyllabusPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _analysisStep = 0;
  bool _isComplete = false;

  final List<Map<String, String>> _generationSteps = [
    {
      'titleEn': 'Analyzing speech baseline & vocabulary level...',
      'titleMl': 'നിങ്ങളുടെ ഭാഷാ നിലവാരവും പദസമ്പത്തും വിശകലനം ചെയ്യുന്നു...',
      'icon': '🧠',
    },
    {
      'titleEn': 'Mapping daily 10-minute micro practice slots...',
      'titleMl': 'ദിവസേനയുള്ള 10 മിനിറ്റ് സ്പീക്കിംഗ് സമയങ്ങൾ ക്രമീകരിക്കുന്നു...',
      'icon': '⏱️',
    },
    {
      'titleEn': 'Synthesizing voice shadow modules & native guides...',
      'titleMl': 'വോയ്സ് മിഷനുകളും മലയാളം ഉച്ചാരണ സഹായികളും ബന്ധിപ്പിക്കുന്നു...',
      'icon': '🎙️',
    },
    {
      'titleEn': 'Personalized 90-Day Master Syllabus Ready!',
      'titleMl': 'നിങ്ങൾക്കായുള്ള 90-ദിവസത്തെ സ്പെഷ്യൽ സിലബസ് തയ്യാറായി! 🎉',
      'icon': '🌟',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _startGenerationSequence();
  }

  void _startGenerationSequence() async {
    for (int i = 0; i < _generationSteps.length; i++) {
      if (!mounted) return;
      setState(() => _analysisStep = i);
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 950));
    }
    if (mounted) {
      HapticFeedback.heavyImpact();
      setState(() => _isComplete = true);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final track = PocketSyllabusRepository.getTrack(widget.level);
    final isMalayalam = widget.nativeLanguage.toLowerCase() == 'malayalam';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),

              // 🌟 Animated Pulsing Avatar / AI Core
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: track.primaryColor.withValues(alpha: 0.35),
                            blurRadius: 36,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        shape: BoxShape.circle,
                        border: Border.all(color: track.primaryColor, width: 2.2),
                      ),
                      child: Icon(
                        _isComplete
                            ? Icons.check_circle_rounded
                            : Icons.auto_awesome_rounded,
                        color: track.primaryColor,
                        size: 42,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Title
              Text(
                _isComplete
                    ? (isMalayalam
                        ? 'നിങ്ങളുടെ സിലബസ് തയ്യാറായി!'
                        : 'Your 90-Day Syllabus is Ready!')
                    : (isMalayalam
                        ? 'നിങ്ങൾക്കായി സിലബസ് ഒരുക്കുന്നു...'
                        : 'Generating Custom Syllabus...'),
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                _isComplete
                    ? (isMalayalam
                        ? 'നിങ്ങളുടെ നിലവാരത്തിനനുസരിച്ചുള്ള പ്രത്യേക റോഡ്മാപ്പ് തയ്യാറാക്കിയിരിക്കുന്നു.'
                        : 'Calibrated perfectly for your speaking fluency path.')
                    : (isMalayalam
                        ? 'നിങ്ങളുടെ മുൻഗണനകളും നിലവാരവും അടിസ്ഥാനമാക്കി റോഡ്മാപ്പ് നിർമ്മിക്കുന്നു.'
                        : 'Analyzing your responses to construct an optimal learning journey.'),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 32),

              // 📊 Step-by-Step Progress Checklist Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: _generationSteps.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final stepData = entry.value;
                    final isDone = idx < _analysisStep || _isComplete;
                    final isCurrent = idx == _analysisStep && !_isComplete;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          if (isDone)
                            const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF10B981), size: 20)
                          else if (isCurrent)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF38BDF8)),
                              ),
                            )
                          else
                            const Icon(Icons.radio_button_unchecked_rounded,
                                color: Colors.white24, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stepData['titleEn']!,
                                  style: GoogleFonts.inter(
                                    color: isDone || isCurrent
                                        ? Colors.white
                                        : Colors.white38,
                                    fontSize: 12.5,
                                    fontWeight: isCurrent
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                if (isMalayalam)
                                  Text(
                                    stepData['titleMl']!,
                                    style: GoogleFonts.inter(
                                      color: isDone || isCurrent
                                          ? const Color(0xFF94A3B8)
                                          : Colors.white24,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // 🏆 Unlocked Track Badge Card (Revealed when complete)
              AnimatedOpacity(
                opacity: _isComplete ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        track.primaryColor.withValues(alpha: 0.22),
                        const Color(0xFF1E293B).withValues(alpha: 0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: track.primaryColor.withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: track.primaryColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(track.icon,
                            color: track.primaryColor, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.badgeText,
                              style: GoogleFonts.outfit(
                                color: track.primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              track.nameEn,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isMalayalam)
                              Text(
                                track.nameNative,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFCBD5E1),
                                  fontSize: 11.5,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 🚀 START DAY 1 Action Button
              if (_isComplete)
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    widget.onContinue();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 6,
                    shadowColor:
                        const Color(0xFF10B981).withValues(alpha: 0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isMalayalam
                            ? 'ദിവസം 1 ആരംഭിക്കുക 🚀'
                            : 'START DAY 1 JOURNEY 🚀',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Center(
                  child: Text(
                    isMalayalam
                        ? 'ദയവായി ഒരു നിമിഷം കാത്തിരിക്കൂ...'
                        : 'Calibrating syllabus...',
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
  );
},
),
),
);
  }
}
