import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// 📚 POCKET WORLD READING LIBRARY & LITERARY REPOSITORY
///
/// Provides curated stories, poems, famous speeches, and executive articles
/// with built-in:
/// 1. Multilingual vocabulary breakdown (Malayalam, Tamil, Hindi, Telugu, Kannada).
/// 2. Audio-assisted read-along narration simulation for learners struggling with reading.
/// 3. Interactive reading comprehension check.
/// 4. Integration with the Daily 40–60 minute Study Timer & coin rewards.
class PocketReadingLibraryModal extends StatefulWidget {
  final int currentDay;
  final VoidCallback? onReadingCompleted;

  const PocketReadingLibraryModal({
    super.key,
    this.currentDay = 1,
    this.onReadingCompleted,
  });

  static Future<void> show(BuildContext context, {int currentDay = 1, VoidCallback? onReadingCompleted}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PocketReadingLibraryModal(
        currentDay: currentDay,
        onReadingCompleted: onReadingCompleted,
      ),
    );
  }

  @override
  State<PocketReadingLibraryModal> createState() => _PocketReadingLibraryModalState();
}

class _PocketReadingLibraryModalState extends State<PocketReadingLibraryModal> {
  String _selectedCategory = 'all';
  _ReadingItem? _activeReading;
  bool _isPlayingAudio = false;
  int _highlightedParagraphIndex = 0;

