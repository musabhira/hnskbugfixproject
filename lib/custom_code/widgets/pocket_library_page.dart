import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/widgets/ai_prompt_service.dart';

class BookItem {
  final String id;
  final String title;
  final String author;
  final String category; // 'Classic Literature', 'Short Stories', 'Wisdom & Philosophy', 'Science & Tech'
  final String coverColor;
  final String summary;
  final int readingTimeMinutes;
  final List<BookChapter> chapters;

  const BookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.coverColor,
    required this.summary,
    required this.readingTimeMinutes,
    required this.chapters,
  });
}

class BookChapter {
  final String chapterTitle;
  final String content;

  const BookChapter({
    required this.chapterTitle,
    required this.content,
  });
}

class PocketLibraryPage extends StatefulWidget {
  const PocketLibraryPage({super.key});

  @override
  State<PocketLibraryPage> createState() => _PocketLibraryPageState();
}

class _PocketLibraryPageState extends State<PocketLibraryPage> {
  final FlutterTts _flutterTts = FlutterTts();
  String _selectedCategory = 'All';
  int _readStreakDays = 3;
  int _xpPoints = 120;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Short Stories',
    'Classic Literature',
    'Wisdom & Mindset',
    'Infotainment & Science',
  ];

  final List<BookItem> _books = [
    BookItem(
      id: 'sherlock_holmes_1',
      title: 'A Scandal in Bohemia',
      author: 'Arthur Conan Doyle',
      category: 'Classic Literature',
      coverColor: '#1E293B',
      summary: 'To Sherlock Holmes she is always THE woman. A classic mystery of wit and observation in Victorian London.',
      readingTimeMinutes: 12,
      chapters: [
        BookChapter(
          chapterTitle: 'Chapter I: The Bohemian Mystery',
          content: '''To Sherlock Holmes she is always THE woman. I have seldom heard him mention her under any other name. In his eyes she eclipses and predominates the whole of her sex. It was not that he felt any emotion akin to love for Irene Adler. All emotions, and that one particularly, were abhorrent to his cold, precise but admirably balanced mind. He was, I take it, the most perfect reasoning and observing machine that the world has seen.

One night—it was on the twentieth of March, 1888—I was returning from a journey to a patient, for I had now returned to civil practice, when my way led me through Baker Street. As I passed the well-remembered door, which must always be associated in my mind with my wooing, and with the dark incidents of the Study in Scarlet, I was seized with a keen desire to see Holmes again, and to know how he was employing his extraordinary powers. His rooms were brilliantly lit, and, even as I looked up, I saw his tall, spare figure pass twice in a dark silhouette against the blind. He was pacing the room swiftly, eagerly, with his head sunk upon his chest and his hands clasped behind him. To me, who knew his every mood and habit, his attitude and manner told their own story. He was at work again. He had risen out of his drug-created dreams and was hot upon the scent of some new problem.''',
        ),
      ],
    ),
    BookItem(
      id: 'the_art_of_war',
      title: 'The Art of War',
      author: 'Sun Tzu',
      category: 'Wisdom & Mindset',
      coverColor: '#7C2D12',
      summary: 'Timeless strategic philosophy on discipline, victory without conflict, and masterclass tactical psychology.',
      readingTimeMinutes: 15,
      chapters: [
        BookChapter(
          chapterTitle: 'Chapter I: Laying Plans',
          content: '''Sun Tzu said: The art of war is of vital importance to the State. It is a matter of life and death, a road either to safety or to ruin. Hence it is a subject of inquiry which can on no account be neglected.

The art of war, then, is governed by five constant factors, to be taken into account in one's deliberations, when seeking to determine the conditions obtaining in the field. These are: The Moral Law; Heaven; Earth; The Commander; Method and discipline.

The Moral Law causes the people to be in complete accord with their ruler, so that they will follow him regardless of their lives, undismayed by any danger.

Heaven signifies night and day, cold and heat, times and seasons. Earth comprises distances, great and small; danger and security; open ground and narrow passes; the chances of life and death.

The Commander stands for the virtues of wisdom, sincerely, benevolence, courage and strictness.

All warfare is based on deception. Hence, when able to attack, we must seem unable; when using our forces, we must seem inactive; when we are near, we must make the enemy believe we are far away; when far away, we must make him believe we are near.''',
        ),
      ],
    ),
    BookItem(
      id: 'aesop_fables',
      title: 'The Ant and the Grasshopper & Tales',
      author: 'Aesop',
      category: 'Short Stories',
      coverColor: '#065F46',
      summary: 'Simple, eloquent moral tales crafted in ancient Greece to expand narrative vocabulary and wisdom.',
      readingTimeMinutes: 8,
      chapters: [
        BookChapter(
          chapterTitle: 'The Ant and the Grasshopper',
          content: '''In a field one summer's day a Grasshopper was hopping about, chirping and singing to its heart's content. An Ant passed by, bearing along with great toil an ear of corn he was taking to the nest.

"Why not come and chat with me," said the Grasshopper, "instead of toiling and moiling in that way?"

"I am helping to lay up food for the winter," said the Ant, "and recommend you to do the same."

"Why bother about winter?" said the Grasshopper; "we have got plenty of food at present."

But the Ant went on its way and continued its toil. When the winter came the Grasshopper had no food and found itself dying of hunger, while it saw the ants distributing every day corn and grain from the stores they had collected in the summer. Then the Grasshopper knew: It is best to prepare for days of need.''',
        ),
      ],
    ),
    BookItem(
      id: 'cosmos_curiosity',
      title: 'Voyage to the Stars',
      author: 'Pocket Mates Science Desk',
      category: 'Infotainment & Science',
      coverColor: '#312E81',
      summary: 'Explore the mysteries of black holes, quantum physics, and interstellar travel in simple conversational English.',
      readingTimeMinutes: 10,
      chapters: [
        BookChapter(
          chapterTitle: 'The Edge of Spacetime',
          content: '''Light takes eight minutes and twenty seconds to travel from the radiant core of the Sun to your eyes on Earth. When you look upward into the starlit night, you are not observing the universe as it exists right now; you are peering into the deep corridors of the past.

A black hole is one of the most enigmatic phenomena in astrophysics. It is a region of spacetime where gravity is so intensely concentrated that nothing—no particles or even electromagnetic radiation such as light—can escape from within its event horizon.

Albert Einstein’s theory of general relativity predicted that a sufficiently compact mass can deform spacetime to form such a cosmic sinkhole. Understanding black holes teaches us the sublime grammar of nature: how matter, energy, time, and space dance in harmonious equations across the cosmos.''',
        ),
      ],
    ),
    BookItem(
      id: 'meditations_marcus',
      title: 'Meditations for Daily Focus',
      author: 'Marcus Aurelius',
      category: 'Wisdom & Mindset',
      coverColor: '#831843',
      summary: 'Daily Stoic meditations for inner peace, emotional resilience, and clear communication in everyday life.',
      readingTimeMinutes: 14,
      chapters: [
        BookChapter(
          chapterTitle: 'Book II: On Clarity & Purpose',
          content: '''When you wake up in the morning, tell yourself: the people I deal with today will be meddling, ungrateful, arrogant, dishonest, jealous, and surly. They are like this because they cannot distinguish good from evil. But I have seen the beauty of good, and the ugliness of evil, and have recognized that the wrongdoer has a nature related to my own.

None of them can hurt me. No one can implicate me in ugliness. Nor can I feel angry at my kin, or hate him. We were made to work together like feet, like hands, like the rows of the upper and lower teeth. To obstruct each other is against nature.

Waste no more time arguing about what a good person should be. Be one.''',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.48);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _readStreakDays = prefs.getInt('pocket_reading_streak') ?? 3;
      _xpPoints = prefs.getInt('english_hub_points') ?? 120;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredBooks = _books.where((b) {
      final matchesCat = _selectedCategory == 'All' || b.category == _selectedCategory;
      final matchesSearch = _searchController.text.isEmpty ||
          b.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          b.author.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF070B0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B141B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_stories_rounded, color: Color(0xFFFFFC00), size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pocket Library & Infotainment',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Free Public Classics • Word-Tap Speech • English Fluency',
                  style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10.5),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Goal & Streak Banner
            _buildReadingDashboardBanner(),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF121B22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search books, stories, science articles...',
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: Colors.white54, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // Category Chips
            SizedBox(
              height: 46,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat, style: GoogleFonts.outfit(color: isSelected ? Colors.black : Colors.white70, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFFFC00),
                    backgroundColor: const Color(0xFF121B22),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? const Color(0xFFFFFC00) : Colors.white10)),
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = cat);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Book Cards List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredBooks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
                  return _buildBookCard(book);
                },
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingDashboardBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF818CF8).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.bolt_rounded, color: Color(0xFFFFFC00), size: 30),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Reading Streak: $_readStreakDays Days 🔥',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Read 10 mins daily to master English vocabulary & earn +15 XP',
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFC00),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+$_xpPoints XP',
              style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(BookItem book) {
    return InkWell(
      onTap: () => _openReader(book),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF121B22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stylized Book Spine Cover
            Container(
              width: 72,
              height: 100,
              decoration: BoxDecoration(
                color: Color(int.parse(book.coverColor.replaceAll('#', '0xFF'))),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.bookmark_added_rounded, color: Color(0xFFFFFC00), size: 16),
                  Text(
                    book.title,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          book.category,
                          style: GoogleFonts.outfit(color: const Color(0xFFFFFC00), fontSize: 10.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: Colors.white38, size: 13),
                          const SizedBox(width: 4),
                          Text('${book.readingTimeMinutes} min', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.title,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'by ${book.author}',
                    style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.summary,
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openReader(BookItem book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookReaderView(book: book),
      ),
    );
  }
}

class BookReaderView extends StatefulWidget {
  final BookItem book;

  const BookReaderView({super.key, required this.book});

  @override
  State<BookReaderView> createState() => _BookReaderViewState();
}

class _BookReaderViewState extends State<BookReaderView> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlayingAudio = false;
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.46);
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlayingAudio = false);
    });
  }

  void _toggleAudioSpeech(String text) async {
    if (_isPlayingAudio) {
      await _flutterTts.stop();
      setState(() => _isPlayingAudio = false);
    } else {
      setState(() => _isPlayingAudio = true);
      await _flutterTts.speak(text);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  void _lookupWordMeaning(String word) async {
    HapticFeedback.lightImpact();
    final cleanWord = word.replaceAll(RegExp(r'[^\w\s]'), '').trim();
    if (cleanWord.isEmpty) return;

    // Speak the word
    await _flutterTts.speak(cleanWord);

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121B22),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cleanWord,
                    style: GoogleFonts.outfit(color: const Color(0xFFFFFC00), fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFFC00), size: 28),
                    onPressed: () => _flutterTts.speak(cleanWord),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              FutureBuilder<AIResponse>(
                future: AIService().generateText(
                  prompt: 'Give a quick 1-sentence dictionary definition, part of speech, and one simple example sentence for the English word: "$cleanWord". Output only clean text with no markdown.',
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFFFFFC00))),
                    );
                  }
                  final def = snapshot.data?.data ?? 'A fundamental English word used for expression and communication.';
                  return Text(
                    def,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, height: 1.4),
                  );
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFC00),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.bookmark_add_rounded),
                  label: const Text('Save to My Vocabulary Vault', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Saved "$cleanWord" to Vocabulary Vault! 🌟'), backgroundColor: const Color(0xFF10B981)),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chapter = widget.book.chapters.first;

    return Scaffold(
      backgroundColor: const Color(0xFF070B0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B141B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.book.title,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isPlayingAudio ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
              color: const Color(0xFFFFFC00),
              size: 28,
            ),
            tooltip: _isPlayingAudio ? 'Pause Narration' : 'Listen with Audio',
            onPressed: () => _toggleAudioSpeech(chapter.content),
          ),
          IconButton(
            icon: const Icon(Icons.format_size_rounded, color: Colors.white70),
            onPressed: () {
              setState(() {
                _fontSize = (_fontSize >= 20.0) ? 14.0 : _fontSize + 2.0;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chapter Title
            Text(
              chapter.chapterTitle,
              style: GoogleFonts.outfit(color: const Color(0xFFFFFC00), fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              '💡 Tip: Tap any word below to hear spoken pronunciation & instant definition!',
              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11.5),
            ),
            const Divider(color: Colors.white12, height: 28),

            // Interactive Clickable Words Reader
            Wrap(
              spacing: 4,
              runSpacing: 6,
              children: chapter.content.split(' ').map((word) {
                return InkWell(
                  onTap: () => _lookupWordMeaning(word),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                    child: Text(
                      word,
                      style: GoogleFonts.outfit(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: _fontSize,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 40),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFC00),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Complete Chapter (+15 XP)', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  int pts = prefs.getInt('english_hub_points') ?? 0;
                  await prefs.setInt('english_hub_points', pts + 15);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('🎉 Chapter completed! +15 English XP awarded!'), backgroundColor: Color(0xFF10B981)),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
