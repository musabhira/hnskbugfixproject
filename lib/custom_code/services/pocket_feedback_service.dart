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
  late String _selectedType;
  int _rating = 5;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _stepController = TextEditingController();
  bool _isSubmitting = false;

  List<Map<String, String>> get _categories => [
        {
          'id': 'roadmap_idea',
          'label': PocketLanguageService.localize(
            en: '💡 Suggest Step / Idea',
            ml: '💡 പുതിയ സ്റ്റെപ്പ് / ആശയം',
            hi: '💡 नया स्टेप / सुझाव',
            ta: '💡 புதிய படி / யோசனை',
            te: '💡 కొత్త దశ / ఆలోచన',
          ),
          'sub': 'Suggest New Step / Roadmap',
        },
        {
          'id': 'day_completion',
          'label': PocketLanguageService.localize(
            en: '🌟 Day Completion Review',
            ml: '🌟 ഡേ ഫീഡ്ബാക്ക്',
            hi: '🌟 दिन की समीक्षा',
            ta: '🌟 நாள் கருத்து',
            te: '🌟 రోజు సమీక్ష',
          ),
          'sub': 'Day Review & Experience',
        },
        {
          'id': 'feature_request',
          'label': PocketLanguageService.localize(
            en: '🚀 Feature Request',
            ml: '🚀 പുതിയ ഫീച്ചർ വേണം',
            hi: '🚀 नया फीचर अनुरोध',
            ta: '🚀 புதிய அம்சம் கோரிக்கை',
            te: '🚀 కొత్త ఫీచర్ అభ్యర్థన',
          ),
          'sub': 'Feature Request',
        },
        {
          'id': 'bug_report',
          'label': PocketLanguageService.localize(
            en: '🐞 Report Bug / Issue',
            ml: '🐞 പ്രശ്നം റിപ്പോർട്ട് ചെയ്യാം',
            hi: '🐞 समस्या रिपोर्ट करें',
            ta: '🐞 பிழை அறிக்கை',
            te: '🐞 సమస్య నివేదిక',
          ),
          'sub': 'Bug / Issue Report',
        },
      ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _textController.dispose();
    _stepController.dispose();
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
              en: 'Please enter your feedback or suggestions.',
              ml: 'ദയവായി നിങ്ങളുടെ അഭിപ്രായം രേഖപ്പെടുത്തൂ.',
              hi: 'कृपया अपनी प्रतिक्रिया या सुझाव दर्ज करें।',
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
      suggestedStep: _stepController.text.trim(),
      dayNumber: widget.initialDayNumber,
      rating: _rating,
      type: _selectedType,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      HapticFeedback.heavyImpact();
      Navigator.of(context).pop();

      // Show warm celebratory confirmation in user's native language
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
          ),
          title: Row(
            children: [
              const Text('🚀', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  PocketLanguageService.localize(
                    en: 'Thank you! Received ❤️',
                    ml: 'നന്ദി! ലഭിച്ചു ❤️',
                    hi: 'धन्यवाद! प्राप्त हुआ ❤️',
                    ta: 'நன்றி! பெறப்பட்டது ❤️',
                    te: 'ధన్యవాదాలు! అందింది ❤️',
                  ),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                PocketLanguageService.localize(
                  en: 'Your valuable suggestions and ideas will be reviewed by our startup team. We will integrate your suggested steps into our upcoming syllabus updates!',
                  ml: 'നിങ്ങളുടെ വിലയേറിയ നിർദ്ദേശങ്ങളും അഭിപ്രായങ്ങളും ഞങ്ങളുടെ ടീം പരിശോധിക്കും. നിങ്ങൾ നിർദ്ദേശിച്ച സ്റ്റെപ്പുകൾ അടുത്ത അപ്‌ഡേറ്റുകളിൽ ഉൾപ്പെടുത്താൻ ഞങ്ങൾ പരമാവധി ശ്രമിക്കും!',
                  hi: 'आपकी मूल्यवान प्रतिक्रिया और सुझावों की समीक्षा की जाएगी। हम आपके सुझावों को आगामी अपडेट में शामिल करने का पूरा प्रयास करेंगे!',
                  ta: 'உங்கள் மதிப்புமிக்க கருத்துக்கள் பரிசீலிக்கப்படும். அடுத்த புதுப்பிப்புகளில் அவற்றைச் சேர்க்க முயற்சிப்போம்!',
                  te: 'మీ విలువైన సలహాలను మా బృందం సమీక్షిస్తుంది. రాబోయే అప్‌డేట్‌లలో మీ సూచనలను చేర్చడానికి మేము ప్రయత్నిస్తాము!',
                ),
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                PocketLanguageService.localize(
                  en: 'Done 👍',
                  ml: 'സന്തോഷം 👍',
                  hi: 'ठीक है 👍',
                  ta: 'சரி 👍',
                  te: 'సరే 👍',
                ),
                style: GoogleFonts.outfit(
                  color: const Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
        top: 20,
        bottom: bottomInset + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFF38BDF8), width: 1.4),
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
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Startup Badge & Title
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: const Color(0xFF38BDF8), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 5),
                      Text(
                        'FEEDBACK ENGINE',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF38BDF8),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white60),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              'Your Ideas & Feedback 🚀',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Share Your Ideas & Suggest Steps',
              style: GoogleFonts.outfit(
                color: const Color(0xFF94A3B8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Text('🌿', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Suggest new learning steps or topics here. We will integrate your ideas directly into upcoming syllabus updates!',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFA7F3D0),
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Category Selector Chips
            Text(
              PocketLanguageService.localize(
                en: 'Select Category:',
                ml: 'വിഭാഗം തിരഞ്ഞെടുക്കുക:',
                hi: 'श्रेणी चुनें:',
                ta: 'வகையைத் தேர்ந்தெடுக்கவும்:',
                te: 'వర్గాన్ని ఎంచుకోండి:',
              ),
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedType == cat['id'];
                return ChoiceChip(
                  label: Text(
                    cat['label']!,
                    style: GoogleFonts.outfit(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFFD700),
                  backgroundColor: const Color(0xFF1E293B),
                  side: BorderSide(
                    color:
                        isSelected ? const Color(0xFFFFD700) : Colors.white24,
                    width: 1,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedType = cat['id']!);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Star Rating (1 to 5)
            Row(
              children: [
                Text(
                  PocketLanguageService.localize(
                    en: 'Rating:',
                    ml: 'റേറ്റിംഗ്:',
                    hi: 'रेटिंग:',
                    ta: 'மதிப்பீடு:',
                    te: 'రేటింగ్:',
                  ),
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: List.generate(5, (index) {
                    final starNum = index + 1;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _rating = starNum);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          starNum <= _rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: starNum <= _rating
                              ? const Color(0xFFFFD700)
                              : Colors.white30,
                          size: 26,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Optional: Suggested Step Input
            if (_selectedType == 'roadmap_idea' ||
                _selectedType == 'feature_request') ...[
              Text(
                PocketLanguageService.localize(
                  en: 'Suggested Step Title (e.g. Job Interview Practice):',
                  ml: 'നിർദ്ദേശിക്കുന്ന സ്റ്റെപ്പ് / പേര് (ഉദാ: Job Interview Practice):',
                  hi: 'सुझाए गए स्टेप का नाम (उदा: Job Interview Practice):',
                  ta: 'பரிந்துரைக்கப்பட்ட படி தலைப்பு (எ.கா: Job Interview):',
                  te: 'సూచించిన దశ శీర్షిక (ఉదా: Job Interview Practice):',
                ),
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _stepController,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: PocketLanguageService.localize(
                    en: 'e.g. Shopping English, Airport Dialogues, Phonics...',
                    ml: 'ഉദാ: ഷോപ്പിംഗ് ഇംഗ്ലീഷ്, എയർപോർട്ട് സംഭാഷണം...',
                    hi: 'उदा: शॉपिंग इंग्लिश, एयरपोर्ट बातचीत...',
                    ta: 'எ.கா: ஷாப்பிங் ஆங்கிலம், விமான நிலைய உரையாடல்...',
                    te: 'ఉదా: షాపింగ్ ఇంగ్లీష్, ఎయిర్‌పోర్ట్ సంభాషణ...',
                  ),
                  hintStyle:
                      GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Main Feedback Details
            Text(
              PocketLanguageService.localize(
                en: 'Feedback / Details:',
                ml: 'നിങ്ങളുടെ അഭിപ്രായം:',
                hi: 'आपकी प्रतिक्रिया / विवरण:',
                ta: 'உங்கள் கருத்து / விவரங்கள்:',
                te: 'మీ అభిప్రాయం / వివరాలు:',
              ),
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _textController,
              maxLines: 4,
              minLines: 3,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: PocketLanguageService.localize(
                  en: 'Describe your idea, what you loved, or how we can improve...',
                  ml: 'നിങ്ങളുടെ അഭിപ്രായം, അനുഭവങ്ങൾ അല്ലെങ്കിൽ ആശയങ്ങൾ തുറന്നെഴുതാം...',
                  hi: 'अपना विचार, सुझाव या सुधार यहाँ विस्तार से लिखें...',
                  ta: 'உங்கள் யோசனை அல்லது பரிந்துரைகளை இங்கே எழுதுங்கள்...',
                  te: 'మీ ఆలోచన లేదా సూచనలను ఇక్కడ రాయండి...',
                ),
                hintStyle:
                    GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF10B981), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            PocketLanguageService.localize(
                              en: 'Submit Feedback 🚀',
                              ml: 'ഫീഡ്ബാക്ക് അയക്കാം 🚀',
                              hi: 'फ़ीडबैक भेजें 🚀',
                              ta: 'கருத்து அனுப்பவும் 🚀',
                              te: 'అభిప్రాయం పంపండి 🚀',
                            ),
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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
