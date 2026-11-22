import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';

/// 📝 Model for custom sentences created by Admin for marketing & Instagram Reels recording.
class AdminMarketingSentence {
  final String id;
  final String prompt; // Native Meaning (Malayalam, Tamil, Hindi, etc.)
  final String englishSentence; // Target English Sentence
  final String extraDistractors; // Optional comma-separated distractor words

  AdminMarketingSentence({
    required this.id,
    required this.prompt,
    required this.englishSentence,
    this.extraDistractors = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'english_sentence': englishSentence,
        'extra_distractors': extraDistractors,
      };

  factory AdminMarketingSentence.fromJson(Map<String, dynamic> json) =>
      AdminMarketingSentence(
        id: json['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        prompt: json['prompt']?.toString() ?? '',
        englishSentence: json['english_sentence']?.toString() ?? '',
        extraDistractors: json['extra_distractors']?.toString() ?? '',
      );

  AdminMarketingSentence copyWith({
    String? prompt,
    String? englishSentence,
    String? extraDistractors,
  }) {
    return AdminMarketingSentence(
      id: id,
      prompt: prompt ?? this.prompt,
      englishSentence: englishSentence ?? this.englishSentence,
      extraDistractors: extraDistractors ?? this.extraDistractors,
    );
  }
}

/// 💾 Repository handling Local Storage for Marketing Studio sentences
class AdminMarketingSentenceRepository {
  static const String _kStorageKey =
      'admin_marketing_sentence_builder_content_v1';

  static final List<AdminMarketingSentence> defaultSentences = [
    AdminMarketingSentence(
      id: 'mkt_1',
      prompt: 'ഞാൻ മലപ്പുറത്തേക്ക് പോയി',
      englishSentence: 'I went to Malappuram',
      extraDistractors: 'go, at, come',
    ),
    AdminMarketingSentence(
      id: 'mkt_2',
      prompt: 'ക്രിസ്റ്റ്യാനോ റൊണാൾഡോ ഫുട്ബോൾ കളിക്കുന്നു',
      englishSentence: 'Cristiano Ronaldo is playing football',
      extraDistractors: 'plays, cricket, was',
    ),
    AdminMarketingSentence(
      id: 'mkt_3',
      prompt: 'മെസ്സി ലോകകപ്പ് ട്രോഫി നേടി',
      englishSentence: 'Messi won the World Cup trophy',
      extraDistractors: 'win, got, the',
    ),
    AdminMarketingSentence(
      id: 'mkt_4',
      prompt: 'നീ എപ്പോഴാണ് കേരളത്തിൽ എത്തിയത്?',
      englishSentence: 'When did you arrive in Kerala?',
      extraDistractors: 'where, come, at',
    ),
    AdminMarketingSentence(
      id: 'mkt_5',
      prompt: 'നമുക്ക് വൈകുന്നേരം ഒരു കട്ടൻ ചായ കുടിക്കാം',
      englishSentence: 'Let us have a black tea in the evening',
      extraDistractors: 'drink, coffee, morning',
    ),
    AdminMarketingSentence(
      id: 'mkt_6',
      prompt: 'ഞാൻ ഇപ്പോൾ ഇംഗ്ലീഷ് പഠിക്കുകയാണ്',
      englishSentence: 'I am learning English right now',
      extraDistractors: 'was, study, speak',
    ),
    AdminMarketingSentence(
      id: 'mkt_7',
      prompt: 'അവൻ ദിവസവും ജിമ്മിൽ പോകാറുണ്ട്',
      englishSentence: 'He goes to the gym every day',
      extraDistractors: 'go, workout, daily',
    ),
    AdminMarketingSentence(
      id: 'mkt_8',
      prompt: 'നിങ്ങൾക്ക് ബിരിയാണി ഇഷ്ടമാണോ?',
      englishSentence: 'Do you like biryani?',
      extraDistractors: 'are, love, eat',
    ),
    AdminMarketingSentence(
      id: 'mkt_9',
      prompt: 'ഇന്നത്തെ കാലാവസ്ഥ വളരെ മനോഹരമാണ്',
      englishSentence: 'The weather today is very beautiful',
      extraDistractors: 'was, good, hot',
    ),
    AdminMarketingSentence(
      id: 'mkt_10',
      prompt: 'വിജയിക്കാൻ കഠിനാധ്വാനം അനിവാര്യമാണ്',
      englishSentence: 'Hard work is essential for success',
      extraDistractors: 'to, needed, win',
    ),
    AdminMarketingSentence(
      id: 'mkt_11',
      prompt: 'நான் மலപ്പുറத்திற்கு சென்றேன்',
      englishSentence: 'I went to Malappuram',
      extraDistractors: 'go, from, came',
    ),
    AdminMarketingSentence(
      id: 'mkt_12',
      prompt: 'நீங்கள் எப்போது வருவீர்கள்?',
      englishSentence: 'When will you come?',
      extraDistractors: 'where, go, are',
    ),
    AdminMarketingSentence(
      id: 'mkt_13',
      prompt: 'നെയ്മർ ബ്രസീലിന്റെ മികച്ച കളിക്കാരനാണ്',
      englishSentence: 'Neymar is the best player of Brazil',
      extraDistractors: 'good, top, in',
    ),
    AdminMarketingSentence(
      id: 'mkt_14',
      prompt: 'ഈ ആപ്പ് നിങ്ങളുടെ ഇംഗ്ലീഷ് സംസാരം മെച്ചപ്പെടുത്തും',
      englishSentence: 'This app will improve your spoken English',
      extraDistractors: 'can, speaking, better',
    ),
    AdminMarketingSentence(
      id: 'mkt_15',
      prompt: 'ഞങ്ങൾ നാളെ കൊച്ചിയിലേക്ക് യാത്ര തിരിക്കും',
      englishSentence: 'We will travel to Kochi tomorrow',
      extraDistractors: 'go, trip, today',
    ),
    AdminMarketingSentence(
      id: 'mkt_16',
      prompt: 'നിന്റെ പ്രധാന ലക്ഷ്യം എന്താണ്?',
      englishSentence: 'What is your main goal?',
      extraDistractors: 'aim, which, how',
    ),
    AdminMarketingSentence(
      id: 'mkt_17',
      prompt: 'അവൾ മനോഹരമായി ഗാനം ആലപിക്കുന്നു',
      englishSentence: 'She sings songs very beautifully',
      extraDistractors: 'sing, song, sweet',
    ),
    AdminMarketingSentence(
      id: 'mkt_18',
      prompt: 'കൂട്ടുകാരുമൊത്ത് സംസാരിക്കാൻ എനിക്ക് സന്തോഷമാണ്',
      englishSentence: 'I am happy to talk with friends',
      extraDistractors: 'speak, love, chat',
    ),
    AdminMarketingSentence(
      id: 'mkt_19',
      prompt: 'എന്റെ ഫോൺ ചാർജ് തീർന്നുപോയി',
      englishSentence: 'My phone battery has run out',
      extraDistractors: 'is, dead, mobile',
    ),
    AdminMarketingSentence(
      id: 'mkt_20',
      prompt: 'ഇന്ന് മുതൽ ദിവസവും സംസാരിച്ചു തുടങ്ങാം',
      englishSentence: 'Let us start speaking every day from today',
      extraDistractors: 'practice, now, daily',
    ),
  ];

  static Future<List<AdminMarketingSentence>> getSentences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final List decoded = jsonDecode(raw);
        final list = decoded
            .map((e) =>
                AdminMarketingSentence.fromJson(Map<String, dynamic>.from(e)))
            .where((s) =>
                s.prompt.trim().isNotEmpty &&
                s.englishSentence.trim().isNotEmpty)
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (e) {
      debugPrint('[MarketingRepo] Error loading sentences: $e');
    }
    // Fallback to default 20 sentences and save
    await saveSentences(defaultSentences);
    return List.from(defaultSentences);
  }

  static Future<void> saveSentences(
      List<AdminMarketingSentence> sentences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(sentences.map((e) => e.toJson()).toList());
      await prefs.setString(_kStorageKey, data);
    } catch (e) {
      debugPrint('[MarketingRepo] Error saving sentences: $e');
    }
  }

