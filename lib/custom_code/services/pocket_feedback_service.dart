import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';

/// 💡 App Feedback Model for Startup Roadmap & User Ideas
class AppFeedbackItem {
  final String id;
  final String? userId;
  final String userName;
  final int? dayNumber;
  final String
      feedbackType; // 'roadmap_idea', 'day_completion', 'feature_request', 'bug_report', 'general'
  final int rating;
  final String feedbackText;
  final String? suggestedStep;
  final String language;
  final String status; // 'new', 'reviewed', 'implemented'
  final DateTime createdAt;

  const AppFeedbackItem({
    required this.id,
    this.userId,
    required this.userName,
    this.dayNumber,
    required this.feedbackType,
    required this.rating,
    required this.feedbackText,
    this.suggestedStep,
    this.language = 'ml',
    this.status = 'new',
    required this.createdAt,
  });

  factory AppFeedbackItem.fromMap(Map<String, dynamic> map) {
    return AppFeedbackItem(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString(),
      userName: map['user_name']?.toString() ?? 'Learner',
      dayNumber: (map['day_number'] as num?)?.toInt(),
      feedbackType: map['feedback_type']?.toString() ?? 'roadmap_idea',
      rating: (map['rating'] as num?)?.toInt() ?? 5,
      feedbackText: map['feedback_text']?.toString() ?? '',
      suggestedStep: map['suggested_step']?.toString(),
      language: map['language']?.toString() ?? 'ml',
      status: map['status']?.toString() ?? 'new',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// 🚀 Startup Feedback Engine Service
/// Captures user suggestions, syllabus enhancements, day completion ratings,
/// and feeds them directly into the Admin Panel for continuous product iteration.
class PocketFeedbackService {
  PocketFeedbackService._();
  static final PocketFeedbackService instance = PocketFeedbackService._();

  final _supabase = SupaFlow.client;

  /// Submit feedback to Supabase `app_feedback` table
  Future<bool> submitFeedback({
    required String text,
    String? suggestedStep,
    int? dayNumber,
    int rating = 5,
    String type = 'roadmap_idea',
    String? language,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      String userName = 'Learner';
      if (user != null) {
        try {
          final res = await _supabase
              .from('profile')
              .select('name, first_name')
              .eq('user_id', user.id)
              .maybeSingle();
          if (res != null) {
            userName = res['first_name'] ?? res['name'] ?? 'Learner';
          } else {
            final userRes = await _supabase
                .from('users')
                .select('name, display_name')
                .eq('id', user.id)
                .maybeSingle();
            if (userRes != null) {
              userName = userRes['display_name'] ?? userRes['name'] ?? 'Learner';
            }
          }
        } catch (_) {}
      }

      final String resolvedLanguage =
          (language != null && language.isNotEmpty && language != 'ml')
              ? language
              : (PocketLanguageService.isHindi
                  ? 'hi'
                  : PocketLanguageService.isTamil
                      ? 'ta'
                      : PocketLanguageService.isTelugu
                          ? 'te'
                          : PocketLanguageService.isKannada
                              ? 'kn'
                              : PocketLanguageService.isMalayalam
                                  ? 'ml'
                                  : 'en');

      await _supabase.from('app_feedback').insert({
        'user_id': user?.id,
        'user_name': userName,
        'day_number': dayNumber,
        'feedback_type': type,
        'rating': rating.clamp(1, 5),
        'feedback_text': text.trim(),
        'suggested_step':
            (suggestedStep != null && suggestedStep.trim().isNotEmpty)
                ? suggestedStep.trim()
                : null,
        'language': resolvedLanguage,
        'status': 'new',
      });

      return true;
    } catch (e) {
      debugPrint('Error submitting feedback: $e');
      return false;
    }
  }

  /// Admin: Fetch feedback list
  Future<List<AppFeedbackItem>> fetchFeedbacks({
    String? status,
    String? type,
  }) async {
    try {
      var query = _supabase.from('app_feedback').select();

      if (status != null && status != 'all') {
        query = query.eq('status', status);
      }
      if (type != null && type != 'all') {
        query = query.eq('feedback_type', type);
      }

      final res = await query.order('created_at', ascending: false).limit(100);
      final List list = res as List? ?? [];
      return list
          .map((m) => AppFeedbackItem.fromMap(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching feedbacks: $e');
      return [];
    }
  }

  /// Admin: Update status
  Future<bool> updateFeedbackStatus(String feedbackId, String newStatus) async {
    try {
      await _supabase
          .from('app_feedback')
          .update({'status': newStatus}).eq('id', feedbackId);
      return true;
    } catch (e) {
      debugPrint('Error updating feedback status: $e');
      return false;
    }
  }

  /// 📲 Opens the Bilingual Bottom Sheet Modal for Feedback & Step Submission
  static Future<void> showFeedbackBottomSheet(
    BuildContext context, {
    int? dayNumber,
    String defaultType = 'roadmap_idea',
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FeedbackBottomSheetContent(
        initialDayNumber: dayNumber,
        initialType: defaultType,
      ),
    );
  }
}

class _FeedbackBottomSheetContent extends StatefulWidget {
  final int? initialDayNumber;
  final String initialType;

  const _FeedbackBottomSheetContent({
    this.initialDayNumber,
    required this.initialType,
  });

  @override
  State<_FeedbackBottomSheetContent> createState() =>
      _FeedbackBottomSheetContentState();
}

class _FeedbackBottomSheetContentState
    extends State<_FeedbackBottomSheetContent> {
  int _rating = 5;
  final TextEditingController _textController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            PocketLanguageService.localize(
              en: 'Please enter your feedback.',
              ml: 'ദയവായി നിങ്ങളുടെ അഭിപ്രായം രേഖപ്പെടുത്തൂ.',
              hi: 'कृपया अपनी प्रतिक्रिया दर्ज करें।',
              ta: 'தயவுசெய்து உங்கள் கருத்தை பதிவு செய்யவும்.',
              te: 'దయచేసి మీ అభిప్రాయాన్ని నమోదు చేయండి.',
            ),
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    final success = await PocketFeedbackService.instance.submitFeedback(
      text: text,
      dayNumber: widget.initialDayNumber,
      rating: _rating,
      type: widget.initialType,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      HapticFeedback.heavyImpact();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF10B981), width: 1.2),
          ),
          content: Row(
            children: [
              const Text('❤️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  PocketLanguageService.localize(
                    en: 'Thank you! Your feedback helps us make Pocket Mates better.',
                    ml: 'നന്ദി! നിങ്ങളുടെ അഭിപ്രായം ലഭിച്ചു ❤️',
                    hi: 'धन्यवाद! आपकी प्रतिक्रिया प्राप्त हुई ❤️',
                    ta: 'நன்றி! உங்கள் கருத்து பெறப்பட்டது ❤️',
                    te: 'ధన్యవాదాలు! మీ అభిప్రాయం అందింది ❤️',
                  ),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            PocketLanguageService.localize(
              en: 'Failed to submit feedback. Please try again.',
              ml: 'ഫീഡ്ബാക്ക് അയക്കാൻ കഴിഞ്ഞില്ല, ദയവായി വീണ്ടും ശ്രമിക്കൂ.',
              hi: 'फ़ीडबैक भेजने में विफल। कृपया पुनः प्रयास करें।',
              ta: 'கருத்து அனுப்ப முடியவில்லை. மீண்டும் முயற்சிக்கவும்.',
              te: 'అభిప్రాయం పంపడం విఫలమైంది. దయచేసి మళ్ళీ ప్రయత్నించండి.',
            ),
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: bottomInset + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0xFFFFD700), width: 1.2),
          left: BorderSide(color: Colors.white12, width: 0.5),
          right: BorderSide(color: Colors.white12, width: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header Row: Title & Subtitle + Close Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('💬', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            PocketLanguageService.localize(
                              en: 'Feedback',
                              ml: 'ഫീഡ്ബാക്ക്',
                              hi: 'फ़ीडबैक',
                              ta: 'கருத்து',
                              te: 'అభిప్రాయం',
                            ),
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        PocketLanguageService.localize(
                          en: 'Your feedback helps us make Pocket Mates better.',
                          ml: 'നിങ്ങളുടെ അഭിപ്രായം Pocket Mates കൂടുതൽ മികച്ചതാക്കാൻ സഹായിക്കും.',
                          hi: 'आपकी प्रतिक्रिया पॉकेट मेट्स को और बेहतर बनाने में मदद करती है।',
                          ta: 'உங்கள் கருத்து Pocket Mates-ஐ மேலும் சிறந்ததாக்க உதவும்.',
                          te: 'మీ అభిప్రాయం Pocket Mates ను మరింత మెరుగుపరచడానికి సహాయపడుతుంది.',
                        ),
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Minimal Star Rating
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final starNum = index + 1;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _rating = starNum);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        starNum <= _rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: starNum <= _rating
                            ? const Color(0xFFFFD700)
                            : Colors.white24,
                        size: 32,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Single Feedback Box
            TextField(
              controller: _textController,
              maxLines: 5,
              minLines: 4,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13.5),
              decoration: InputDecoration(
                hintText: PocketLanguageService.localize(
                  en: 'Write your thoughts, suggestions, or issues here...',
                  ml: 'നിങ്ങളുടെ അഭിപ്രായങ്ങളും നിർദ്ദേശങ്ങളും ഇവിടെ എഴുതാം...',
                  hi: 'अपने विचार, सुझाव या समस्या यहाँ लिखें...',
                  ta: 'உங்கள் கருத்துகள் அல்லது ஆலோசனைகளை இங்கே எழுதுங்கள்...',
                  te: 'మీ ఆలోచనలు లేదా సూచనలను ఇక్కడ రాయండి...',
                ),
                hintStyle: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 12.5,
                ),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFFFD700),
                    width: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Minimal Send Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, size: 17, color: Colors.black),
                          const SizedBox(width: 8),
                          Text(
                            PocketLanguageService.localize(
                              en: 'Send Feedback',
                              ml: 'ഫീഡ്ബാക്ക് അയക്കാം',
                              hi: 'फ़ीडबैक भेजें',
                              ta: 'கருத்து அனுப்பவும்',
                              te: 'అభిప్రాయం పంపండి',
                            ),
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
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