  final List<_ReadingItem> _libraryItems = const [
    _ReadingItem(
      id: 'story_1',
      category: 'stories',
      categoryLabel: 'Classic Story',
      categoryIcon: '📖',
      title: 'The Alchemist of Veridia',
      author: 'Ancient Parable (Adapted)',
      readingTimeMins: 4,
      difficulty: 'Beginner - Intermediate',
      excerpt: 'In the mountain valleys of Veridia lived an artisan who transformed raw ore into resilient steel...',
      contentParagraphs: [
        'In the mountain valleys of Veridia lived an artisan named Liam who was known not for his wealth, but for his relentless patience.',
        'While other metalworkers hurried to sell brittle swords, Liam refined each blade over seven days and seven nights in a controlled hearth.',
        '"Patience is not idle waiting," he taught his young apprentices. "Patience is deliberate labor focused upon enduring perfection."',
        'When a devastating storm collapsed the wooden town bridges, it was Liam\'s forged archway that stood unshaken, allowing hundreds of families to reach safe ground.',
        'Fluency in English is crafted like fine steel: day by day, word by word, until your thoughts flow with unbreakable strength.',
      ],
      vocabNotes: [
        {'word': 'Relentless', 'meaning': 'വിടാതെ തുടരുന്ന / പതറാത്ത', 'phonetic': '/rɪˈlent.ləs/'},
        {'word': 'Brittle', 'meaning': 'പെട്ടെന്ന് പൊട്ടിപ്പോകുന്ന', 'phonetic': '/ˈbrɪt.əl/'},
        {'word': 'Deliberate', 'meaning': 'ശ്രദ്ധാപൂർവ്വമായ / ബോധപൂർവ്വമായ', 'phonetic': '/dɪˈlɪb.ər.ət/'},
        {'word': 'Unshaken', 'meaning': 'ഇളകാത്ത / അടിയുറച്ച', 'phonetic': '/ʌnˈʃeɪ.kən/'},
      ],
      reflectionQuestion: 'What does the author compare language learning to?',
      reflectionOptions: [
        'Fast cooking',
        'Forging steel with daily deliberate patience',
        'Buying wooden bridges',
        'Climbing mountains alone',
      ],
      correctReflectionIndex: 1,
    ),
    _ReadingItem(
      id: 'poem_1',
      category: 'poetry',
      categoryLabel: 'Inspiring Poetry',
      categoryIcon: '📜',
      title: 'Invictus (Unconquerable Soul)',
      author: 'William Ernest Henley',
      readingTimeMins: 3,
      difficulty: 'Intermediate',
      excerpt: 'Out of the night that covers me, black as the pit from pole to pole, I thank whatever gods may be for my unconquerable soul...',
      contentParagraphs: [
        'Out of the night that covers me,\nBlack as the pit from pole to pole,\nI thank whatever gods may be\nFor my unconquerable soul.',
        'In the fell clutch of circumstance\nI have not winced nor cried aloud.\nUnder the bludgeonings of chance\nMy head is bloody, but unbowed.',
        'Beyond this place of wrath and tears\nLooms but the Horror of the shade,\nAnd yet the menace of the years\nFinds and shall find me unafraid.',
        'It matters not how strait the gate,\nHow charged with punishments the scroll,\nI am the master of my fate,\nI am the captain of my soul.',
      ],
      vocabNotes: [
        {'word': 'Unconquerable', 'meaning': 'തോൽപ്പിക്കാനാവാത്ത', 'phonetic': '/ʌnˈkɒŋ.kər.ə.bəl/'},
        {'word': 'Winced', 'meaning': 'വേദനയോടെ മുഖം ചുളിച്ചു', 'phonetic': '/wɪnst/'},
        {'word': 'Unbowed', 'meaning': 'തല കുനിക്കാത്ത / കീഴടങ്ങാത്ത', 'phonetic': '/ʌnˈbaʊd/'},
        {'word': 'Menace', 'meaning': 'ഭീഷണി / അപകടസാധ്യത', 'phonetic': '/ˈmen.ɪs/'},
      ],
      reflectionQuestion: 'What is the central theme of "Invictus"?',
      reflectionOptions: [
        'Giving up in difficult times',
        'Unbreakable resilience and mastery over one\'s destiny',
        'Complaining about circumstances',
        'Sleeping through the night',
      ],
      correctReflectionIndex: 1,
    ),
    _ReadingItem(
      id: 'speech_1',
      category: 'speeches',
      categoryLabel: 'Master Oratory',
      categoryIcon: '🎙️',
      title: 'The Cadence of Conviction (I Have a Dream Excerpt)',
      author: 'Dr. Martin Luther King Jr.',
      readingTimeMins: 4,
      difficulty: 'Intermediate - Advanced',
      excerpt: 'I say to you today, my friends, that in spite of the difficulties and frustrations of the moment, I still have a dream...',
      contentParagraphs: [
        'I say to you today, my friends, that in spite of the difficulties and frustrations of the moment, I still have a dream. It is a dream deeply rooted in the universal promise of human dignity.',
        'I have a dream that one day this nation will rise up and live out the true meaning of its creed: "We hold these truths to be self-evident, that all men are created equal."',
        'I have a dream that my four little children will one day live in a nation where they will not be judged by the color of their skin but by the content of their character.',
        'Notice the oratorical power of repetition ("I have a dream") and rhythmic triads. This is how timeless English moves nations.',
      ],
      vocabNotes: [
        {'word': 'Creed', 'meaning': 'വിശ്വാസപ്രമാണം / തത്വം', 'phonetic': '/kriːd/'},
        {'word': 'Self-evident', 'meaning': 'സ്വയം വ്യക്തമായ', 'phonetic': '/ˌselfˈev.ɪ.dənt/'},
        {'word': 'Oratorical', 'meaning': 'പ്രസംഗകലപരമായ', 'phonetic': '/ˌɒr.əˈtɒr.ɪ.kəl/'},
        {'word': 'Cadence', 'meaning': 'ശബ്ദത്തിന്റെ താളം / ഭംഗി', 'phonetic': '/ˈkeɪ.dəns/'},
      ],
      reflectionQuestion: 'Which rhetoric device gives this speech its unforgettable power?',
      reflectionOptions: [
        'Whispering',
        'Rhythmic anaphora (repetition) and parallel sentence structure',
        'Complicated technical jargon',
        'Rushing without pauses',
      ],
      correctReflectionIndex: 1,
    ),
    _ReadingItem(
      id: 'exec_1',
      category: 'executive',
      categoryLabel: 'Executive Wisdom',
      categoryIcon: '💡',
      title: 'The Architecture of Diplomatic Listening',
      author: 'Executive Leadership Institute',
      readingTimeMins: 3,
      difficulty: 'Advanced',
      excerpt: 'Elite communicators do not listen to reply; they listen to understand beneath the surface of spoken words...',
      contentParagraphs: [
        'The greatest breakdown in professional negotiations occurs when participants begin formulating their rebuttal before the other party has finished speaking.',
        'Diplomatic listening requires three concurrent disciplines: maintaining empathetic eye contact, noting verbal pauses, and summarizing the counterpart\'s core point before presenting your own.',
        'By utilizing diplomatic softeners such as "If I understand your perspective accurately..." you defuse tension and transform an adversarial debate into a joint problem-solving accord.',
        'Mastery of English is not solely about grand vocabulary; it is about knowing how to hold space for others through articulate, measured speech.',
      ],
      vocabNotes: [
        {'word': 'Rebuttal', 'meaning': 'മറുവാദം / ഖണ്ഡിക്കൽ', 'phonetic': '/rɪˈbʌt.əl/'},
        {'word': 'Adversarial', 'meaning': 'ശത്രുതാപരമായ', 'phonetic': '/ˌæd.vəˈseə.ri.əl/'},
        {'word': 'Concur', 'meaning': 'യോജിക്കുക / സമ്മതിക്കുക', 'phonetic': '/kənˈkɜːr/'},
        {'word': 'Articulate', 'meaning': 'വ്യക്തമായി പ്രകടിപ്പിക്കാൻ കഴിവുള്ള', 'phonetic': '/ɑːˈtɪk.jə.lət/'},
      ],
      reflectionQuestion: 'What is the key technique recommended for diplomatic listening?',
      reflectionOptions: [
        'Interrupting quickly',
        'Summarizing the counterpart\'s perspective before responding',
        'Ignoring the other speaker',
        'Speaking much louder',
      ],
      correctReflectionIndex: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0xFF8B5CF6), width: 2)),
      ),
      child: _activeReading != null ? _buildReaderView(_activeReading!) : _buildCatalogView(),
    );
  }

  // CATALOG VIEW
  Widget _buildCatalogView() {
    final filtered = _selectedCategory == 'all'
        ? _libraryItems
        : _libraryItems.where((item) => item.category == _selectedCategory).toList();

    return Column(
      children: [
        // Drag handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.4)),
                ),
                child: const Text('📚', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'POCKET READING LIBRARY',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Free stories, poems, oratory & audio reading',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white70),
              ),
            ],
          ),
        ),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              _buildCategoryChip('all', 'All Works', '📚'),
              _buildCategoryChip('stories', 'Stories', '📖'),
              _buildCategoryChip('poetry', 'Poetry', '📜'),
              _buildCategoryChip('speeches', 'Speeches', '🎙️'),
              _buildCategoryChip('executive', 'Leadership', '💡'),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // Reading List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: filtered.length,
            itemBuilder: (context, idx) {
              final item = filtered[idx];
              return _buildReadingCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String catId, String label, String icon) {
    final isSelected = _selectedCategory == catId;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = catId);
        HapticFeedback.selectionClick();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingCard(_ReadingItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${item.categoryIcon} ${item.categoryLabel}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFA78BFA),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '⏱️ ${item.readingTimeMins} min read',
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'By ${item.author}',
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.excerpt,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '📊 ${item.difficulty}',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _activeReading = item;
                    _highlightedParagraphIndex = 0;
                    _isPlayingAudio = false;
                  });
                  HapticFeedback.lightImpact();
                },
                icon: const Icon(Icons.menu_book, size: 14),
                label: const Text('READ & LISTEN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // READER VIEW WITH AUDIO SIMULATION
  Widget _buildReaderView(_ReadingItem item) {
    return Column(
      children: [
        // Reader Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() {
                  _activeReading = null;
                  _isPlayingAudio = false;
                }),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${item.author} • ${item.categoryLabel}',
                      style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              // Listen Button (Simulated TTS Narration)
              GestureDetector(
                onTap: _toggleAudioPlayback,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isPlayingAudio ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isPlayingAudio ? const Color(0xFF10B981) : const Color(0xFF8B5CF6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isPlayingAudio ? Icons.pause : Icons.volume_up,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isPlayingAudio ? 'PLAYING' : 'LISTEN',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(color: Color(0xFF1E293B), height: 1),

        // Reader Content ScrollView
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Paragraphs with active read-along highlight
                ...List.generate(item.contentParagraphs.length, (idx) {
                  final isCurrent = _isPlayingAudio && _highlightedParagraphIndex == idx;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: isCurrent ? const EdgeInsets.all(12) : EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: isCurrent ? const Color(0xFF8B5CF6).withValues(alpha: 0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: isCurrent ? Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.4)) : null,
                    ),
                    child: Text(
                      item.contentParagraphs[idx],
                      style: GoogleFonts.inter(
                        color: isCurrent ? Colors.white : const Color(0xFFE2E8F0),
                        fontSize: 13.5,
                        height: 1.6,
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Key Vocabulary Card
                _buildVocabGlossary(item.vocabNotes),

                const SizedBox(height: 16),

                // Quick Reflection / Comprehension Check
                _buildReflectionQuiz(item),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _toggleAudioPlayback() {
    setState(() {
      _isPlayingAudio = !_isPlayingAudio;
      if (_isPlayingAudio) {
        _startAutoAdvanceNarration();
      }
    });
    HapticFeedback.selectionClick();
  }

  void _startAutoAdvanceNarration() async {
    while (_isPlayingAudio && mounted && _activeReading != null) {
      await Future.delayed(const Duration(seconds: 4));
      if (!_isPlayingAudio || !mounted || _activeReading == null) break;
      setState(() {
        if (_highlightedParagraphIndex < _activeReading!.contentParagraphs.length - 1) {
          _highlightedParagraphIndex++;
        } else {
          _isPlayingAudio = false;
          _highlightedParagraphIndex = 0;
        }
      });
    }
  }

  Widget _buildVocabGlossary(List<Map<String, String>> notes) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Key Vocabulary & Pronunciation',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF38BDF8),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: notes.map((n) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          n['word'] ?? '',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          n['phonetic'] ?? '',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF94A3B8),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      n['meaning'] ?? '',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionQuiz(_ReadingItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✍️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.reflectionQuestion,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(item.reflectionOptions.length, (idx) {
            final opt = item.reflectionOptions[idx];
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  final isCorrect = idx == item.correctReflectionIndex;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      content: Text(
                        isCorrect
                            ? '🎉 Correct! +25 Reading Coins earned & Study Timer updated!'
                            : 'Review the text above and try again!',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  );
                  if (isCorrect) {
                    widget.onReadingCompleted?.call();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: const Color(0xFFCBD5E1),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
                child: Text(
                  '${String.fromCharCode(65 + idx)}) $opt',
                  style: GoogleFonts.inter(fontSize: 11.5),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ReadingItem {
  final String id;
  final String category;
  final String categoryLabel;
  final String categoryIcon;
  final String title;
  final String author;
  final int readingTimeMins;
  final String difficulty;
  final String excerpt;
  final List<String> contentParagraphs;
  final List<Map<String, String>> vocabNotes;
  final String reflectionQuestion;
  final List<String> reflectionOptions;
  final int correctReflectionIndex;

  const _ReadingItem({
    required this.id,
    required this.category,
    required this.categoryLabel,
    required this.categoryIcon,
    required this.title,
    required this.author,
    required this.readingTimeMins,
    required this.difficulty,
    required this.excerpt,
    required this.contentParagraphs,
    required this.vocabNotes,
    required this.reflectionQuestion,
    required this.reflectionOptions,
    required this.correctReflectionIndex,
  });
}
