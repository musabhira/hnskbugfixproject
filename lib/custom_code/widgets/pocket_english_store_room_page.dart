import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 📚 ENGLISH STORE ROOM & AUDIO LOUNGE
/// A rich, comic-styled, pure-English learning powerhouse featuring:
/// 1. 🎧 Audio Stories & Reading Room (With native TTS narration & playback speed)
/// 2. 🎓 Student & Campus Survival (Teacher etiquette, asking doubts, exam structuring, academic emails)
/// 3. 💼 Interview & Career Vault (Top questions, STAR model answers, meeting phrases, workplace emails)
/// 4. 🌍 Everyday Real Situations (Airport, doctor, restaurant, returns, networking)
/// 5. ⚡ Smart English Toolkit & Lexicon (Live Dictionary API, 50+ Power Idioms, Silent Letters, Tongue Twisters)
class PocketEnglishStoreRoomPage extends StatefulWidget {
  const PocketEnglishStoreRoomPage({super.key});

  @override
  State<PocketEnglishStoreRoomPage> createState() => _PocketEnglishStoreRoomPageState();
}

class _PocketEnglishStoreRoomPageState extends State<PocketEnglishStoreRoomPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FlutterTts _tts = FlutterTts();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dictionaryInputController = TextEditingController();

  int _selectedTab = 0;
  String _searchQuery = '';
  bool _isPlayingAudio = false;
  String _currentlyPlayingId = '';
  double _speechRate = 0.45; // Natural human pace for English learners
  Set<String> _bookmarkedIds = {};

  // Live Dictionary API State
  bool _isLoadingDictionary = false;
  Map<String, dynamic>? _dictionaryResult;
  String? _dictionaryError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (mounted && _tabController.indexIsChanging) {
        setState(() {
          _selectedTab = _tabController.index;
        });
      }
    });
    _initTts();
    _loadBookmarks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _dictionaryInputController.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(_speechRate);
      await _tts.setPitch(1.0);
      _tts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _isPlayingAudio = false;
            _currentlyPlayingId = '';
          });
        }
      });
      _tts.setErrorHandler((msg) {
        if (mounted) {
          setState(() {
            _isPlayingAudio = false;
            _currentlyPlayingId = '';
          });
        }
      });
    } catch (_) {}
  }

  Future<void> _loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('pocket_english_vault_bookmarks') ?? [];
      if (mounted) {
        setState(() {
          _bookmarkedIds = list.toSet();
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleBookmark(String id) async {
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_bookmarkedIds.contains(id)) {
        _bookmarkedIds.remove(id);
      } else {
        _bookmarkedIds.add(id);
      }
    });
    await prefs.setStringList('pocket_english_vault_bookmarks', _bookmarkedIds.toList());
  }

  Future<void> _speakText(String id, String text) async {
    HapticFeedback.selectionClick();
    if (_isPlayingAudio && _currentlyPlayingId == id) {
      await _tts.stop();
      setState(() {
        _isPlayingAudio = false;
        _currentlyPlayingId = '';
      });
      return;
    }

    await _tts.stop();
    setState(() {
      _isPlayingAudio = true;
      _currentlyPlayingId = id;
    });

    // Remove markdown formatting / symbols before speaking
    final cleanText = text
        .replaceAll(RegExp(r'[*_#`~]'), '')
        .replaceAll('•', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    await _tts.setSpeechRate(_speechRate);
    await _tts.speak(cleanText);
  }

  Future<void> _lookupDictionary(String word) async {
    final query = word.trim().toLowerCase();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoadingDictionary = true;
      _dictionaryError = null;
      _dictionaryResult = null;
    });

    try {
      final url = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$query');
      final res = await http.get(url).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        if (data.isNotEmpty && mounted) {
          setState(() {
            _dictionaryResult = data.first as Map<String, dynamic>;
            _isLoadingDictionary = false;
          });
          return;
        }
      }
      if (mounted) {
        setState(() {
          _dictionaryError = "Word not found in online lexicon. Try another keyword.";
          _isLoadingDictionary = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dictionaryError = "Could not connect to online dictionary. Check your internet connection.";
          _isLoadingDictionary = false;
        });
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard! ✨'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopHeroHeader(isDark, cardBg, textColor),
            _buildComicTabBar(isDark, cardBg, textColor),
            if (_isPlayingAudio) _buildActiveAudioPlayerBar(isDark),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAudioLibraryTab(isDark, cardBg, textColor),
                  _buildStudentSurvivalTab(isDark, cardBg, textColor),
                  _buildInterviewVaultTab(isDark, cardBg, textColor),
                  _buildEverydayDialoguesTab(isDark, cardBg, textColor),
                  _buildSmartToolkitTab(isDark, cardBg, textColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 🎨 HERO HEADER & COMIC AESTHETIC BAR
  // ==========================================
  Widget _buildTopHeroHeader(bool isDark, Color cardBg, Color textColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFC00),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_stories_rounded, color: Colors.black, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'ENGLISH STORE ROOM',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF2A85),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.black, width: 1.2),
                          ),
                          child: Text(
                            'PRO',
                            style: GoogleFonts.outfit(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Audio Library • Interview Vault • Campus • Tools',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              // Speech speed controller toggle
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (_speechRate == 0.45) {
                      _speechRate = 0.55;
                    } else if (_speechRate == 0.55) {
                      _speechRate = 0.38;
                    } else {
                      _speechRate = 0.45;
                    }
                  });
                  _tts.setSpeechRate(_speechRate);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.speed_rounded, size: 14, color: Color(0xFFFFB300)),
                      const SizedBox(width: 4),
                      Text(
                        _speechRate == 0.38
                            ? '0.8x'
                            : (_speechRate == 0.45 ? '1.0x' : '1.2x'),
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Instant Search Bar
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              style: GoogleFonts.inter(fontSize: 13, color: textColor),
              decoration: InputDecoration(
                hintText: 'Search stories, interview answers, idioms...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFFFFB300)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 🏷️ COMIC TAB BAR
  // ==========================================
  Widget _buildComicTabBar(bool isDark, Color cardBg, Color textColor) {
    return Container(
      height: 48,
      color: cardBg,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        physics: const BouncingScrollPhysics(),
        indicatorColor: const Color(0xFFFFFC00),
        indicatorWeight: 3.5,
        tabAlignment: TabAlignment.start,
        labelColor: textColor,
        unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: "🎧 Audio Library"),
          Tab(text: "🎓 Student & Campus"),
          Tab(text: "💼 Interview Vault"),
          Tab(text: "🌍 Real Dialogues"),
          Tab(text: "⚡ Smart Toolkit"),
        ],
      ),
    );
  }

  // ==========================================
  // 🔊 ACTIVE TTS AUDIO STRIP
  // ==========================================
  Widget _buildActiveAudioPlayerBar(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFC00),
        border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.graphic_eq_rounded, color: Colors.black, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Playing Audio Narration (Tap again to pause)...',
              style: GoogleFonts.outfit(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.stop_circle_rounded, color: Colors.black, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () async {
              await _tts.stop();
              setState(() {
                _isPlayingAudio = false;
                _currentlyPlayingId = '';
              });
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: 🎧 AUDIO STORIES & READING ROOM
  // ==========================================
  Widget _buildAudioLibraryTab(bool isDark, Color cardBg, Color textColor) {
    final stories = _getCuratedStories().where((s) {
      if (_searchQuery.isEmpty) return true;
      return s['title'].toString().toLowerCase().contains(_searchQuery) ||
          s['author'].toString().toLowerCase().contains(_searchQuery) ||
          s['summary'].toString().toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];
        final id = story['id'] as String;
        final isPlayingThis = _isPlayingAudio && _currentlyPlayingId == id;
        final isBookmarked = _bookmarkedIds.contains(id);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isPlayingThis ? const Color(0xFFFFFC00) : (isDark ? const Color(0xFF334155) : Colors.black),
              width: 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black,
                offset: const Offset(3.5, 3.5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Comic Tag Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: story['accentColor'] as Color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  border: const Border(bottom: BorderSide(color: Colors.black, width: 2)),
                ),
                child: Row(
                  children: [
                    Text(
                      story['categoryTag'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${story['readMinutes']} MIN READ',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                story['title'] as String,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'By ${story['author']}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            color: isBookmarked ? const Color(0xFFFFB300) : (isDark ? Colors.white54 : Colors.black54),
                          ),
                          onPressed: () => _toggleBookmark(id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      story['summary'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.45,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Action Buttons: Read Story & Listen
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openStoryReaderModal(story),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFF0F172A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.black, width: 1.5),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.chrome_reader_mode_outlined, size: 18),
                            label: Text(
                              'READ STORY',
                              style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () => _speakText(id, story['content'] as String),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPlayingThis ? const Color(0xFFFF2A85) : const Color(0xFFFFFC00),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Colors.black, width: 1.5),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          icon: Icon(
                            isPlayingThis ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: isPlayingThis ? Colors.white : Colors.black,
                            size: 20,
                          ),
                          label: Text(
                            isPlayingThis ? 'PAUSE' : 'LISTEN',
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: isPlayingThis ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 2: 🎓 STUDENT & CAMPUS SURVIVAL
  // ==========================================
  Widget _buildStudentSurvivalTab(bool isDark, Color cardBg, Color textColor) {
    final items = _getStudentSurvivalData().where((item) {
      if (_searchQuery.isEmpty) return true;
      return item['title'].toString().toLowerCase().contains(_searchQuery) ||
          item['situation'].toString().toLowerCase().contains(_searchQuery) ||
          item['tips'].toString().toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final id = item['id'] as String;
        final isPlayingThis = _isPlayingAudio && _currentlyPlayingId == id;
        final isBookmarked = _bookmarkedIds.contains(id);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : Colors.black,
              width: 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black,
                offset: const Offset(3.5, 3.5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: item['badgeColor'] as Color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  border: const Border(bottom: BorderSide(color: Colors.black, width: 2)),
                ),
                child: Row(
                  children: [
                    Icon(item['icon'] as IconData, size: 16, color: Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      item['category'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => _toggleBookmark(id),
                      child: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['situation'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Dialogues or Phrases List
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.format_quote_rounded, size: 16, color: Color(0xFFFFB300)),
                              const SizedBox(width: 6),
                              Text(
                                'Recommended Phrasing & Script:',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['script'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              height: 1.45,
                              color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Pro Tip Box
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_rounded, size: 18, color: Color(0xFFFFFC00)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pro Etiquette Tip: ${item['tips']}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _copyToClipboard(item['script'] as String, 'Phrazes'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          icon: const Icon(Icons.copy_rounded, size: 14),
                          label: Text(
                            'COPY SCRIPT',
                            style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () => _speakText(id, "${item['title']}. ${item['script']}"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPlayingThis ? const Color(0xFFFF2A85) : const Color(0xFFFFFC00),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.black, width: 1.2),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          icon: Icon(
                            isPlayingThis ? Icons.stop_rounded : Icons.volume_up_rounded,
                            size: 16,
                            color: isPlayingThis ? Colors.white : Colors.black,
                          ),
                          label: Text(
                            isPlayingThis ? 'STOP' : 'PRONOUNCE',
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: isPlayingThis ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 3: 💼 INTERVIEW & CAREER VAULT
  // ==========================================
  Widget _buildInterviewVaultTab(bool isDark, Color cardBg, Color textColor) {
    final questions = _getInterviewVaultData().where((q) {
      if (_searchQuery.isEmpty) return true;
      return q['question'].toString().toLowerCase().contains(_searchQuery) ||
          q['formula'].toString().toLowerCase().contains(_searchQuery) ||
          q['modelAnswer'].toString().toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final q = questions[index];
        final id = q['id'] as String;
        final isPlayingThis = _isPlayingAudio && _currentlyPlayingId == id;
        final isBookmarked = _bookmarkedIds.contains(id);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : Colors.black,
              width: 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black,
                offset: const Offset(3.5, 3.5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: q['tagColor'] as Color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  border: const Border(bottom: BorderSide(color: Colors.black, width: 2)),
                ),
                child: Row(
                  children: [
                    Text(
                      q['tag'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => _toggleBookmark(id),
                      child: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q['question'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Strategy Formula
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFFFC00), width: 1.2),
                      ),
                      child: Text(
                        '💡 Winning Strategy: ${q['formula']}',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Model Answer
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🎯 High-Scoring Model Answer:',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF00E676),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            q['modelAnswer'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              height: 1.45,
                              color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // What to avoid
                    Text(
                      '⚠️ Never say: ${q['avoid']}',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: const Color(0xFFFF5252),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _copyToClipboard(q['modelAnswer'] as String, 'Model answer'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          icon: const Icon(Icons.copy_rounded, size: 14),
                          label: Text(
                            'COPY ANSWER',
                            style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () => _speakText(id, "${q['question']}. ${q['modelAnswer']}"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPlayingThis ? const Color(0xFFFF2A85) : const Color(0xFFFFFC00),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.black, width: 1.2),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          icon: Icon(
                            isPlayingThis ? Icons.stop_rounded : Icons.record_voice_over_rounded,
                            size: 16,
                            color: isPlayingThis ? Colors.white : Colors.black,
                          ),
                          label: Text(
                            isPlayingThis ? 'STOP' : 'LISTEN TO ANSWER',
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: isPlayingThis ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 4: 🌍 REAL WORLD SITUATIONAL DIALOGUES
  // ==========================================
  Widget _buildEverydayDialoguesTab(bool isDark, Color cardBg, Color textColor) {
    final dialogues = _getEverydayDialoguesData().where((d) {
      if (_searchQuery.isEmpty) return true;
      return d['title'].toString().toLowerCase().contains(_searchQuery) ||
          d['scenario'].toString().toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
      itemCount: dialogues.length,
      itemBuilder: (context, index) {
        final d = dialogues[index];
        final id = d['id'] as String;
        final isPlayingThis = _isPlayingAudio && _currentlyPlayingId == id;
        final isBookmarked = _bookmarkedIds.contains(id);
        final lines = d['lines'] as List<Map<String, String>>;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : Colors.black,
              width: 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black,
                offset: const Offset(3.5, 3.5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: d['badgeColor'] as Color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  border: const Border(bottom: BorderSide(color: Colors.black, width: 2)),
                ),
                child: Row(
                  children: [
                    Text(
                      d['title'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => _toggleBookmark(id),
                      child: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d['scenario'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Script bubbles
                    ...lines.map((line) {
                      final speaker = line['speaker'] ?? '';
                      final text = line['text'] ?? '';
                      final isUser = speaker == 'You' || speaker == 'Passenger' || speaker == 'Customer' || speaker == 'Guest';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isUser ? const Color(0xFFFFFC00) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.black, width: 1),
                              ),
                              child: Text(
                                speaker,
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                text,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  height: 1.35,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    // Action Buttons
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            final fullConvo = lines.map((l) => "${l['speaker']}: ${l['text']}").join('\n');
                            _copyToClipboard(fullConvo, 'Dialogue script');
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          icon: const Icon(Icons.copy_rounded, size: 14),
                          label: Text(
                            'COPY SCRIPT',
                            style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            final fullSpeech = lines.map((l) => "${l['speaker']} says, ${l['text']}").join('. ');
                            _speakText(id, fullSpeech);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPlayingThis ? const Color(0xFFFF2A85) : const Color(0xFFFFFC00),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.black, width: 1.2),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          icon: Icon(
                            isPlayingThis ? Icons.stop_rounded : Icons.record_voice_over_rounded,
                            size: 16,
                            color: isPlayingThis ? Colors.white : Colors.black,
                          ),
                          label: Text(
                            isPlayingThis ? 'STOP' : 'PRACTICE CONVERSATION',
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: isPlayingThis ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 5: ⚡ SMART TOOLKIT, LEXICON & IDIOMS
  // ==========================================
  Widget _buildSmartToolkitTab(bool isDark, Color cardBg, Color textColor) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
      children: [
        // 1. LIVE DICTIONARY CARD
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : Colors.black,
              width: 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black,
                offset: const Offset(3.5, 3.5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Icon(Icons.spellcheck_rounded, color: Colors.black, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'LIVE ENGLISH DICTIONARY',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Instant phonetic pronunciation, word class & example sentences:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: _dictionaryInputController,
                        onSubmitted: _lookupDictionary,
                        style: GoogleFonts.inter(fontSize: 13, color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Type any word (e.g. articulate, resilient)...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                          prefixIcon: const Icon(Icons.search_rounded, size: 18),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoadingDictionary
                        ? null
                        : () => _lookupDictionary(_dictionaryInputController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFC00),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    child: _isLoadingDictionary
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : Text(
                            'LOOKUP',
                            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w900),
                          ),
                  ),
                ],
              ),
              if (_dictionaryResult != null) ...[
                const SizedBox(height: 14),
                _buildDictionaryResultCard(isDark, textColor),
              ],
              if (_dictionaryError != null) ...[
                const SizedBox(height: 10),
                Text(
                  _dictionaryError!,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.redAccent),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 2. POWER IDIOMS & PHRASAL VERBS STORE
        Text(
          '🔥 50+ ESSENTIAL ENGLISH IDIOMS & PHRASES',
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        ..._getIdiomsData().map((idiom) {
          final id = 'idiom_${idiom['phrase']}';
          final isPlayingThis = _isPlayingAudio && _currentlyPlayingId == id;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : Colors.black,
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black,
                  offset: const Offset(2.5, 2.5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: idiom['color'] as Color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 1.2),
                      ),
                      child: Text(
                        idiom['level'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        idiom['phrase'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isPlayingThis ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                        color: isPlayingThis ? const Color(0xFFFF2A85) : const Color(0xFFFFB300),
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _speakText(id, "${idiom['phrase']}. Meaning: ${idiom['meaning']}. Example: ${idiom['example']}"),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Meaning: ${idiom['meaning']}',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Example: "${idiom['example']}"',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),

        // 3. SILENT LETTERS & PRONUNCIATION PITFALLS
        Text(
          '🤫 SILENT LETTERS & ACCENT SECRETS',
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        ..._getSilentLettersData().map((s) {
          final id = 'silent_${s['rule']}';
          final isPlayingThis = _isPlayingAudio && _currentlyPlayingId == id;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : Colors.black,
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black,
                  offset: const Offset(2.5, 2.5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      s['rule'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFFB300),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        isPlayingThis ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                        color: isPlayingThis ? const Color(0xFFFF2A85) : textColor,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _speakText(id, "${s['rule']}. Words: ${s['words'].join(', ')}"),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  s['explanation'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (s['words'] as List<String>).map((w) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Text(
                        w,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // 📖 LIVE DICTIONARY CARD BUILDER
  // ==========================================
  Widget _buildDictionaryResultCard(bool isDark, Color textColor) {
    final word = _dictionaryResult?['word'] ?? '';
    final phonetic = _dictionaryResult?['phonetic'] ?? '';
    final meanings = (_dictionaryResult?['meanings'] as List?) ?? [];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                word.toString().toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 8),
              if (phonetic.isNotEmpty)
                Text(
                  phonetic,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF00E5FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _speakText('dict_$word', word),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                icon: const Icon(Icons.volume_up_rounded, size: 14),
                label: Text(
                  'PRONOUNCE',
                  style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...meanings.take(2).map((m) {
            final partOfSpeech = m['partOfSpeech'] ?? '';
            final defs = (m['definitions'] as List?) ?? [];
            final firstDef = defs.isNotEmpty ? defs.first : {};
            final definition = firstDef['definition'] ?? '';
            final example = firstDef['example'] ?? '';

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      partOfSpeech.toString().toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• $definition',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: isDark ? Colors.white70 : const Color(0xFF334155),
                      height: 1.35,
                    ),
                  ),
                  if (example.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2, left: 10),
                      child: Text(
                        'Example: "$example"',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // 📖 FULL STORY READER MODAL (TTS INCLUDED)
  // ==========================================
  void _openStoryReaderModal(Map<String, dynamic> story) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = story['id'] as String;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.black, width: 2.5),
          ),
          child: Column(
            children: [
              // Modal Top Grab Bar
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story['title'] as String,
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            'Author: ${story['author']} • ${story['readMinutes']} min read',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 24),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1.5),
              // Story Text Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    story['content'] as String,
                    style: GoogleFonts.merriweather(
                      fontSize: 15,
                      height: 1.75,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ),
              // Floating Bottom Audio Control in Modal
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  border: const Border(top: BorderSide(color: Colors.black, width: 1.5)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          _speakText(id, story['content'] as String);
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFC00),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.black, width: 1.5),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        icon: Icon(
                          _isPlayingAudio && _currentlyPlayingId == id
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.black,
                        ),
                        label: Text(
                          _isPlayingAudio && _currentlyPlayingId == id ? 'PAUSE AUDIO' : 'PLAY NARRATION',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w900),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded),
                        onPressed: () => _copyToClipboard(story['content'] as String, 'Full story'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // 📚 MASSIVE CURATED DATA REPOSITORIES
  // ==========================================
  List<Map<String, dynamic>> _getCuratedStories() {
    return [
      {
        'id': 'story_clockmaker',
        'title': 'The Clockmaker of Vienna',
        'author': 'Julian Vance',
        'categoryTag': 'INSPIRATION & PATIENCE',
        'accentColor': const Color(0xFFFFFC00),
        'readMinutes': 4,
        'summary':
            'A master craftsman explains why rushing through life destroys the delicate gears of joy and human connection.',
        'content': '''In a narrow cobblestone lane in Vienna, an elderly artisan named Herr Becker crafted mechanical clocks. His workshop smelled of aged cedarwood, brass shavings, and warm lamp oil.

One frosty morning, an impatient young merchant burst through the oak door. "Herr Becker!" the merchant exclaimed, tapping his gold pocket watch frantically. "I need the most accurate chronometer in the empire, and I need it finished by tomorrow evening. Name your fee; I have ships departing for the Orient!"

Herr Becker did not look up from his magnifying lens. With tweezers delicate as hummingbird feathers, he held a microscopic hairspring balance. "Tomorrow evening? Young gentleman, a fine clock is not assembled by speed. It is calibrated through silence."

"What does silence have to do with gears?" scoffed the young merchant.

"A pendulum," Becker answered softly, "cannot measure true time if the room is shaking with anxiety. When you force a gear before its teeth are polished, it grinds itself into dust within a year. Most men spend their entire lives rushing to save minutes, only to squander decades on hurried regrets."

The merchant paused. Looking around the quiet workshop, where dozens of clocks ticked in harmonic synchrony, his frantic pulse slowed for the very first time in months. "Teach me to listen," he whispered. And for three hours, the busy merchant sat quietly, learning the gentle rhythm of true patience.''',
      },
      {
        'id': 'story_midnight_train',
        'title': 'The Midnight Train to Edinburgh',
        'author': 'Eleanor Sterling',
        'categoryTag': 'MYSTERY & DIALOGUE',
        'accentColor': const Color(0xFF00E5FF),
        'readMinutes': 5,
        'summary':
            'Two strangers share a rain-swept railway carriage across the Scottish Highlands, uncovering an unexpected truth.',
        'content': '''The midnight sleeper rattled rhythmically against the iron rails as rain whipped the glass. Inside carriage number seven, Arthur closed his worn copy of Robert Louis Stevenson and looked across the mahogany table.

A woman in a charcoal woolen coat was gazing out into the black abyss of the Scottish countryside. Beside her rested an antique violin case, strapped shut with two brass buckles.

"Forgive the intrusion," Arthur began politely, offering a gentle smile. "Are you heading all the way north to Inverness, or disembarking at Edinburgh Waverley?"

The woman turned, her eyes keen and remarkably observant. "Waverley," she replied, her voice low and melodious. "I have an appointment at the Royal Lyceum Theatre at dawn."

"A musician, I presume?" Arthur nodded toward the leather case.

"Not quite," she said with a faint smirk. "This case once belonged to my grandfather. Inside rests neither violin nor bow, but three handwritten diaries from the winter of 1941."

Arthur straightened in his seat, his curiosity instantly piqued. "Family history, or historical evidence?"

"Both," she murmured, unlocking the left buckle with a soft click. "They contain the lost letters between two codebreakers who solved an impossible riddle, yet chose never to speak of it until now."''',
      },
      {
        'id': 'story_fisherman',
        'title': 'The Fisherman and the Banker',
        'author': 'Adapted Global Parable',
        'categoryTag': 'LIFE PHILOSOPHY',
        'accentColor': const Color(0xFF00E676),
        'readMinutes': 3,
        'summary':
            'An investment executive tries to teach a humble coastal fisherman about wealth, only to receive a life-changing lesson.',
        'content': '''An investment banker was standing on the sunlit pier of a small Greek village when a modest wooden boat docked. Inside lay several glistening yellowfin tuna.

"Impressive fish," the banker remarked in English. "How long did it take you to catch them?"

"Only a short while, Sir," the fisherman replied with a warm grin.

"Why didn't you stay out longer to catch twice as many?" asked the banker.

"Because this is more than enough for my family," the fisherman said calmly. "I sleep late, fish for an hour, play with my children, take an afternoon siesta with my wife, and stroll into the village square each evening to sip coffee and strum my guitar with my lifelong friends. I have a full, peaceful life."

The banker laughed arrogantly. "Look here, I hold a master's degree from Harvard. I can help you! If you spend eight hours fishing every day, you could buy a second boat, then a fleet of trawlers, then open your own cannery. Within twenty years, you could list your company on the stock exchange and make tens of millions!"

The fisherman smiled gently. "And after that, Sir?"

"After that, you retire! You can move to a small coastal village, sleep late, fish for an hour, play with your grandchildren, take siestas with your wife, and strum your guitar with friends in the evening."

The fisherman chuckled quietly. "Isn't that exactly what I am doing right now?"''',
      },
      {
        'id': 'story_harnessed_wind',
        'title': 'The Boy Who Captured the Sky',
        'author': 'True Biographical Tribute',
        'categoryTag': 'SCIENCE & COURAGE',
        'accentColor': const Color(0xFFFF2A85),
        'readMinutes': 4,
        'summary':
            'When drought threatened his farming village, fourteen-year-old William built a functioning windmill from scraps.',
        'content': '''The dry season of 2001 struck the African plains with merciless cruelty. Crops withered into brittle amber husks, and the evening wells dried into cracked clay.

Fourteen-year-old William could no longer afford the school fees. Instead of surrendering to despair, he spent every single morning in the small village library, reading English textbooks on physics and electromagnetism.

One faded blue manual contained a diagram of a windmill. The caption read: "Wind turbines generate clean electricity to pump water and power machinery."

William closed the book and marched straight to the village scrapyard.

For two months, neighbors laughed as William collected rusted bicycle frames, melted plastic pipes, and broken tractor fans. "The boy has lost his sanity," elders gossiped.

Undeterred, William climbed an eighteen-foot eucalyptus tower he had lashed together with twine. He mounted the homemade dynamo and wired it down to a small automobile bulb.

As the afternoon trade winds gusted across the dry valley, the blades began to spin. Faster and faster they whirled until the small bulb flared into brilliant, blinding illumination! The crowd below gasped in stunned silence. From discarded junk and stubborn curiosity, a boy had captured the sky.''',
      },
    ];
  }

  List<Map<String, dynamic>> _getStudentSurvivalData() {
    return [
      {
        'id': 'stud_ask_doubt',
        'title': 'Asking Doubts Politely in Class',
        'category': 'CLASSROOM DISCUSSIONS',
        'icon': Icons.school_rounded,
        'badgeColor': const Color(0xFFFFFC00),
        'situation': 'When the teacher is moving fast and you need clarification without sounding rude or defensive.',
        'script': '''• "Excuse me, Professor. Could you please elaborate slightly on that last point regarding [Topic]?"
• "Pardon my interruption, Sir/Ma'am. I didn't quite catch the connection between step 2 and step 3. Could you kindly clarify?"
• "If I understood correctly, does this imply that [Your Interpretation]? Or is there another exception?"''',
        'tips': 'Never say "You are going too fast" or "I don’t understand you." Instead, put the focus on your understanding: "Could you kindly clarify?"',
      },
      {
        'id': 'stud_email_extension',
        'title': 'Emailing a Professor for an Assignment Extension',
        'category': 'PROFESSIONAL EMAILS',
        'icon': Icons.mail_outline_rounded,
        'badgeColor': const Color(0xFF00E5FF),
        'situation': 'When unforeseen illness or family circumstances prevent you from meeting a paper deadline.',
        'script': '''Subject: Extension Request: [Course Code] - [Your Full Name] - Roll No: [123]

Dear Professor [Last Name],

I hope this email finds you well.

I am writing to respectfully request a short two-day extension for the upcoming assignment on [Assignment Name], originally due on [Date]. Due to an unexpected medical emergency, I have fallen slightly behind on my research.

I have already drafted the outline and completed 60% of the analysis. An extension until [New Proposed Date] would allow me to finalize the work to the rigorous standard expected in your class.

Thank you very much for your understanding and consideration.

Sincerely,
[Your Name]''',
        'tips': 'Always mention how much work you have already completed. Never write an extension email an hour before the deadline.',
      },
      {
        'id': 'stud_exam_structuring',
        'title': 'The PEEL Formula for High-Scoring Exam Essays',
        'category': 'EXAM MASTERY',
        'icon': Icons.menu_book_rounded,
        'badgeColor': const Color(0xFF00E676),
        'situation': 'How to structure descriptive answers in university and board examinations to score top grades.',
        'script': '''• P - Point: State your main argument directly in the very first sentence.
  Example: "Rapid urbanization has substantially accelerated climate degradation in coastal cities."
• E - Explanation: Elaborate on why and how this occurs.
  Use linkers: "Specifically...", "This phenomenon is largely attributable to...", "Consequently..."
• E - Evidence / Example: Provide a concrete fact, study, or historical precedent.
  Use linkers: "For instance...", "A case in point is...", "Empirical studies demonstrate..."
• L - Link: Connect your paragraph back to the overall thesis of the question.
  Use linkers: "Hence, it is evident that...", "In essence, this highlights the critical necessity for..."''',
        'tips': 'Examiners skim through hundreds of papers. Strong topic sentences and clear transitional markers guarantee maximum marks.',
      },
      {
        'id': 'stud_viva_defense',
        'title': 'Handling Oral Exams & Project Vivas',
        'category': 'ORAL DEFENSE',
        'icon': Icons.record_voice_over_rounded,
        'badgeColor': const Color(0xFFFF2A85),
        'situation': 'When the viva panel asks an unexpected question and you need a moment to organize your thoughts.',
        'script': '''• "That is an intriguing question, Professor. Allow me a brief moment to structure my response."
• "While our primary dataset focused on [Factor A], looking at it from [Factor B] is a compelling perspective because..."
• "If I may respectfully add to that, the empirical results we obtained demonstrated..."
• "I don't have that specific statistic at my fingertips right now, but I would be glad to look into it and follow up."''',
        'tips': 'Never bluff or make up facts in a viva. If you do not know, calmly acknowledge it and explain what related principles you do know.',
      },
    ];
  }

  List<Map<String, dynamic>> _getInterviewVaultData() {
    return [
      {
        'id': 'job_tell_me_about_yourself',
        'question': '1. "Tell me about yourself."',
        'tag': '🔥 MOST ASKED OPENER',
        'tagColor': const Color(0xFFFFFC00),
        'formula': 'Present (Current role & specialty) ➔ Past (2 big achievements) ➔ Future (Why this company excites you).',
        'modelAnswer': '''"Certainly! For the past three years, I have been working as a Software Engineer specializing in scalable Flutter mobile architectures and real-time backend integrations.

In my recent position, I spearheaded the complete refactoring of our user engagement system, which reduced app crash rates by 40% and boosted daily active sessions by over 25%.

What truly excites me about this opportunity at your organization is your dedication to seamless user experiences. I am eager to leverage my engineering background and collaborative problem-solving skills to help accelerate your upcoming product roadmap."''',
        'avoid': 'Do not narrate your life story starting from elementary school or recount your entire resume line by line.',
      },
      {
        'id': 'job_greatest_weakness',
        'question': '2. "What is your greatest weakness?"',
        'tag': '🎯 HIGH-STAKES PSYCHOLOGY',
        'tagColor': const Color(0xFF00E5FF),
        'formula': 'Pick a real, non-fatal professional skill + Explain the proactive steps you are taking to master it.',
        'modelAnswer': '''"In the past, I sometimes struggled with delegating tasks because I wanted to ensure every tiny detail met my personal standards. However, as projects grew in scope, I realized this created unnecessary bottlenecks.

To address this, I started implementing clear milestone checklists and conducting weekly asynchronous alignment syncs. This has allowed me to empower team members while maintaining exceptional quality standards, making our entire delivery cycle far more efficient."''',
        'avoid': 'Never say "I have no weaknesses" (arrogant) or "I am too much of a perfectionist" (cliché & dishonest).',
      },
      {
        'id': 'job_why_hire_you',
        'question': '3. "Why should we hire you over other candidates?"',
        'tag': '⚡ VALUE TRIFECTA',
        'tagColor': const Color(0xFF00E676),
        'formula': 'Direct Skills Match + Cultural / Team Alignment + Proven Track Record of delivering bottom-line results.',
        'modelAnswer': '''"You should hire me because I offer a unique combination of technical depth and customer-centric problem solving. Looking at your current expansion, you need someone who can hit the ground running with minimal hand-holding.

Throughout my career, I have consistently demonstrated the ability to bridge technical requirements with business goals, having previously delivered three enterprise-grade projects ahead of deadline. I bring that same disciplined work ethic and enthusiasm to your team."''',
        'avoid': 'Never disparage other candidates or say "Because I really need a job."',
      },
      {
        'id': 'job_star_conflict',
        'question': '4. "Describe a workplace disagreement and how you resolved it."',
        'tag': '🤝 S.T.A.R. METHOD',
        'tagColor': const Color(0xFFFF2A85),
        'formula': 'Situation (Context) ➔ Task (The challenge) ➔ Action (Your calm diplomatic step) ➔ Result (Positive outcome).',
        'modelAnswer': '''"During a critical product launch last quarter, our design lead and I had differing opinions regarding the navigation layout. The design team preferred an aesthetic carousel, while data showed users preferred an immediate grid.

Rather than debate opinions, I suggested conducting a rapid A/B test with fifty internal users over forty-eight hours. The data clearly showed that combining a simplified header with a grid reduced drop-off rates by 18%.

By grounding our discussion in objective data rather than personal pride, we reached consensus swiftly and delivered an award-winning feature."''',
        'avoid': 'Never blame a manager or coworker. Never frame yourself as the lone hero fighting bad colleagues.',
      },
    ];
  }

  List<Map<String, dynamic>> _getEverydayDialoguesData() {
    return [
      {
        'id': 'dial_airport_immigration',
        'title': '✈️ International Airport Immigration',
        'scenario': 'Arriving at border control in London Heathrow or New York JFK.',
        'badgeColor': const Color(0xFFFFFC00),
        'lines': [
          {'speaker': 'Officer', 'text': 'Good morning. Passports and landing cards, please.'},
          {'speaker': 'You', 'text': 'Good morning, Officer. Here they are.'},
          {'speaker': 'Officer', 'text': 'What is the primary purpose of your visit?'},
          {'speaker': 'You', 'text': 'I am here for a ten-day vacation and to visit family.'},
          {'speaker': 'Officer', 'text': 'Where will you be staying during your time here?'},
          {'speaker': 'You', 'text': 'At the Kensington Grand Hotel in central London. Here is my confirmed reservation.'},
          {'speaker': 'Officer', 'text': 'Do you have a return ticket?'},
          {'speaker': 'You', 'text': 'Yes, Sir. My return flight departs on the twenty-fourth.'},
          {'speaker': 'Officer', 'text': 'Everything appears in order. Welcome, and enjoy your stay!'},
        ],
      },
      {
        'id': 'dial_restaurant_order',
        'title': '🍽️ Dining at a Fine Restaurant',
        'scenario': 'Asking for recommendations, dietary preferences, and bill splitting.',
        'badgeColor': const Color(0xFF00E5FF),
        'lines': [
          {'speaker': 'Server', 'text': 'Good evening! Welcome to Bistro Lumière. Are you ready to order, or do you need a few more minutes?'},
          {'speaker': 'You', 'text': 'Good evening! We are almost ready. What would you recommend for the chef’s special tonight?'},
          {'speaker': 'Server', 'text': 'The pan-seared sea bass with saffron risotto is exceptional today.'},
          {'speaker': 'You', 'text': 'That sounds delightful! Could you please ensure the dressing is served on the side, as my colleague has a slight dairy allergy?'},
          {'speaker': 'Server', 'text': 'Certainly, I will notify the kitchen immediately.'},
          {'speaker': 'You', 'text': 'Wonderful. And could we also please have a pitcher of sparkling water for the table?'},
        ],
      },
      {
        'id': 'dial_doctor_clinic',
        'title': '🩺 Consulting a Doctor at a Clinic',
        'scenario': 'Accurately describing physical symptoms, onset, and pain severity.',
        'badgeColor': const Color(0xFF00E676),
        'lines': [
          {'speaker': 'Doctor', 'text': 'Hello! Please take a seat. What seems to be troubling you today?'},
          {'speaker': 'You', 'text': 'Hello Doctor. I have had a severe throbbing headache since Tuesday morning, accompanied by mild dizziness.'},
          {'speaker': 'Doctor', 'text': 'Are you experiencing any nausea, sensitivity to bright light, or fever?'},
          {'speaker': 'You', 'text': 'Yes, bright sunlight seems to worsen the pain, though I haven’t had a high temperature.'},
          {'speaker': 'Doctor', 'text': 'Have you taken any medication over the counter?'},
          {'speaker': 'You', 'text': 'I took 500mg of paracetamol yesterday evening, but it provided only temporary relief.'},
          {'speaker': 'Doctor', 'text': 'Understood. Let me examine your blood pressure and pupillary reflexes.'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getIdiomsData() {
    return [
      {
        'phrase': 'Bite the bullet',
        'meaning': 'To face a painful or difficult situation with courage and fortitude.',
        'example': 'I hate having difficult conversations about budget cuts, but I will have to bite the bullet tomorrow.',
        'level': 'INTERMEDIATE',
        'color': const Color(0xFFFFFC00),
      },
      {
        'phrase': 'Call it a day',
        'meaning': 'To stop working on something for the rest of the day.',
        'example': 'We have solved four major bugs today; let us call it a day and get some rest.',
        'level': 'BEGINNER',
        'color': const Color(0xFF00E5FF),
      },
      {
        'phrase': 'Hit the nail on the head',
        'meaning': 'To describe exactly what is causing a situation or problem.',
        'example': 'Sarah hit the nail on the head when she remarked that our onboarding process was overly complex.',
        'level': 'ESSENTIAL',
        'color': const Color(0xFF00E676),
      },
      {
        'phrase': 'Burn the midnight oil',
        'meaning': 'To work late into the night or early hours of the morning.',
        'example': 'The engineering team burned the midnight oil to ensure the server update went live smoothly.',
        'level': 'ADVANCED',
        'color': const Color(0xFFFF2A85),
      },
      {
        'phrase': 'Under the weather',
        'meaning': 'Feeling slightly unwell, sick, or exhausted.',
        'example': 'He did not attend the board meeting this morning because he was feeling a bit under the weather.',
        'level': 'HIGH FREQUENCY',
        'color': const Color(0xFFFFB300),
      },
      {
        'phrase': 'Break the ice',
        'meaning': 'To do or say something that relieves tension and makes people feel comfortable.',
        'example': 'The facilitator started the workshop with a humorous quiz to break the ice among international delegates.',
        'level': 'ESSENTIAL',
        'color': const Color(0xFF00E5FF),
      },
      {
        'phrase': 'See eye to eye',
        'meaning': 'To agree fully with someone on a matter.',
        'example': 'Although my co-founder and I do not always see eye to eye on marketing, we share the same core values.',
        'level': 'PROFESSIONAL',
        'color': const Color(0xFF00E676),
      },
    ];
  }

  List<Map<String, dynamic>> _getSilentLettersData() {
    return [
      {
        'rule': 'Silent "B"',
        'explanation': 'The letter "B" is usually silent when followed by "T" or preceded by "M" at the end of a syllable.',
        'words': ['Doubt', 'Subtle', 'Debt', 'Climb', 'Thumb', 'Tomb', 'Comb'],
      },
      {
        'rule': 'Silent "K"',
        'explanation': 'The letter "K" is never pronounced when it comes before "N" at the beginning of a word.',
        'words': ['Knight', 'Knock', 'Knee', 'Knowledge', 'Knife', 'Knot'],
      },
      {
        'rule': 'Silent "S"',
        'explanation': 'The letter "S" is silent in several historical French-influenced English words.',
        'words': ['Island', 'Isle', 'Aisle', 'Debris', 'Viscount'],
      },
      {
        'rule': 'Silent "P"',
        'explanation': 'The letter "P" is silent in Greek prefixes starting with "PS", "PN", and "PT".',
        'words': ['Psychology', 'Pneumonia', 'Psychiatrist', 'Receipt', 'Pterodactyl'],
      },
      {
        'rule': 'Silent "L"',
        'explanation': 'The letter "L" is silent after vowels "A", "O", and "U" before "K", "M", "F", and "D".',
        'words': ['Half', 'Calf', 'Salmon', 'Talk', 'Walk', 'Should', 'Could'],
      },
    ];
  }
}
