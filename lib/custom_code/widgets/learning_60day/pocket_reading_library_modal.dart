import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

/// 📚 POCKET WORLD READING LIBRARY & LITERARY REPOSITORY
///
/// English-Only Reading Habit Engine with:
/// 1. Real FlutterTTS paragraph-by-paragraph read-along narration.
/// 2. Robot Reading Mates (Lexi, Sage, Byte, Nova) as interactive companions.
/// 3. Curated English Classic Stories, Mysteries, Sci-Fi, Speeches & Fables.
/// 4. Tap-to-pronounce vocabulary breakdown with phonetics.
/// 5. Daily 10-minute Reading Habit Tracker & XP rewards.
class PocketReadingLibraryModal extends StatefulWidget {
  final int currentDay;
  final VoidCallback? onReadingCompleted;

  const PocketReadingLibraryModal({
    super.key,
    this.currentDay = 1,
    this.onReadingCompleted,
  });

  static Future<void> show(BuildContext context,
      {int currentDay = 1, VoidCallback? onReadingCompleted}) {
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
  State<PocketReadingLibraryModal> createState() =>
      _PocketReadingLibraryModalState();
}

class _PocketReadingLibraryModalState extends State<PocketReadingLibraryModal> {
  String _selectedCategory = 'all';
  _ReadingItem? _activeReading;
  bool _isPlayingAudio = false;
  int _highlightedParagraphIndex = 0;
  final FlutterTts _tts = FlutterTts();