  static Future<void> addSentence(AdminMarketingSentence sentence) async {
    final list = await getSentences();
    list.add(sentence);
    await saveSentences(list);
  }

  static Future<void> updateSentence(AdminMarketingSentence sentence) async {
    final list = await getSentences();
    final idx = list.indexWhere((e) => e.id == sentence.id);
    if (idx >= 0) {
      list[idx] = sentence;
      await saveSentences(list);
    }
  }

  static Future<void> deleteSentence(String id) async {
    final list = await getSentences();
    list.removeWhere((e) => e.id == id);
    await saveSentences(list);
  }

  static Future<void> resetToDefaults() async {
    await saveSentences(defaultSentences);
  }
}

/// 🎬 Admin Tab View: Sentence Builder Marketing Studio
class AdminSentenceMarketingStudioTab extends StatefulWidget {
  const AdminSentenceMarketingStudioTab({super.key});

  @override
  State<AdminSentenceMarketingStudioTab> createState() =>
      _AdminSentenceMarketingStudioTabState();
}

class _AdminSentenceMarketingStudioTabState
    extends State<AdminSentenceMarketingStudioTab> {
  List<AdminMarketingSentence> _sentences = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await AdminMarketingSentenceRepository.getSentences();
    if (mounted) {
      setState(() {
        _sentences = data;
        _isLoading = false;
      });
    }
  }

  void _showAddEditDialog({AdminMarketingSentence? existing}) {
    final isEdit = existing != null;
    final promptCtrl = TextEditingController(text: existing?.prompt ?? '');
    final englishCtrl =
        TextEditingController(text: existing?.englishSentence ?? '');
    final distractorsCtrl =
        TextEditingController(text: existing?.extraDistractors ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.movie_creation_rounded,
                color: Color(0xFFFFD700), size: 22),
            const SizedBox(width: 8),
            Text(
              isEdit ? 'Edit Marketing Sentence' : 'Add Marketing Sentence',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NATIVE PROMPT / MEANING (Top Bar)',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: promptCtrl,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. ഞാൻ മലപ്പുറത്തേക്ക് പോയി',
                  hintStyle:
                      GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'CORRECT ENGLISH SENTENCE (Target)',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF38BDF8),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: englishCtrl,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. I went to Malappuram',
                  hintStyle:
                      GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'EXTRA DISTRACTOR WORDS (Optional, comma-separated)',
                style: GoogleFonts.outfit(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: distractorsCtrl,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. go, come, at',
                  hintStyle:
                      GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.outfit(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final prompt = promptCtrl.text.trim();
              final english = englishCtrl.text.trim();
              if (prompt.isEmpty || english.isEmpty) return;

              Navigator.pop(ctx);
              if (isEdit) {
                await AdminMarketingSentenceRepository.updateSentence(
                  existing.copyWith(
                    prompt: prompt,
                    englishSentence: english,
                    extraDistractors: distractorsCtrl.text.trim(),
                  ),
                );
              } else {
                await AdminMarketingSentenceRepository.addSentence(
                  AdminMarketingSentence(
                    id: 'mkt_${DateTime.now().millisecondsSinceEpoch}',
                    prompt: prompt,
                    englishSentence: english,
                    extraDistractors: distractorsCtrl.text.trim(),
                  ),
                );
              }
              _loadData();
            },
            child: Text(
              isEdit ? 'Update' : 'Add',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDelete(AdminMarketingSentence s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Delete Sentence?',
          style: GoogleFonts.outfit(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${s.prompt}"?',
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.outfit(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AdminMarketingSentenceRepository.deleteSentence(s.id);
      _loadData();
    }
  }

  void _handleReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Reset to Default Sentences?',
          style: GoogleFonts.outfit(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will restore the 20 pre-built viral marketing sentences (Ronaldo, Messi, Kerala districts, Tamil, etc.).',
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.outfit(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Reset',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AdminMarketingSentenceRepository.resetToDefaults();
      _loadData();
    }
  }

  void _startSimulator({int initialIndex = 0}) {
    if (_sentences.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add at least one sentence first!',
              style: GoogleFonts.outfit()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminSentenceBuilderSimulatorPage(
          sentences: _sentences,
          initialIndex: initialIndex.clamp(0, _sentences.length - 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD700)),
      );
    }

    final q = _searchQuery.toLowerCase();
    final filtered = _sentences.where((s) {
      if (q.isEmpty) return true;
      return s.prompt.toLowerCase().contains(q) ||
          s.englishSentence.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: Column(
        children: [
          // Top Control Card
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.movie_creation_rounded,
                        color: Color(0xFFFFD700),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sentence Builder Studio',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Viral content generator for Instagram Reels & screen recording',
                            style: GoogleFonts.outfit(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_sentences.length} Ready',
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(
                          'Add Sentence',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        onPressed: () => _showAddEditDialog(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                      icon: const Icon(Icons.restore_rounded, size: 16),
                      label: Text(
                        'Reset (20)',
                        style: GoogleFonts.outfit(fontSize: 12.5),
                      ),
                      onPressed: _handleReset,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'Search sentences by prompt or English...',
                hintStyle:
                    GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded,
                    size: 18, color: Color(0xFFFFD700)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1E293B),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Sentence List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isNotEmpty
                          ? 'No sentences matching "$_searchQuery"'
                          : 'No sentences added yet',
                      style: GoogleFonts.outfit(
                          color: Colors.white54, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final words = item.englishSentence.split(' ');
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2129),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '#${index + 1}',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFFD700),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.prompt,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.englishSentence,
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFFFD700),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (item.extraDistractors.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Distractors: ${item.extraDistractors}',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white38,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    '${words.length} words',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF38BDF8),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.play_circle_fill_rounded,
                                    color: Color(0xFF22C55E),
                                    size: 26,
                                  ),
                                  tooltip: 'Simulate this sentence',
                                  onPressed: () => _startSimulator(
                                      initialIndex: _sentences.indexOf(item)),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_rounded,
                                          size: 16, color: Colors.white60),
                                      onPressed: () =>
                                          _showAddEditDialog(existing: item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          size: 16, color: Colors.redAccent),
                                      onPressed: () => _handleDelete(item),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          border: Border(
            top: BorderSide(
              color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            ),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 4,
            ),
            icon: const Icon(Icons.rocket_launch_rounded, size: 20),
            label: Text(
              '🚀 Launch Sentence Builder Simulator',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
              ),
            ),
            onPressed: () => _startSimulator(initialIndex: 0),
          ),
        ),
      ),
    );
  }
}

