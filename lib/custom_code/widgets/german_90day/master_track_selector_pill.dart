import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_learning_track_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/german_90day/german_localization_helper.dart';

/// 🎯 Expandable Master Track Selector Pill with Dropdown Arrow & Save Button
/// Tapping opens a compact selection box (`English Master Track` vs `German Master Track`),
/// and tapping Save triggers a brief animated switch/refresh into the chosen track.
class MasterTrackSelectorPill extends StatefulWidget {
  final bool isGermanActive;
  final String? userId;
  final Future<void> Function(String selectedTrack)? onTrackSaved;

  const MasterTrackSelectorPill({
    super.key,
    required this.isGermanActive,
    this.userId,
    this.onTrackSaved,
  });

  @override
  State<MasterTrackSelectorPill> createState() =>
      _MasterTrackSelectorPillState();
}

class _MasterTrackSelectorPillState extends State<MasterTrackSelectorPill> {
  bool _isExpanded = false;
  bool _isSwitching = false;
  late String _pendingTrack;

  @override
  void initState() {
    super.initState();
    _pendingTrack = widget.isGermanActive
        ? PocketLearningTrackService.trackGerman
        : PocketLearningTrackService.trackEnglish;
  }

  @override
  void didUpdateWidget(covariant MasterTrackSelectorPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isGermanActive != widget.isGermanActive) {
      _pendingTrack = widget.isGermanActive
          ? PocketLearningTrackService.trackGerman
          : PocketLearningTrackService.trackEnglish;
    }
  }

  Future<void> _handleSave() async {
    if (_isSwitching) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSwitching = true);

    await Future.delayed(const Duration(milliseconds: 420));
    await PocketLearningTrackService.setTrack(
      _pendingTrack,
      userId: widget.userId,
    );
    if (widget.onTrackSaved != null) {
      await widget.onTrackSaved!(_pendingTrack);
    }

    if (!mounted) return;
    setState(() {
      _isSwitching = false;
      _isExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDe = widget.isGermanActive;
    final title = isDe ? 'GERMAN MASTER TRACK' : 'ENGLISH MASTER TRACK';

    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _isExpanded = !_isExpanded);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.62),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDe
                      ? const Color(0xFFFFCE00).withValues(alpha: 0.75)
                      : Colors.white.withValues(alpha: 0.28),
                  width: 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isDe ? '🇩🇪' : '🎯',
                      style: const TextStyle(fontSize: 11.5)),
                  const SizedBox(width: 5),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: isDe
                          ? const Color(0xFFFFCE00)
                          : Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w800,
                      fontSize: 10.5,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: isDe ? const Color(0xFFFFCE00) : Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 6),
            Container(
              width: 230,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFFCE00).withValues(alpha: 0.55),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.55),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: _isSwitching
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Color(0xFFFFCE00),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _pendingTrack ==
                                    PocketLearningTrackService.trackGerman
                                ? GermanLocalizationHelper.pick(
                                    en: 'Switching to German Track...',
                                    ml: 'ജർമൻ ട്രാക്കിലേക്ക് മാറുന്നു...',
                                    ta: 'ஜெர்மன் வழிக்கு மாறுகிறது...',
                                    hi: 'जर्मन ट्रैक पर स्विच हो रहा है...',
                                    kn: 'ಜರ್ಮನ್ ಟ್ರ್ಯಾಕ್‌ಗೆ ಬದಲಾಗುತ್ತಿದೆ...',
                                    te: 'జర్మన్ ట్రాక్‌కు మారుతోంది...',
                                  )
                                : 'Switching to English Track...',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFCE00),
                              fontWeight: FontWeight.w700,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _trackOption(
                          flag: '🇬🇧',
                          label: 'English Master Track',
                          value: PocketLearningTrackService.trackEnglish,
                        ),
                        const SizedBox(height: 6),
                        _trackOption(
                          flag: '🇩🇪',
                          label: 'German Master Track',
                          value: PocketLearningTrackService.trackGerman,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 34,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFCE00),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: _handleSave,
                            child: Text(
                              GermanLocalizationHelper.pick(
                                en: 'Save',
                                ml: 'സേവ് (Save)',
                                ta: 'சேமி (Save)',
                                hi: 'सहेजें (Save)',
                                kn: 'ಉಳಿಸಿ (Save)',
                                te: 'సేవ్ (Save)',
                              ),
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _trackOption({
    required String flag,
    required String label,
    required String value,
  }) {
    final selected = _pendingTrack == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _pendingTrack = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFCE00).withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFFFFCE00) : Colors.white12,
            width: selected ? 1.3 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  color: selected ? const Color(0xFFFFCE00) : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? const Color(0xFFFFCE00) : Colors.white38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