  // Robot Reading Companion
  String _selectedRobot = 'Lexi';
  final Map<String, Map<String, String>> _robotMates = {
    'Lexi': {
      'icon': '🤖',
      'role': 'Literature & Fluency Guide',
      'quote':
          'Reading aloud is the secret bridge between understanding and speaking!',
      'color': '0xFF8B5CF6',
    },
    'Sage': {
      'icon': '🧙‍♂️',
      'role': 'Philosophy & Oratory Master',
      'quote':
          'Ponder each sentence carefully; great thoughts forge great speakers.',
      'color': '0xFF38BDF8',
    },
    'Byte': {
      'icon': '🦾',
      'role': 'Sci-Fi & Technical Companion',
      'quote': 'Deconstruct the grammar patterns like clean, modular code!',
      'color': '0xFF10B981',
    },
    'Nova': {
      'icon': '🚀',
      'role': 'Adventure & Storyteller',
      'quote': 'Immerse your imagination fully into the narrative world!',
      'color': '0xFFF59E0B',
    },
  };

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.46);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setCompletionHandler(() {
        if (_isPlayingAudio && mounted && _activeReading != null) {
          if (_highlightedParagraphIndex <
              _activeReading!.contentParagraphs.length - 1) {
            setState(() {
              _highlightedParagraphIndex++;
            });
            _speakCurrentParagraph();
          } else {
            setState(() {
              _isPlayingAudio = false;
              _highlightedParagraphIndex = 0;
            });
          }
        }
      });
    } catch (_) {}
  }

  void _speakCurrentParagraph() async {
    if (_activeReading == null) return;
    final text = _activeReading!.contentParagraphs[_highlightedParagraphIndex];
    await _tts.stop();
    await _tts.speak(text);
  }

  void _toggleAudioPlayback() async {
    HapticFeedback.selectionClick();
    if (_isPlayingAudio) {
      await _tts.stop();
      setState(() => _isPlayingAudio = false);
    } else {
      setState(() => _isPlayingAudio = true);
      _speakCurrentParagraph();
    }
  }

  final List<_ReadingItem> _libraryItems = const [
    _ReadingItem(
      id: 'story_sherlock',
      category: 'mysteries',
      categoryLabel: 'Sherlock Holmes Mystery',
      categoryIcon: '🔍',
      title: 'The Mystery of the Red-Headed League',
      author: 'Sir Arthur Conan Doyle',
      readingTimeMins: 5,
      difficulty: 'Intermediate',
      excerpt:
          'Mr. Jabez Wilson presented an extraordinary problem to Sherlock Holmes: a bizarre advertisement and a mysterious bank cellar...',
      contentParagraphs: [
        'Sherlock Holmes sat in his armchair at 221B Baker Street, listening attentively to our visitor, Mr. Jabez Wilson, a red-headed pawnbroker with an extraordinary dilemma.',
        '"For months," Wilson explained, "I was paid a handsome wage simply to copy the Encyclopedia Britannica in a secluded office, solely because of the brilliant shade of my hair."',
        'Holmes leaned forward, his piercing gray eyes alive with keen analytical interest. "And then, Mr. Wilson, what transpired?"',
        '"One morning, gentlemen, a cardboard sign was pinned to the locked door: The Red-Headed League is Dissolved. The entire organization had vanished into thin air!"',
        'Holmes smiled quietly. To the untrained eye, it seemed a peculiar practical joke; to Holmes, it was the clever distraction masking an audacious bank robbery beneath the city streets.',
      ],
      vocabNotes: [
        {
          'word': 'Attentively',
          'meaning': 'വളരെ ശ്രദ്ധയോടെ / ഏകാഗ്രതയോടെ',
          'phonetic': '/əˈten.tɪv.li/'
        },
        {
          'word': 'Dilemma',
          'meaning': 'ധർമ്മസങ്കടം / കുഴപ്പത്തിലാക്കുന്ന അവസ്ഥ',
          'phonetic': '/dɪˈlem.ə/'
        },
        {
          'word': 'Audacious',
          'meaning': 'അതിസാഹസികമായ / ധീരമായ',
          'phonetic': '/ɔːˈdeɪ.ʃəs/'
        },
        {
          'word': 'Peculiar',
          'meaning': 'വിചിത്രമായ / അസാധാരണമായ',
          'phonetic': '/pɪˈkjuː.li.ər/'
        },
      ],
      reflectionQuestion:
          'What did Sherlock Holmes deduce about the Red-Headed League?',
      reflectionOptions: [
        'It was a legitimate charity organization',
        'It was a clever distraction to tunnel into a bank vault',
        'It was an encyclopedia printing company',
        'It was a private gentleman\'s club',
      ],
      correctReflectionIndex: 1,
    ),
    _ReadingItem(
      id: 'story_magi',
      category: 'classics',
      categoryLabel: 'Heartwarming Classic',
      categoryIcon: '🎁',
      title: 'The Gift of the Magi',
      author: 'O. Henry',
      readingTimeMins: 4,
      difficulty: 'Beginner - Intermediate',
      excerpt:
          'One dollar and eighty-seven cents. That was all. And tomorrow was Christmas. Della had only one priceless treasure: her cascade of brown hair...',
      contentParagraphs: [
        'One dollar and eighty-seven cents. That was all. And sixty cents of it was in pennies, saved one and two at a time by bargaining hard with the grocer.',
        'Della counted it three times. Tomorrow would be Christmas Day, and she had clearly nothing of substance to buy Jim, her beloved husband, a worthy gift.',
        'There were two possessions of the James Dillingham Youngs in which they took mighty pride: Jim\'s heirloom gold watch and Della\'s long, shimmering cascade of hair.',
        'With tears in her eyes, Della ran down the stairs to Madame Sofronie\'s hair salon. "Will you buy my hair?" she asked with quiet dignity.',
        'Twenty dollars later, she raced through the city shops until she discovered it: a platinum watch chain, simple and chaste in design, perfectly worthy of Jim.',
        'True generosity is not measured in coins, but in the willingness to surrender that which is most precious out of genuine love.',
      ],
      vocabNotes: [
        {
          'word': 'Cascade',
          'meaning': 'വെള്ളച്ചാട്ടം പോലെ ഒഴുകുന്ന ഭംഗി',
          'phonetic': '/kæsˈkeɪd/'
        },
        {
          'word': 'Heirloom',
          'meaning': 'കുടുംബപാരമ്പര്യമായി കൈമാറിവന്ന സ്വത്ത്',
          'phonetic': '/ˈeə.luːm/'
        },
        {
          'word': 'Chaste',
          'meaning': 'ലളിതവും മാന്യവുമായ',
          'phonetic': '/tʃeɪst/'
        },
        {
          'word': 'Generosity',
          'meaning': 'ഔദാര്യം / വിശാലമനസ്സ്',
          'phonetic': '/ˌdʒen.əˈrɒs.ə.ti/'
        },
      ],
      reflectionQuestion:
          'What makes Della\'s gift so universally touching across generations?',
      reflectionOptions: [
        'It was the most expensive platinum chain in New York',
        'She sacrificed her most treasured possession out of selfless love',
        'Jim asked for it specifically',
        'It was on discount at the department store',
      ],
      correctReflectionIndex: 1,
    ),
    _ReadingItem(
      id: 'story_timemachine',
      category: 'scifi',
      categoryLabel: 'Sci-Fi Adventure',
      categoryIcon: '⏳',
      title: 'The Time Machine (First Leap into Tomorrow)',
      author: 'H.G. Wells',
      readingTimeMins: 4,
      difficulty: 'Intermediate',
      excerpt:
          'I gripped the starting lever with both hands and pushed it forward an inch. The laboratory grew faint and hazy...',
      contentParagraphs: [
        '"It is simply this," the Time Traveller told us, resting his hand upon the metallic levers of his brass and ivory apparatus. "Time is simply the fourth dimension of space."',
        'He pressed the forward lever an inch. Immediately, the laboratory grew faint and hazy. Day and night flapped together like dark wings.',
        'I saw the sun hopping swiftly across the sky every minute, marking the passage of a full day in the blink of an eye.',
        'The trees grew, spread, shed their autumn leaves, and sprouted green again like rapid stop-motion photographs across the years.',
        'Human language, like time itself, is an ongoing journey. When we read, we travel through the minds of thinkers who lived centuries before us.',
      ],
      vocabNotes: [
        {
          'word': 'Apparatus',
          'meaning': 'യന്ത്രസംവിധാനം / ഉപകരണം',
          'phonetic': '/ˌæp.əˈreɪ.təs/'
        },
        {
          'word': 'Dimension',
          'meaning': 'മാനം / അളവ് / വശം',
          'phonetic': '/daɪˈmen.ʃən/'
        },
        {
          'word': 'Passage',
          'meaning': 'കടന്നുപോക്ക് / കാലയളവ്',
          'phonetic': '/ˈpæs.ɪdʒ/'
        },
        {
          'word': 'Stop-motion',
          'meaning': 'ഫ്രെയിം ബൈ ഫ്രെയിം ചലനം',
          'phonetic': '/ˈstɒpˌməʊ.ʃən/'
        },
      ],
      reflectionQuestion:
          'How does the Time Traveller describe the nature of Time?',
      reflectionOptions: [
        'An unstoppable river',
        'The fourth dimension of space',
        'A winding mountain clock',
        'A mystery that cannot be understood',
      ],
      correctReflectionIndex: 1,
    ),
    _ReadingItem(
      id: 'story_alice',
      category: 'classics',
      categoryLabel: 'Fantasy & Wonder',
      categoryIcon: '🐇',
      title: 'Alice in Wonderland (Down the Rabbit-Hole)',
      author: 'Lewis Carroll',
      readingTimeMins: 4,
      difficulty: 'Beginner - Intermediate',
      excerpt:
          'Alice was beginning to get very tired of sitting by her sister on the riverbank, when suddenly a White Rabbit with pink eyes ran close by her...',
      contentParagraphs: [
        'Alice was beginning to get very tired of sitting by her sister on the grassy bank and of having nothing to do.',
        'Once or twice she had peeped into the book her sister was reading, but it had no pictures or conversations in it. "And what is the use of a book," thought Alice, "without pictures or conversations?"',
        'Suddenly, a White Rabbit with pink eyes scurried past her, pulled a gold pocket watch from his waistcoat pocket, and exclaimed: "Oh dear! Oh dear! I shall be too late!"',
        'Burning with curiosity, Alice sprang to her feet and chased the rabbit across the field, arriving just in time to see him pop down a large rabbit-hole under the hedge.',
        'In another moment, down went Alice after him, never once considering how in the world she was to get out again.',
        'Curiosity is the engine of all fluency. Never fear the rabbit-hole of a new language; jump in boldly and explore!',
      ],
      vocabNotes: [
        {
          'word': 'Peeped',
          'meaning': 'ഒളിഞ്ഞു നോക്കി / വേഗത്തിൽ നോക്കി',
          'phonetic': '/piːpt/'
        },
        {
          'word': 'Scurried',
          'meaning': 'വേഗത്തിൽ ഓടിപ്പോയി',
          'phonetic': '/ˈskʌr.id/'
        },
        {
          'word': 'Waistcoat',
          'meaning': 'കോട്ടിന്റെ ഉള്ളിലിടുന്ന ചെറിയ കുപ്പായം',
          'phonetic': '/ˈweɪst.kəʊt/'
        },
        {
          'word': 'Curiosity',
          'meaning': 'അറിയാനുള്ള അതിയായ ആഗ്രഹം / കൗതുകം',
          'phonetic': '/ˌkjʊə.riˈɒs.ə.ti/'
        },
      ],
      reflectionQuestion:
          'Why did Alice follow the White Rabbit down the hole?',
      reflectionOptions: [
        'She wanted to catch dinner',
        'She was burning with genuine childlike curiosity',
        'Her sister ordered her to run',
        'She was running away from school',
      ],
      correctReflectionIndex: 1,
    ),
    _ReadingItem(
      id: 'story_lastleaf',
      category: 'classics',
      categoryLabel: 'Emotional Triumph',
      categoryIcon: '🍃',
      title: 'The Last Leaf (Hope in the Autumn Wind)',
      author: 'O. Henry',
      readingTimeMins: 4,
      difficulty: 'Intermediate',
      excerpt:
          'In Greenwich Village, Johnsy lay sick in bed, watching the ivy vine lose its leaves. "When the last one falls," she whispered, "I must go too..."',
      contentParagraphs: [
        'In a small studio apartment in Greenwich Village, young Johnsy lay frail and pneumonia-stricken, gazing out the window at the brick wall opposite.',
        '"Leaves," she whispered, counting backwards. "Ten, nine, eight... when the last ivy leaf falls, I must go too."',
        'Downstairs lived old Behrman, an aging painter who had spent forty years dreaming of painting his elusive masterpiece.',
        'That night, a cold, merciless rain beat against the windows, driven by ferocious winter gales. Johnsy waited in quiet despair for the final leaf to drop.',
        'Yet the next morning, standing bravely against the storm, one dark green leaf remained stubbornly attached to the vine.',
        'Johnsy looked at it and smiled. "Something has made that last leaf stay there to show me how wicked I was to despair. I will live."',
        'Old Behrman died that afternoon of pneumonia. In the driving storm and freezing dark, he had painted his masterpiece on the wall: the leaf that never fell.',
      ],
      vocabNotes: [
        {
          'word': 'Frail',
          'meaning': 'ശരീരബലമില്ലാത്ത / ദുർബലമായ',
          'phonetic': '/freɪl/'
        },
        {
          'word': 'Elusive',
          'meaning': 'കൈപ്പിടിയിൽ ഒതുങ്ങാത്ത / പിടികൊടുക്കാത്ത',
          'phonetic': '/ɪˈluː.sɪv/'
        },
        {
          'word': 'Masterpiece',
          'meaning': 'ജീവിതത്തിലെ ഏറ്റവും മികച്ച സൃഷ്ടി',
          'phonetic': '/ˈmɑː.stə.piːs/'
        },
        {
          'word': 'Ferocious',
          'meaning': 'ശക്തിയേറിയ / ഭയങ്കരമായ',
          'phonetic': '/fəˈrəʊ.ʃəs/'
        },
      ],
      reflectionQuestion:
          'What was old Behrman\'s true masterpiece that saved Johnsy\'s life?',
      reflectionOptions: [
        'A portrait of the mayor',
        'The ivy leaf painted on the brick wall during the freezing storm',
        'A sculpture of an ancient hero',
        'A landscape of Greenwich Village',
      ],
      correctReflectionIndex: 1,
    ),
    _ReadingItem(
      id: 'story_jobs',
      category: 'speeches',
      categoryLabel: 'Modern Keynote',
      categoryIcon: '💡',
      title: 'Stay Hungry, Stay Foolish',
      author: 'Steve Jobs (Stanford Address)',
      readingTimeMins: 4,
      difficulty: 'Intermediate - Advanced',
      excerpt:
          'You can\'t connect the dots looking forward; you can only connect them looking backwards. You have to trust that the dots will somehow connect...',
      contentParagraphs: [
        'You can\'t connect the dots looking forward; you can only connect them looking backwards. So you have to trust that the dots will somehow connect in your future.',
        'You have to trust in something—your gut, destiny, life, karma, whatever. This approach has never let me down, and it has made all the difference in my life.',
        'Your work is going to fill a large part of your life, and the only way to be truly satisfied is to do what you believe is great work.',
        'And the only way to do great work is to love what you do. If you haven\'t found it yet, keep looking. Don\'t settle.',
        'Your time is limited, so don\'t waste it living someone else\'s life. Don\'t let the noise of others\' opinions drown out your own inner voice.',
        'Stay Hungry. Stay Foolish.',
      ],
      vocabNotes: [
        {
          'word': 'Destiny',
          'meaning': 'വിധി / ഭാവിഭാഗ്യം',
          'phonetic': '/ˈdes.tɪ.ni/'
        },
        {'word': 'Karma', 'meaning': 'കർമ്മഫലം', 'phonetic': '/ˈkɑː.mə/'},
        {
          'word': 'Drown out',
          'meaning': 'മറ്റൊരു ശബ്ദം കൊണ്ട് ഇല്ലാതാക്കുക',
          'phonetic': '/draʊn aʊt/'
        },
        {
          'word': 'Satisfied',
          'meaning': 'തൃപ്തനായ / സന്തുഷ്ടനായ',
          'phonetic': '/ˈsæt.ɪs.faɪd/'
        },
      ],
      reflectionQuestion:
          'According to Steve Jobs, what is the prerequisite for doing truly great work?',
      reflectionOptions: [
        'Working 100 hours a week without sleeping',
        'Loving what you do and refusing to settle',
        'Earning the highest salary in the firm',
        'Copying the decisions of competitors',
      ],
      correctReflectionIndex: 1,
    ),
    _ReadingItem(
      id: 'speech_1',
      category: 'speeches',
      categoryLabel: 'Master Oratory',
      categoryIcon: '🎙️',
      title: 'The Cadence of Conviction (I Have a Dream)',
      author: 'Dr. Martin Luther King Jr.',
      readingTimeMins: 4,
      difficulty: 'Intermediate - Advanced',
      excerpt:
          'I say to you today, my friends, that in spite of the difficulties and frustrations of the moment, I still have a dream...',
      contentParagraphs: [
        'I say to you today, my friends, that in spite of the difficulties and frustrations of the moment, I still have a dream. It is a dream deeply rooted in the universal promise of human dignity.',
        'I have a dream that one day this nation will rise up and live out the true meaning of its creed: "We hold these truths to be self-evident, that all men are created equal."',
        'I have a dream that my four little children will one day live in a nation where they will not be judged by the color of their skin but by the content of their character.',
        'Notice the oratorical power of repetition ("I have a dream") and rhythmic triads. This is how timeless English moves nations.',
      ],
      vocabNotes: [
        {
          'word': 'Creed',
          'meaning': 'വിശ്വാസപ്രമാണം / തത്വം',
          'phonetic': '/kriːd/'
        },
        {
          'word': 'Self-evident',
          'meaning': 'സ്വയം വ്യക്തമായ',
          'phonetic': '/ˌselfˈev.ɪ.dənt/'
        },
        {
          'word': 'Oratorical',
          'meaning': 'പ്രസംഗകലപരമായ',
          'phonetic': '/ˌɒr.əˈtɒr.ɪ.kəl/'
        },
        {
          'word': 'Cadence',
          'meaning': 'ശബ്ദത്തിന്റെ താളം / ഭംഗി',
          'phonetic': '/ˈkeɪ.dəns/'
        },
      ],
      reflectionQuestion:
          'Which rhetoric device gives this speech its unforgettable power?',
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
      excerpt:
          'Elite communicators do not listen to reply; they listen to understand beneath the surface of spoken words...',
      contentParagraphs: [
        'The greatest breakdown in professional negotiations occurs when participants begin formulating their rebuttal before the other party has finished speaking.',
        'Diplomatic listening requires three concurrent disciplines: maintaining empathetic eye contact, noting verbal pauses, and summarizing the counterpart\'s core point before presenting your own.',
        'By utilizing diplomatic softeners such as "If I understand your perspective accurately..." you defuse tension and transform an adversarial debate into a joint problem-solving accord.',
        'Mastery of English is not solely about grand vocabulary; it is about knowing how to hold space for others through articulate, measured speech.',
      ],
      vocabNotes: [
        {
          'word': 'Rebuttal',
          'meaning': 'മറുവാദം / ഖണ്ഡിക്കൽ',
          'phonetic': '/rɪˈbʌt.əl/'
        },
        {
          'word': 'Adversarial',
          'meaning': 'ശത്രുതാപരമായ',
          'phonetic': '/ˌæd.vəˈseə.ri.əl/'
        },
        {
          'word': 'Concur',
          'meaning': 'യോജിക്കുക / സമ്മതിക്കുക',
          'phonetic': '/kənˈkɜːr/'
        },
        {
          'word': 'Articulate',
          'meaning': 'വ്യക്തമായി പ്രകടിപ്പിക്കാൻ കഴിവുള്ള',
          'phonetic': '/ɑːˈtɪk.jə.lət/'
        },
      ],
      reflectionQuestion:
          'What is the key technique recommended for diplomatic listening?',
      reflectionOptions: [
        'Interrupting quickly',
        'Summarizing the counterpart\'s perspective before responding',
        'Ignoring the other speaker',
        'Speaking much louder',
      ],
      correctReflectionIndex: 1,
    ),
    _ReadingItem(
      id: 'fable_aesop',
      category: 'fables',
      categoryLabel: 'Wisdom Fable',
      categoryIcon: '🐢',
      title: 'The Tortoise and the Hare',
      author: 'Aesop',
      readingTimeMins: 3,
      difficulty: 'Beginner',
      excerpt:
          'A boastful Hare scoffed at a slow-moving Tortoise, challenging him to a race across the woodland...',
      contentParagraphs: [
        'A Hare was once boasting of his incredible speed before the other woodland creatures. "I have never yet been beaten," said he, "when I put forth my full speed. I challenge anyone here to race with me."',
        'The Tortoise said quietly, "I accept your challenge."',
        '"That is a good joke!" laughed the Hare; "I could dance around you all the way."',
        'The race began. The Hare darted almost out of sight at once, but soon stopped and, to show his contempt for the Tortoise, lay down to take a nap.',
        'Meanwhile, the Tortoise plodded on and plodded on; he never stopped for a moment until he neared the finish line.',
        'When the Hare awoke from his slumber, he sprinted like the wind, but it was too late. The Tortoise had already crossed the ribbon.',
        'Slow and steady wins the race. Daily consistency in English will always defeat sporadic bursts of study.',
      ],
      vocabNotes: [
        {
          'word': 'Boasting',
          'meaning': 'പൊങ്ങച്ചം പറയൽ / അഹങ്കരിക്കൽ',
          'phonetic': '/ˈbəʊ.stɪŋ/'
        },
        {
          'word': 'Contempt',
          'meaning': 'പുച്ഛം / വിലകുറച്ചുകാണൽ',
          'phonetic': '/kənˈtempt/'
        },
        {
          'word': 'Plodded',
          'meaning': 'പതിയെ എങ്കിലും ഉറച്ച കാലടികളോടെ മുന്നേറി',
          'phonetic': '/ˈplɒd.ɪd/'
        },
        {
          'word': 'Sporadic',
          'meaning': 'എപ്പോഴെങ്കിലും മാത്രം ഉണ്ടാകുന്ന',
          'phonetic': '/spəˈræd.ɪk/'
        },
      ],
      reflectionQuestion:
          'How does this classic fable apply to your 90-day English journey?',
      reflectionOptions: [
        'You should study 10 hours once a month',
        'Small, steady daily practice beats erratic cramming every single time',
        'Fast talkers are always the best thinkers',
        'Sleeping during work is beneficial',
      ],
      correctReflectionIndex: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0xFF8B5CF6), width: 2)),
      ),
      child: _activeReading != null
          ? _buildReaderView(_activeReading!)
          : _buildCatalogView(),
    );
  }

  // CATALOG VIEW
  Widget _buildCatalogView() {
    final filtered = _selectedCategory == 'all'
        ? _libraryItems
        : _libraryItems
            .where((item) => item.category == _selectedCategory)
            .toList();

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
                  border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.4)),
                ),
                child: const Text('📚', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'POCKET READING REPOSITORY',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'English-Only Stories, Mysteries, Sci-Fi & Keynotes',
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

        // 🎯 Daily Reading Habit Tracker Banner
        _buildReadingHabitBanner(),

        const SizedBox(height: 8),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              _buildCategoryChip(
                  'all', 'All Works (${_libraryItems.length})', '📚'),
              _buildCategoryChip('mysteries', 'Mysteries', '🔍'),
              _buildCategoryChip('classics', 'Classics', '🎁'),
              _buildCategoryChip('scifi', 'Sci-Fi', '⏳'),
              _buildCategoryChip('fables', 'Fables', '🐢'),
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

  Widget _buildReadingHabitBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Text('🔥', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'DAILY 10-MIN READING HABIT',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF818CF8),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+50 XP / Story',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF34D399),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Reading English every day builds effortless subconscious grammar and unstoppable fluency.',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            color: isSelected
                ? const Color(0xFF8B5CF6)
                : Colors.white.withValues(alpha: 0.1),
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
              Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 13, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text(
                    '${item.readingTimeMins} min read',
                    style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'by ${item.author}',
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 11.5,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: GoogleFonts.outfit(
                      fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // READER VIEW WITH REAL FLUTTER_TTS READ-ALONG & ROBOT MATE
  Widget _buildReaderView(_ReadingItem item) {
    final robotData = _robotMates[_selectedRobot] ?? _robotMates['Lexi']!;

    return Column(
      children: [
        // Reader Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              IconButton(
                onPressed: () async {
                  await _tts.stop();
                  setState(() {
                    _activeReading = null;
                    _isPlayingAudio = false;
                  });
                },
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
                      style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8), fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              // Listen Button (Real FlutterTTS Narration)
              GestureDetector(
                onTap: _toggleAudioPlayback,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isPlayingAudio
                        ? const Color(0xFF10B981)
                        : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isPlayingAudio
                          ? const Color(0xFF10B981)
                          : const Color(0xFF8B5CF6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isPlayingAudio
                            ? Icons.pause_circle_filled
                            : Icons.volume_up,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isPlayingAudio ? 'PAUSE' : 'READ ALOUD',
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
                // 🤖 Robot Reading Mate Companion Card
                _buildRobotCompanionCard(robotData),

                const SizedBox(height: 14),

                // Paragraphs with active read-along highlight
                ...List.generate(item.contentParagraphs.length, (idx) {
                  final isCurrent =
                      _isPlayingAudio && _highlightedParagraphIndex == idx;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _highlightedParagraphIndex = idx);
                      if (_isPlayingAudio) {
                        _speakCurrentParagraph();
                      } else {
                        _speakSingleParagraph(item.contentParagraphs[idx]);
                      }
                      HapticFeedback.selectionClick();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: isCurrent
                          ? const EdgeInsets.all(12)
                          : const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFF8B5CF6).withValues(alpha: 0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isCurrent
                            ? Border.all(
                                color: const Color(0xFF8B5CF6)
                                    .withValues(alpha: 0.5),
                                width: 1.2)
                            : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isCurrent)
                            Container(
                              margin: const EdgeInsets.only(right: 8, top: 2),
                              child: const Text('🔊',
                                  style: TextStyle(fontSize: 13)),
                            ),
                          Expanded(
                            child: Text(
                              item.contentParagraphs[idx],
                              style: GoogleFonts.inter(
                                color: isCurrent
                                    ? Colors.white
                                    : const Color(0xFFE2E8F0),
                                fontSize: 14,
                                height: 1.65,
                                fontWeight: isCurrent
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
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

  void _speakSingleParagraph(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Widget _buildRobotCompanionCard(Map<String, String> robot) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF131D33),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(robot['icon']!, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Robot Mate: $_selectedRobot',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF38BDF8),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            robot['role']!,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '"${robot['quote']}"',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.swap_horiz,
                    color: Color(0xFF38BDF8), size: 18),
                tooltip: 'Switch Robot Buddy',
                onSelected: (bot) => setState(() => _selectedRobot = bot),
                itemBuilder: (ctx) => _robotMates.keys.map((bot) {
                  return PopupMenuItem(
                    value: bot,
                    child: Row(
                      children: [
                        Text(_robotMates[bot]!['icon']!),
                        const SizedBox(width: 8),
                        Text(bot,
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVocabGlossary(List<Map<String, String>> notes) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Key Vocabulary & Pronunciation (Tap 🔊 to listen)',
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
              final word = n['word'] ?? '';
              return GestureDetector(
                onTap: () {
                  _tts.stop();
                  _tts.speak(word);
                  HapticFeedback.selectionClick();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            word,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('🔊', style: TextStyle(fontSize: 10)),
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
        border:
            Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
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
                      backgroundColor: isCorrect
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      content: Text(
                        isCorrect
                            ? '🎉 Correct! +50 Reading XP & Citadel Coins earned!'
                            : 'Review the text above and try again!',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, fontSize: 12),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side:
                        BorderSide(color: Colors.white.withValues(alpha: 0.1)),
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