/// 🎮 Exact Clone Replica of the Sentence Builder Game for Screen Recording & Reels
class AdminSentenceBuilderSimulatorPage extends StatefulWidget {
  final List<AdminMarketingSentence> sentences;
  final int initialIndex;

  const AdminSentenceBuilderSimulatorPage({
    super.key,
    required this.sentences,
    this.initialIndex = 0,
  });

  @override
  State<AdminSentenceBuilderSimulatorPage> createState() =>
      _AdminSentenceBuilderSimulatorPageState();
}

class _AdminSentenceBuilderSimulatorPageState
    extends State<AdminSentenceBuilderSimulatorPage>
    with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  late int _currentIndex;
  bool _isRoundCompleted = false;

  final List<_SimTile> _placedTiles = [];
  final List<_SimTile> _remainingTiles = [];

  String? _shakingTileId;
  late AnimationController _shakeAnimController;

  static const List<Color> _tileColors = [
    Color(0xFFE91E63), // Vibrant Pink / Magenta
    Color(0xFF00E676), // Vibrant Green
    Color(0xFF00E5FF), // Vibrant Sky Cyan
    Color(0xFFFFB300), // Vibrant Amber / Yellow
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _shakeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _initTts();
    _loadRound(_currentIndex);
  }

  @override
  void dispose() {
    _shakeAnimController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("en-IN");
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setPitch(1.05);
      await PocketVoiceService.instance
          .configureOptimalFemaleVoice(_flutterTts);
    } catch (_) {}
  }

  void _loadRound(int index) {
    if (index < 0 || index >= widget.sentences.length) return;

    final currentSentence = widget.sentences[index];
    final targetWords = currentSentence.englishSentence
        .split(' ')
        .where((w) => w.trim().isNotEmpty)
        .toList();

    final List<_SimTile> allTiles = [];

    // Add target words with assigned vibrant colors
    for (int i = 0; i < targetWords.length; i++) {
      allTiles.add(
        _SimTile(
          id: 'target_${index}_${i}_${targetWords[i]}',
          word: targetWords[i],
          color: _tileColors[i % _tileColors.length],
        ),
      );
    }

    // Add distractors if provided, or default distractors
    List<String> distractors = [];
    if (currentSentence.extraDistractors.isNotEmpty) {
      distractors = currentSentence.extraDistractors
          .split(',')
          .map((w) => w.trim())
          .where((w) => w.isNotEmpty)
          .toList();
    }

    for (int d = 0; d < distractors.length; d++) {
      allTiles.add(
        _SimTile(
          id: 'distractor_${index}_${d}_${distractors[d]}',
          word: distractors[d],
          color: _tileColors[(targetWords.length + d) % _tileColors.length],
        ),
      );
    }

    // Shuffle the tiles so they are scrambled in the bottom word bank
    allTiles.shuffle(math.Random());

    setState(() {
      _currentIndex = index;
      _placedTiles.clear();
      _remainingTiles.clear();
      _remainingTiles.addAll(allTiles);
      _isRoundCompleted = false;
      _shakingTileId = null;
    });
  }

  Future<void> _speakText(String text) async {
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  void _onTileTapped(_SimTile tile) {
    if (_isRoundCompleted) return;

    final targetWords = widget.sentences[_currentIndex].englishSentence
        .split(' ')
        .where((w) => w.trim().isNotEmpty)
        .toList();

    final nextExpectedIndex = _placedTiles.length;
    if (nextExpectedIndex >= targetWords.length) return;

    final expectedWord = targetWords[nextExpectedIndex];

    // Case-insensitive clean comparison
    final cleanTileWord =
        tile.word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
    final cleanExpectedWord =
        expectedWord.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();

    if (cleanTileWord == cleanExpectedWord) {
      // ✅ CORRECT TILE!
      PocketGameSfx.instance.playSnapCorrect();
      HapticFeedback.lightImpact();

      setState(() {
        _remainingTiles.removeWhere((t) => t.id == tile.id);
        _placedTiles.add(tile);
      });

      _speakText(tile.word);

      // Check if entire sentence is completed
      if (_placedTiles.length == targetWords.length) {
        _onRoundCompleted();
      }
    } else {
      // ❌ WRONG TILE!
      PocketGameSfx.instance.playErrorBuzz();
      HapticFeedback.heavyImpact(); // Strong error vibration!

      setState(() {
        _shakingTileId = tile.id;
      });

      _shakeAnimController.forward(from: 0.0).then((_) {
        if (mounted) {
          setState(() {
            _shakingTileId = null;
          });
        }
      });
    }
  }

  void _onPlacedTileTapped(_SimTile tile) {
    if (_isRoundCompleted) return;
    PocketGameSfx.instance.playTilePop();
    HapticFeedback.selectionClick();
    setState(() {
      _placedTiles.removeWhere((t) => t.id == tile.id);
      _remainingTiles.add(tile);
    });
  }

  void _onRoundCompleted() {
    setState(() {
      _isRoundCompleted = true;
    });

    PocketGameSfx.instance.playVictory();
    HapticFeedback.mediumImpact();

    final fullSentence = widget.sentences[_currentIndex].englishSentence;
    _speakText(fullSentence);
  }

  void _nextSentence() {
    if (_currentIndex < widget.sentences.length - 1) {
      _loadRound(_currentIndex + 1);
    } else {
      _loadRound(0); // Loop back
    }
  }

  void _prevSentence() {
    if (_currentIndex > 0) {
      _loadRound(_currentIndex - 1);
    }
  }

  void _restartCurrentSentence() {
    _loadRound(_currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final currentSentence = widget.sentences[_currentIndex];
    final targetWords = currentSentence.englishSentence
        .split(' ')
        .where((w) => w.trim().isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white70, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sentence Builder',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_currentIndex + 1} of ${widget.sentences.length}',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Prev
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded,
                        color: Colors.white70, size: 24),
                    onPressed: _currentIndex > 0 ? _prevSentence : null,
                  ),
                  // Restart (Great for reels if you misclick!)
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded,
                        color: Color(0xFFFFD700), size: 22),
                    tooltip: 'Restart Sentence',
                    onPressed: _restartCurrentSentence,
                  ),
                  // Next
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded,
                        color: Colors.white70, size: 24),
                    onPressed: _nextSentence,
                  ),
                ],
              ),
            ),

            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / widget.sentences.length,
                  backgroundColor: Colors.white12,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                  minHeight: 5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Big Bold Prompt Card (Native Meaning)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.translate_rounded,
                            color: Color(0xFFFFD700), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'TRANSLATE THIS SENTENCE',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentSentence.prompt,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Assembled Sentence Area (Placed Tiles)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131A2A),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _isRoundCompleted
                          ? const Color(0xFF22C55E)
                          : Colors.white12,
                      width: _isRoundCompleted ? 2.0 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isRoundCompleted
                                ? Icons.check_circle_rounded
                                : Icons.dashboard_customize_rounded,
                            size: 16,
                            color: _isRoundCompleted
                                ? const Color(0xFF22C55E)
                                : Colors.white38,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isRoundCompleted
                                ? 'EXCELLENT! COMPLETED 🎉'
                                : 'TAP WORDS IN CORRECT ORDER',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: _isRoundCompleted
                                  ? const Color(0xFF22C55E)
                                  : Colors.white38,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded,
                                color: Color(0xFFFFD700), size: 20),
                            onPressed: () => _speakText(
                                currentSentence.englishSentence),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: [
                                ..._placedTiles.map((tile) {
                                  return GestureDetector(
                                    onTap: () => _onPlacedTileTapped(tile),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: tile.color,
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: tile.color
                                                .withValues(alpha: 0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        tile.word,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                // Dotted slots for remaining words
                                if (!_isRoundCompleted)
                                  ...List.generate(
                                    targetWords.length - _placedTiles.length,
                                    (i) => Container(
                                      width: 48,
                                      height: 38,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.04),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.white24,
                                          style: BorderStyle.solid,
                                          width: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bottom Word Bank Area
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'AVAILABLE WORDS',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Colors.white38,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: _remainingTiles.map((tile) {
                            final isShaking = _shakingTileId == tile.id;
                            Widget tileWidget = GestureDetector(
                              onTap: () => _onTileTapped(tile),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isShaking
                                      ? Colors.redAccent
                                      : tile.color,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isShaking
                                              ? Colors.redAccent
                                              : tile.color)
                                          .withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  tile.word,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            );

                            if (isShaking) {
                              return AnimatedBuilder(
                                animation: _shakeAnimController,
                                builder: (context, child) {
                                  final offset = math.sin(
                                          _shakeAnimController.value *
                                              math.pi *
                                              6) *
                                      8;
                                  return Transform.translate(
                                    offset: Offset(offset, 0),
                                    child: child,
                                  );
                                },
                                child: tileWidget,
                              );
                            }

                            return tileWidget;
                          }).toList(),
                        ),
                      ),
                    ),
                    if (_isRoundCompleted) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22C55E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          icon: const Icon(Icons.arrow_forward_rounded,
                              size: 20),
                          label: Text(
                            'Next Sentence ->',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          onPressed: _nextSentence,
                        ),
                      ),
                    ],
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

class _SimTile {
  final String id;
  final String word;
  final Color color;

  _SimTile({
    required this.id,
    required this.word,
    required this.color,
  });
}
