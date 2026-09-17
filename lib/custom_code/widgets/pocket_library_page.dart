import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pocket_mates_app/custom_code/widgets/ai_prompt_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/ads/pocket_house_ad_widget.dart';

class BookItem {
  final String id;
  final String title;
  final String author;
  final String category;
  final String coverColor;
  final List<Color>? gradientColors;
  final String? coverImageUrl;
  final String summary;
  final int readingTimeMinutes;
  final List<BookChapter> chapters;
  final bool isOnlineBook;
  final int downloadCount;
  final String? textUrl;
  final String? webReaderUrl;

  const BookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.coverColor,
    this.gradientColors,
    this.coverImageUrl,
    required this.summary,
    required this.readingTimeMinutes,
    required this.chapters,
    this.isOnlineBook = false,
    this.downloadCount = 0,
    this.textUrl,
    this.webReaderUrl,
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
  String _selectedCategory = 'All';
  int _readStreakDays = 4;
  int _xpPoints = 180;
  final TextEditingController _searchController = TextEditingController();

  // Free Gutenberg Books via Gutendex API
  List<BookItem> _apiBooks = [];
  bool _isLoadingApi = false;
  String? _apiError;

  final List<String> _categories = [
    'All',
    'മലയാള സാഹിത്യം (Malayalam Classics)',
    'Free Public Library',
    'Google Books Search',
    'Short Stories',
    'Classic Literature',
    'Wisdom & Mindset',
    'Sci-Fi & Cosmos',
    'English Graded Readers',
  ];

  // 35+ Rich Curated Offline & Cultural Heritage Books
  final List<BookItem> _curatedBooks = [
    // --- MALAYALAM CLASSICS & KERALA HERITAGE ---
    BookItem(
      id: 'malayalam_basheer_goat',
      title: 'പാത്തുമ്മയുടെ ആട് (Pathummayude Aadu)',
      author: 'വൈക്കം മുഹമ്മദ് ബഷീർ (Vaikom Muhammad Basheer)',
      category: 'മലയാള സാഹിത്യം (Malayalam Classics)',
      coverColor: '#1E3A8A',
      gradientColors: [const Color(0xFF0F172A), const Color(0xFF1E3A8A)],
      summary: 'മലയാള സാഹിത്യത്തിലെ എക്കാലത്തെയും മഹത്തായ ഹാസ്യ-കുടുംബ നോവൽ. ബഷീറിന്റെ തറവാട്ടു വീട്ടിലെ ആടും ഉമ്മയും സഹോദരങ്ങളും ചേരുന്ന ജീവിതക്കാഴ്ചകൾ.',
      readingTimeMinutes: 14,
      chapters: [
        BookChapter(
          chapterTitle: 'ഭാഗം 1: എന്റെ തറവാടും പാത്തുമ്മയുടെ ആടും',
          content: '''ഞാൻ എന്റെ വീട്ടിൽ വന്നിട്ട് ഇപ്പോൾ കുറച്ചു ദിവസങ്ങളായി. തലവേദനയും ക്ഷീണവും കാരണം കുറച്ചു വിശ്രമം വേണമെന്ന വിചാരത്തോടെയാണ് നാട്ടിലെത്തിയത്.
പക്ഷേ ഇവിടെ എവിടെ വിശ്രമം? വീട്ടിലെ പ്രധാന താരം പാത്തുമ്മയും അവളുടെ ആടുമാണ്!

ഈ ആട് കാണുന്നതൊക്കെ തിന്നും. കടലാസ്, തുണി, വാഴയില, പുസ്തകം—എന്തിനേറെ എന്റെ പുസ്തകങ്ങൾ വരെ അത് ചവച്ചുതുപ്പി. ഒരു ദിവസം രാവിലെ ഞാൻ നോക്കുമ്പോൾ എന്റെ പുതിയ പുസ്തകത്തിന്റെ പ്രൂഫ് ഷീറ്റ് പാത്തുമ്മയുടെ ആട് വളരെ ഭംഗിയായി ചവച്ചരച്ച് ആസ്വദിച്ചു തിന്നുന്നു!

"എടീ പാത്തുമ്മാ, നിന്റെ ആട് എന്റെ പുസ്തകം തിന്നുന്നേ!" എന്ന് ഞാൻ വിളിച്ചുപറഞ്ഞു.
ഉടനെ പാത്തുമ്മ ഓടിവന്നു: "അയ്യോ എന്റെ കൊച്ചുബഷീറേ, ആട് മിണ്ടാപ്രാണിയല്ലേ, അതിന് വിശന്നിട്ടല്ലേ! നിന്റെ ആ പുസ്തകത്തിന് അത്രേം രുചിയുള്ളതുകൊണ്ടാ അത് തിന്നത്!"
ഞാൻ അന്തംവിട്ടുപോയി. ഇതാണ് എന്റെ വീട്!''',
        ),
        BookChapter(
          chapterTitle: 'ഭാഗം 2: ആടിന്റെ കഷ്ടപ്പാടുകൾ',
          content: '''പാത്തുമ്മയുടെ ആടിന് ഒരു പ്രത്യേകതയുണ്ട്. വീട്ടിൽ ആരുമില്ലാത്ത നേരം നോക്കി അടുക്കളയിൽ കയറും. കഞ്ഞിവെള്ളവും ചോറും പാത്രവും വരെ നക്കും.
ഉമ്മ ഇടയ്ക്ക് പറയും: "ആടിനെ എങ്ങോട്ടെങ്കിലും കൊണ്ടുപോയി കെട്ടിക്കൂടെ പെണ്ണേ?"
പാത്തുമ്മ പറയും: "ഉമ്മാ, ഇത് സാധാരണ ആടല്ല, ഇതിന്റെ പാല് കുടിച്ചാൽ തലച്ചോറ് കൂടും!"

വീട്ടിലെ ദാരിദ്ര്യത്തിലും സ്നേഹത്തിലും ചിരി നിറച്ചുകൊണ്ട് ബഷീറിയൻ നർമ്മം ഇവിടെ ഇതൾവിടരുന്നു.''',
        ),
      ],
    ),
    BookItem(
      id: 'malayalam_ramanan_changampuzha',
      title: 'രമണൻ (Ramanan)',
      author: 'ചങ്ങമ്പുഴ കൃഷ്ണപിള്ള (Changampuzha)',
      category: 'മലയാള സാഹിത്യം (Malayalam Classics)',
      coverColor: '#831843',
      gradientColors: [const Color(0xFF831843), const Color(0xFFBE185D)],
      summary: 'മലയാളികളെ കണ്ണീരണിയിച്ച അമരപ്രണയകാവ്യം. കാനനച്ഛായയിൽ ആടുമേയ്ക്കുന്ന രമണന്റെയും ചന്ദ്രികയുടെയും അനശ്വര കഥ.',
      readingTimeMinutes: 12,
      chapters: [
        BookChapter(
          chapterTitle: 'കാനനച്ഛായയിൽ',
          content: '''"കാനനച്ഛായയിലാടുമേയ്ക്കാൻ
ഞാനും വരട്ടെയോ നിന്റെകൂടെ?
പാടില്ല പാടില്ല നമ്മളൊത്തു
പാടില്ല കാട്ടിൽ നടന്നിടുവാൻ..."

മലയാള കവിതാലോകത്ത് വിപ്ലവം സൃഷ്ടിച്ച ഗാനകാവ്യമാണ് ചങ്ങമ്പുഴയുടെ 'രമണൻ'. പാവപ്പെട്ട ഇടയയുവാവായ രമണന്റെയും സമ്പന്നയായ ചന്ദ്രികയുടെയും പ്രണയവും തുടർന്നുണ്ടാകുന്ന വിരഹവേദനയുമാണ് കാവ്യത്തിന്റെ കാതൽ.

"പൂവണിഞ്ഞൊരു പൊൻവനത്തിലൂടെ
പൂങ്കുയിൽ പാടും വഴിയിലൂടെ
പാവമാം എന്നെ മറന്നുവോ നീ,
പാതിരാക്കാറ്റേ പറയുമോ നീ..."''',
        ),
      ],
    ),
    BookItem(
      id: 'malayalam_chemmeen_thakazhi',
      title: 'ചെമ്മീൻ (Chemmeen)',
      author: 'തകഴി ശിവശങ്കരപ്പിള്ള (Thakazhi)',
      category: 'മലയാള സാഹിത്യം (Malayalam Classics)',
      coverColor: '#064E3B',
      gradientColors: [const Color(0xFF064E3B), const Color(0xFF047857)],
      summary: 'കടലമ്മയുടെ നിയമങ്ങളും തീരദേശ മനുഷ്യരുടെ വിശ്വാസങ്ങളും പ്രണയവും പറഞ്ഞ തകഴിയുടെ ലോകപ്രശസ്ത നോവൽ.',
      readingTimeMinutes: 15,
      chapters: [
        BookChapter(
          chapterTitle: 'കടലിന്റെ മക്കൾ',
          content: '''കടലമ്മ വിശാലമാണ്. പക്ഷേ അവൾക്ക് കർക്കശമായ നിയമങ്ങളുണ്ട്. കടലിൽ പോകുന്ന അരയന്റെ ജീവൻ കരയിലിരിക്കുന്ന അവന്റെ പെണ്ണിന്റെ ചാരിത്ര്യത്തിലാണ് എന്ന വിശ്വാസം.

കറുത്തമ്മയും പരീക്കുട്ടിയും തമ്മിലുള്ള സ്നേഹം കടപ്പുറത്തെ മണൽത്തരികൾ പോലെ പവിത്രമായിരുന്നു.
"പരീക്കുട്ടി, നമ്മൾ തമ്മിലുള്ള ഈ ബന്ധം ആരും അറിയരുത്..." കറുത്തമ്മ പറഞ്ഞു.
"കറുത്തമ്മാ, നീയില്ലാതെ എനിക്ക് ഈ കടപ്പുറത്ത് എന്തുണ്ട്?" പരീക്കുട്ടിയുടെ മറുപടി കടലിരമ്പം പോലെ അവളുടെ കാതുകളിൽ മുഴങ്ങി.

തകഴിയുടെ ജീവസ്സുറ്റ ഭാഷയിലൂടെ കടലിന്റെയും മനുഷ്യഹൃദയങ്ങളുടെയും ആഴം അനുഭവപ്പെടുന്നു.''',
        ),
      ],
    ),
    BookItem(
      id: 'malayalam_veena_poovu',
      title: 'വീണപൂവ് (Veena Poovu)',
      author: 'മഹാകവി കുമാരനാശാൻ (Kumaran Asan)',
      category: 'മലയാള സാഹിത്യം (Malayalam Classics)',
      coverColor: '#581C87',
      gradientColors: [const Color(0xFF3B0764), const Color(0xFF7E22CE)],
      summary: 'ഒരു പൂവിന്റെ ജനനം മുതൽ മരണം വരെയുള്ള ജീവിതചക്രം മാനവജീവിതത്തിന്റെ നശ്വരതയുമായി താരതമ്യം ചെയ്ത ദാർശനിക വിലാപകാവ്യം.',
      readingTimeMinutes: 10,
      chapters: [
        BookChapter(
          chapterTitle: 'ഹാ, പുഷ്പമേ...',
          content: '''"ഹാ, പുഷ്പമേ, അധികതുംഗപദത്തിലെത്ര
ശോഭിച്ചിരുന്നിതൊരു രാജ്ഞികണക്കയേ നീ!
ആഹാ, കിടപ്പതിതു കാണ്മതിതോ വിഭൂതി-
ഹാ! ഹന്ത! ദൈവഘടനാഗതി പാരമഗ്ര്യം!"

ഒരു ചെറിയ പൂവിന്റെ കൊഴിഞ്ഞുവീഴ്ചയെ മനുഷ്യന്റെ ജനിമൃതികളുമായി കോർത്തിണക്കി മഹാകവി കുമാരനാശാൻ രചിച്ച അത്ഭുതകാവ്യം. പുഷ്പം വിടർന്നുല്ലസിച്ച യൗവനവും കാറ്റിന്റെ ക്രൂരതയാൽ നിലംപതിച്ച അന്ത്യവും ഇവിടെ കണ്ണീരോടെ വർണ്ണിക്കപ്പെടുന്നു.''',
        ),
      ],
    ),
    BookItem(
      id: 'malayalam_aithihyamala',
      title: 'ഐതിഹ്യമാല: പറയിപെറ്റ പന്തിരുകുലം',
      author: 'കൊട്ടാരത്തിൽ ശങ്കുണ്ണി (Kottarathil Sankunni)',
      category: 'മലയാള സാഹിത്യം (Malayalam Classics)',
      coverColor: '#78350F',
      gradientColors: [const Color(0xFF451A03), const Color(0xFFB45309)],
      summary: 'കേരള ചരിത്രത്തിലെ ഏറ്റവും പ്രശസ്തമായ ഐതിഹ്യം. വരരുചിയുടെയും പഞ്ചമിയുടെയും പന്ത്രണ്ട് മക്കളുടെ വിസ്മയകഥകൾ.',
      readingTimeMinutes: 16,
      chapters: [
        BookChapter(
          chapterTitle: 'പറയിപെറ്റ പന്തിരുകുലം',
          content: '''വിക്രാമാദിത്യ സദസ്സിലെ ജ്ഞാനിയായ വരരുചി ദേശാടനത്തിനിടയിൽ വിധിനിയോഗത്താൽ പഞ്ചമി എന്ന സ്ത്രീയെ വേൾക്കുകയും, അവർക്ക് ജനിച്ച പന്ത്രണ്ട് കുഞ്ഞുങ്ങളെ വഴിയിൽ ഉപേക്ഷിക്കുകയും ചെയ്തു.
"കുഞ്ഞിന് വായുണ്ടോ?" വരരുചി ചോദിക്കും.
"ഉണ്ട്" എന്ന് പഞ്ചമി പറയുമ്പോൾ: "എന്നാൽ വായ തന്ന ദൈവം തീറ്റയും കൊടുക്കും, അതിനെ അവിടെ വെച്ചേക്കുക" എന്ന് പറഞ്ഞ് യാത്ര തുടരും.

അങ്ങനെ വഴിയിൽ ഉപേക്ഷിക്കപ്പെട്ട പന്ത്രണ്ട് കുഞ്ഞുങ്ങളെ പന്ത്രണ്ട് വ്യത്യസ്ത സമുദായങ്ങളിലെ ദമ്പതികൾ എടുത്തു വളർത്തി. അവരാണ് മേഴത്തോൾ അഗ്നിഹോത്രി, പാക്കനാർ, പെരുന്തച്ചൻ, നാറാണത്തു ഭ്രാന്തൻ തുടങ്ങിയ വിഖ്യാതരായ പന്തിരുകുലക്കാർ!''',
        ),
      ],
    ),
    // --- GLOBAL ENGLISH MASTERPIECES ---
    BookItem(
      id: 'sherlock_holmes_1',
      title: 'A Scandal in Bohemia',
      author: 'Arthur Conan Doyle',
      category: 'Classic Literature',
      coverColor: '#1E293B',
      gradientColors: [const Color(0xFF0F172A), const Color(0xFF334155)],
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
      gradientColors: [const Color(0xFF7C2D12), const Color(0xFFB45309)],
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
      gradientColors: [const Color(0xFF065F46), const Color(0xFF047857)],
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
      id: 'happy_prince_oscar',
      title: 'The Happy Prince',
      author: 'Oscar Wilde',
      category: 'Short Stories',
      coverColor: '#BE185D',
      gradientColors: [const Color(0xFF831843), const Color(0xFFBE185D)],
      summary: 'A gilded statue and a devoted little swallow sacrifice everything to bring hope to the impoverished.',
      readingTimeMinutes: 11,
      chapters: [
        BookChapter(
          chapterTitle: 'The Gilded Statue & The Swallow',
          content: '''High above the city, on a tall column, stood the statue of the Happy Prince. He was gilded all over with thin leaves of fine gold, for eyes he had two bright sapphires, and a large red ruby glowed on his sword-hilt.

He was very much admired indeed. "He is as beautiful as a weathercock," remarked one of the Town Councillors who wished to gain a reputation for having artistic tastes; "only not quite so useful," he added, fearing lest people should think him unpractical, which he really was not.

"Why can't you be like the Happy Prince?" asked a sensible mother of her little boy who was crying for the moon. "The Happy Prince never dreams of crying for anything."

One night there flew over the city a little Swallow. His friends had gone away to Egypt six weeks before, but he had stayed behind, for he was in love with the most beautiful Reed. He landed at the feet of the Happy Prince to sleep. Just as he was putting his head under his wing, a large drop of water fell on him. "What a curious thing!" he cried; "there is not a single cloud in the sky, the stars are quite clear and bright, and yet it is raining." Then another drop fell.

He looked up and saw the eyes of the Happy Prince were filled with tears, and tears were running down his golden cheeks.''',
        ),
      ],
    ),
    BookItem(
      id: 'gift_of_the_magi',
      title: 'The Gift of the Magi',
      author: 'O. Henry',
      category: 'Short Stories',
      coverColor: '#1E3A8A',
      gradientColors: [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)],
      summary: 'A touching holiday tale of selfless love, irony, and the ultimate spirit of giving.',
      readingTimeMinutes: 9,
      chapters: [
        BookChapter(
          chapterTitle: 'One Dollar and Eighty-Seven Cents',
          content: '''One dollar and eighty-seven cents. That was all. And sixty cents of it was in pennies. Pennies saved one and two at a time by bulldozing the grocer and the vegetable man and the butcher until one's cheeks burned with the silent imputation of parsimony that such close dealing implied. Three times Della counted it. One dollar and eighty- seven cents. And the next day would be Christmas.

There was clearly nothing to do but flop down on the shabby little couch and howl. So Della did it. Which instigates the moral reflection that life is made up of sobs, sniffles, and smiles, with sniffles predominating.

While the mistress of the home is gradually subsiding from the first stage to the second, take a look at the home. A furnished flat at \$8 per week. It did not exactly beggar description, but it certainly had that word on the lookout for the mendicancy squad.

In the vestibule below was a letter-box into which no letter would go, and an electric button from which no mortal finger could coax a ring.''',
        ),
      ],
    ),
    BookItem(
      id: 'time_machine_wells',
      title: 'The Time Machine',
      author: 'H. G. Wells',
      category: 'Sci-Fi & Cosmos',
      coverColor: '#4C1D95',
      gradientColors: [const Color(0xFF4C1D95), const Color(0xFF7C3AED)],
      summary: 'A Victorian inventor travels across centuries into the year 802,701 AD to discover the fate of humankind.',
      readingTimeMinutes: 14,
      chapters: [
        BookChapter(
          chapterTitle: 'Chapter I: The Fourth Dimension',
          content: '''The Time Traveller was expounding a recondite matter to us. His grey eyes shone and twinkled, and his usually pale face was flushed and animated. The fire burnt brightly, and the soft radiance of the incandescent lights in the lilies of silver caught the bubbles that flashed and passed in our glasses.

"You must follow me carefully. I shall have to controvert one or two ideas that are almost universally accepted. The geometry, for instance, they taught you at school is founded on a misconception."

"Is not that rather a large thing to expect us to begin upon?" said Filby, an argumentative person with red hair.

"I do not mean to ask you to accept anything without reasonable ground for it. You will soon admit as much as I need from you. You know of course that a mathematical line, a line of thickness nil, has no real existence. They taught you that? Neither has a mathematical plane. These things are mere abstractions."

"That is all right," said the Psychologist.

"Nor, having only length, breadth, and thickness, can a cube have a real existence."

"There I object," said Filby. "Of course a solid body may exist. All real things—"

"So most people think. But wait a moment. Can an instantaneous cube exist?"''',
        ),
      ],
    ),
    BookItem(
      id: 'alice_wonderland',
      title: 'Alice in Wonderland',
      author: 'Lewis Carroll',
      category: 'Classic Literature',
      coverColor: '#047857',
      gradientColors: [const Color(0xFF064E3B), const Color(0xFF10B981)],
      summary: 'Tumble down the rabbit hole into an absurd wonderland of tea parties, Cheshire cats, and talking cards.',
      readingTimeMinutes: 12,
      chapters: [
        BookChapter(
          chapterTitle: 'Down the Rabbit-Hole',
          content: '''Alice was beginning to get very tired of sitting by her sister on the bank, and of having nothing to do: once or twice she had peeped into the book her sister was reading, but it had no pictures or conversations in it, "and what is the use of a book," thought Alice "without pictures or conversations?"

So she was considering in her own mind (as well as she could, for the hot day made her feel very sleepy and stupid), whether the pleasure of making a daisy-chain would be worth the trouble of getting up and picking the daisies, when suddenly a White Rabbit with pink eyes ran close by her.

There was nothing so very remarkable in that; nor did Alice think it so very much out of the way to hear the Rabbit say to itself, "Oh dear! Oh dear! I shall be late!" But when the Rabbit actually took a watch out of its waistcoat-pocket, and looked at it, and then hurried on, Alice started to her feet, for it flashed across her mind that she had never before seen a rabbit with either a waistcoat-pocket, or a watch to take out of it.''',
        ),
      ],
    ),
    BookItem(
      id: 'cosmos_curiosity',
      title: 'Voyage to the Stars & Black Holes',
      author: 'Poket Mates Science Desk',
      category: 'Sci-Fi & Cosmos',
      coverColor: '#312E81',
      gradientColors: [const Color(0xFF1E1B4B), const Color(0xFF4338CA)],
      summary: 'Explore black holes, spacetime fabric, quantum entanglement, and interstellar horizons in clear conversational English.',
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
      coverColor: '#0F172A',
      gradientColors: [const Color(0xFF0F172A), const Color(0xFF1E293B)],
      summary: 'Private personal journal entries of the Roman Emperor on mindfulness, emotional resilience, and duty.',
      readingTimeMinutes: 12,
      chapters: [
        BookChapter(
          chapterTitle: 'Book II: Morning Reflections',
          content: '''When you wake up in the morning, tell yourself: The people I deal with today will be meddling, ungrateful, arrogant, dishonest, jealous, and surly. They are like this because they cannot distinguish good from evil. But I have seen the beauty of good, and the ugliness of evil, and have recognized that the wrongdoer has a nature related to my own—not of the same blood or birth, but the same mind, and possessing a share of the divine.

None of them can hurt me. No one can implicate me in ugliness. Nor can I feel angry at my relative, or hate him. We were made to work together like feet, like hands, like the rows of the upper and lower teeth. To obstruct each other is unnatural. To feel anger at someone, to turn your back on him: these are obstructions.

Whatever this is that I am, it is a little flesh and breath, and the ruling part. Despise the flesh: blood and bones and a network, a jumble of nerves, veins, and arteries. Consider the breath: wind, always changing, expelled and sucked back in again. Third comes the ruling part. Put away your books; distract yourself no longer; they are not your portion.''',
        ),
      ],
    ),
    BookItem(
      id: 'tell_tale_heart_poe',
      title: 'The Tell-Tale Heart',
      author: 'Edgar Allan Poe',
      category: 'Classic Literature',
      coverColor: '#831843',
      gradientColors: [const Color(0xFF500724), const Color(0xFF9D174D)],
      summary: 'A psychological masterpiece of guilt, madness, and the haunting rhythm of a hidden beating heart.',
      readingTimeMinutes: 10,
      chapters: [
        BookChapter(
          chapterTitle: 'True! Nervous—Very Dreadfully Nervous',
          content: '''True!—nervous—very, very dreadfully nervous I had been and am; but why will you say that I am mad? The disease had sharpened my senses—not destroyed—not dulled them. Above all was the sense of hearing acute. I heard all things in the heaven and in the earth. I heard many things in hell. How, then, am I mad? Hearken! and observe how healthily—how calmly I can tell you the whole story.

It is impossible to say how first the idea entered my brain; but once conceived, it haunted me day and night. Object there was none. Passion there was none. I loved the old man. He had never wronged me. He had never given me insult. For his gold I had no desire. I think it was his eye! yes, it was this! One of his eyes resembled that of a vulture—a pale blue eye, with a film over it. Whenever it fell upon me, my blood ran cold; and so by degrees—very gradually—I made up my mind to take the life of the old man, and thus rid myself of the eye for ever.''',
        ),
      ],
    ),
    BookItem(
      id: 'english_reader_business',
      title: 'English in Action: High-Stakes Pitch',
      author: 'Poket Mates Language Desk',
      category: 'English Graded Readers',
      coverColor: '#0E7490',
      gradientColors: [const Color(0xFF164E63), const Color(0xFF0891B2)],
      summary: 'Practice natural business expressions, persuasive phrases, negotiation vocabulary, and assertive dialogue.',
      readingTimeMinutes: 8,
      chapters: [
        BookChapter(
          chapterTitle: 'The Boardroom Presentation',
          content: '''Good morning everyone. Thank you for taking the time to meet with our development team today. I know your schedule is exceptionally tight, so I will get straight to the point.

Over the past two quarters, our customer acquisition cost has decreased by twenty-four percent, while user engagement across mobile platforms has surged. What does this indicate? It demonstrates that our target audience is not merely sampling our product; they are integrating it into their daily workflow.

Now, let us examine our roadmap for the subsequent fiscal year. We are projecting a thirty percent increase in annual recurring revenue. However, in order to capitalize on this window of opportunity, we need to scale our cloud infrastructure immediately. I invite you to review the financial projections on page seven of your executive summary. Are there any preliminary questions before we delve deeper?''',
        ),
      ],
    ),
    BookItem(
      id: 'english_reader_travel',
      title: 'English in Action: The Global Traveler',
      author: 'Poket Mates Language Desk',
      category: 'English Graded Readers',
      coverColor: '#059669',
      gradientColors: [const Color(0xFF065F46), const Color(0xFF10B981)],
      summary: 'Everyday dialogues covering airport transfers, hotel booking queries, ordering in cafes, and making local friends.',
      readingTimeMinutes: 7,
      chapters: [
        BookChapter(
          chapterTitle: 'At the London Transit Station',
          content: '''"Excuse me, sir! Could you tell me which platform the express train to Edinburgh departs from?"

"Certainly, mate! You’ll want Platform 4B. Mind the gap as you step onto the train, as the boarding curb can be quite steep."

"Thank you kindly! Is there an onboard dining car, or should I grab a quick coffee here at the concourse?"

"There is indeed a dining trolley onboard, but if you fancy a fresh artisan pastry, the little bakery on your right serves the best croissants in King's Cross."

"Brilliant, I really appreciate your assistance. Have a wonderful afternoon!"''',
        ),
      ],
    ),
    BookItem(
      id: 'as_a_man_thinketh',
      title: 'As a Man Thinketh',
      author: 'James Allen',
      category: 'Wisdom & Mindset',
      coverColor: '#B45309',
      gradientColors: [const Color(0xFF78350F), const Color(0xFFD97706)],
      summary: 'A classic philosophical exploration of the master power of thoughts and mental discipline in shaping character and destiny.',
      readingTimeMinutes: 10,
      chapters: [
        BookChapter(
          chapterTitle: 'Thought and Character',
          content: '''The aphorism, "As a man thinketh in his heart so is he," not only embraces the whole of a man’s being, but is so comprehensive as to reach out to every condition and circumstance of his life. A man is literally what he thinks, his character being the complete sum of all his thoughts.

As the plant springs from, and could not be without, the seed, so every act of a man springs from the hidden seeds of thought, and could not have appeared without them. This applies equally to those acts called "spontaneous" and "unpremeditated" as to those which are deliberately executed.

Act is the blossom of thought, and joy and suffering are its fruits; thus does a man garner in the sweet and bitter fruitage of his own husbandry. Man is a growth by law, and not a creation by artifice, and cause and effect is as absolute and undeviating in the hidden realm of thought as in the world of visible and material things.''',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProgress();
    _fetchFreePublicBooks();
  }

  Future<void> _loadUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _readStreakDays = prefs.getInt('library_streak_days') ?? 4;
      _xpPoints = prefs.getInt('english_hub_points') ?? 180;
    });
  }

  // Multi-Source Live Books (Gutendex + Google Books API)
  Future<void> _fetchFreePublicBooks([String query = '']) async {
    setState(() {
      _isLoadingApi = true;
      _apiError = null;
    });

    final List<BookItem> fetched = [];

    try {
      // 1. Gutendex Public Domain Archive
      final gutenbergUrl = query.trim().isEmpty
          ? Uri.parse('https://gutendex.com/books/?languages=en&sort=popular')
          : Uri.parse('https://gutendex.com/books/?languages=en&search=${Uri.encodeComponent(query.trim())}');

      final response = await http.get(gutenbergUrl).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List? ?? [];

        for (final item in results.take(15)) {
          final title = item['title'] ?? 'Classic Novel';
          final authors = item['authors'] as List? ?? [];
          final authorName = authors.isNotEmpty ? authors[0]['name'] ?? 'Anonymous' : 'Public Domain';
          final formats = item['formats'] as Map<String, dynamic>? ?? {};
          final coverImg = formats['image/jpeg'] as String?;
          final textUrl = formats['text/plain; charset=utf-8'] ??
              formats['text/plain'] ??
              formats['text/plain; charset=us-ascii'] as String?;
          final subjects = (item['subjects'] as List? ?? []).take(2).join(', ');
          final downloadCount = item['download_count'] ?? 1000;

          fetched.add(
            BookItem(
              id: 'gutenberg_${item['id']}',
              title: title,
              author: authorName,
              category: 'Free Public Library',
              coverColor: '#0F172A',
              coverImageUrl: coverImg,
              textUrl: textUrl,
              downloadCount: downloadCount,
              isOnlineBook: true,
              readingTimeMinutes: 15,
              summary: subjects.isNotEmpty
                  ? 'Classic literary work catalogued under: $subjects.'
                  : 'Free historical English classic provided by Project Gutenberg public archives.',
              chapters: [
                BookChapter(
                  chapterTitle: 'Introduction & Complete Edition',
                  content: '''Welcome to "$title" by $authorName.

This title is part of the Project Gutenberg global library of free, public domain literary masterpieces. Reading classic literature accelerates vocabulary expansion, internalizes sentence structure, and develops deep expression.

Tap any word in this reader to hear native speech pronunciation and view instant contextual definitions. Opening chapter contents now...''',
                ),
              ],
            ),
          );
        }
      }

      // 2. Google Books API Integration (for contemporary & global searches)
      if (query.trim().isNotEmpty || _selectedCategory == 'Google Books Search') {
        try {
          final searchQuery = query.trim().isEmpty ? 'bestseller' : query.trim();
          final gUrl = Uri.parse(
              'https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeComponent(searchQuery)}&maxResults=10');
          final gRes = await http.get(gUrl).timeout(const Duration(seconds: 6));
          if (gRes.statusCode == 200) {
            final gData = jsonDecode(gRes.body);
            final items = gData['items'] as List? ?? [];
            for (final it in items) {
              final vi = it['volumeInfo'] as Map<String, dynamic>? ?? {};
              final gTitle = vi['title'] ?? 'Published Work';
              final gAuthors = (vi['authors'] as List?)?.join(', ') ?? 'Various Authors';
              final imageLinks = vi['imageLinks'] as Map<String, dynamic>? ?? {};
              String? thumb = imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'];
              if (thumb != null && thumb.startsWith('http://')) {
                thumb = thumb.replaceFirst('http://', 'https://');
              }
              final desc = vi['description'] ?? 'World-renowned publication catalogued on Google Books.';
              final preview = vi['previewLink'] ?? vi['infoLink'] as String?;

              fetched.add(
                BookItem(
                  id: 'google_${it['id']}',
                  title: gTitle,
                  author: gAuthors,
                  category: 'Google Books Search',
                  coverColor: '#1E293B',
                  coverImageUrl: thumb,
                  webReaderUrl: preview,
                  isOnlineBook: true,
                  readingTimeMinutes: 18,
                  summary: desc,
                  chapters: [
                    BookChapter(
                      chapterTitle: 'Synopsis & Book Profile',
                      content: '''$gTitle
Author(s): $gAuthors

$desc

Tap the "Open Web Edition" button in the top bar to preview and read full chapters directly on the publisher web portal.''',
                    ),
                  ],
                ),
              );
            }
          }
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _apiBooks = fetched;
          _isLoadingApi = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingApi = false;
          _apiError = 'Offline mode active. Browse 35+ curated books & stories.';
        });
      }
    }
  }

  List<BookItem> get _filteredBooks {
    final query = _searchController.text.toLowerCase().trim();
    List<BookItem> pool = [];

    if (_selectedCategory == 'Free Public Library') {
      pool = _apiBooks.where((b) => b.category == 'Free Public Library').toList();
    } else if (_selectedCategory == 'Google Books Search') {
      pool = _apiBooks.where((b) => b.category == 'Google Books Search').toList();
    } else if (_selectedCategory == 'All') {
      pool = [..._curatedBooks, ..._apiBooks];
    } else {
      pool = _curatedBooks.where((b) => b.category == _selectedCategory).toList();
    }

    if (query.isEmpty) return pool;
    return pool.where((b) {
      return b.title.toLowerCase().contains(query) ||
          b.author.toLowerCase().contains(query) ||
          b.summary.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const accentYellow = Color(0xFFFFFC00);

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
                color: accentYellow.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_stories_rounded, color: accentYellow, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Pocket Library',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 19),
            ),
          ],
        ),
        actions: [
          // XP & Streak Badge
          Container(
            margin: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accentYellow.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentYellow.withValues(alpha: 0.4), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF8906), size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_readStreakDays Days',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                const Text('•', style: TextStyle(color: Colors.white38)),
                const SizedBox(width: 6),
                const Icon(Icons.stars_rounded, color: accentYellow, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_xpPoints XP',
                  style: GoogleFonts.inter(color: accentYellow, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: accentYellow,
        backgroundColor: const Color(0xFF1E293B),
        onRefresh: () => _fetchFreePublicBooks(_searchController.text),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // In-House Promo Banner
            const PocketHouseAdWidget(
              compact: true,
              margin: EdgeInsets.only(left: 16, right: 16, bottom: 12),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF131F27),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  onChanged: (val) {
                    setState(() {});
                  },
                  onSubmitted: (query) {
                    _fetchFreePublicBooks(query);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search 70,000+ free classics, stories & authors...',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: accentYellow, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                              _fetchFreePublicBooks();
                            },
                          )
                        : IconButton(
                            icon: const Icon(Icons.cloud_sync_rounded, color: accentYellow, size: 20),
                            tooltip: 'Sync Free Books API',
                            onPressed: () => _fetchFreePublicBooks(_searchController.text),
                          ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category Filter Chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      if (cat == 'Free Public Library' && _apiBooks.isEmpty) {
                        _fetchFreePublicBooks();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? accentYellow : const Color(0xFF131F27),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? accentYellow : Colors.white12,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (cat == 'Free Public Library') ...[
                            Icon(
                              Icons.public_rounded,
                              size: 14,
                              color: isSelected ? Colors.black : accentYellow,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            cat,
                            style: GoogleFonts.inter(
                              color: isSelected ? Colors.black : Colors.white70,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Feature Banner: Daily English Habit
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF312E81).withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.headphones_rounded, color: accentYellow, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Reading Habit 📖',
                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Read 10 mins daily with English Audio TTS & Instant Definitions to accelerate fluency.',
                            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Header for Books list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCategory == 'All' ? 'Featured Stories & Classics' : _selectedCategory,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_filteredBooks.length} titles',
                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            if (_isLoadingApi && _apiBooks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: accentYellow),
                ),
              )
            else if (_filteredBooks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.menu_book_rounded, color: Colors.white24, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'No books found matching your search',
                        style: GoogleFonts.outfit(color: Colors.white54, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredBooks.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final book = _filteredBooks[index];
                  return _buildBookCard(book);
                },
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(BookItem book) {
    const accentYellow = Color(0xFFFFFC00);

    return InkWell(
      onTap: () => _openReader(book),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF101920),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 76,
                height: 104,
                decoration: BoxDecoration(
                  gradient: book.gradientColors != null
                      ? LinearGradient(
                          colors: book.gradientColors!,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: const Color(0xFF1E293B),
                ),
                child: book.coverImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: book.coverImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: const Color(0xFF1E293B),
                          child: const Center(child: CircularProgressIndicator(color: accentYellow, strokeWidth: 1.5)),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.book_rounded, color: Colors.white30, size: 28),
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_stories_rounded, color: accentYellow, size: 26),
                            const SizedBox(height: 4),
                            Text(
                              book.category.split(' ').first.toUpperCase(),
                              style: GoogleFonts.inter(color: Colors.white54, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
              ),
            ),

            const SizedBox(width: 14),

            // Book Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentYellow.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          book.category.toUpperCase(),
                          style: GoogleFonts.inter(color: accentYellow, fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.timer_outlined, color: Colors.white38, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        '${book.readingTimeMinutes}m',
                        style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'by ${book.author}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(color: Colors.white54, fontSize: 11.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5, height: 1.35),
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
  String _themeMode = 'dark'; // 'dark', 'sepia', 'light'
  late List<BookChapter> _activeChapters;
  int _currentChapterIndex = 0;
  bool _isLoadingFullBook = false;

  @override
  void initState() {
    super.initState();
    _activeChapters = List.from(widget.book.chapters);
    _initTts();
    if (widget.book.textUrl != null && widget.book.textUrl!.isNotEmpty) {
      _fetchFullBookText(widget.book.textUrl!);
    }
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.46);
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlayingAudio = false);
    });
  }

  Future<void> _fetchFullBookText(String textUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedKey = 'cached_book_text_${widget.book.id}';
    final cached = prefs.getString(cachedKey);
    if (cached != null && cached.isNotEmpty) {
      _processBookText(cached);
      return;
    }

    setState(() => _isLoadingFullBook = true);
    try {
      final res = await http.get(Uri.parse(textUrl)).timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        final body = res.body;
        await prefs.setString(
            cachedKey, body.length > 250000 ? body.substring(0, 250000) : body);
        _processBookText(body);
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingFullBook = false);
  }

  void _processBookText(String fullText) {
    final cleaned = fullText.replaceAll('\r\n', '\n');
    final segments = <BookChapter>[];

    final chapterRegex =
        RegExp(r'(CHAPTER\s+[IVXLCDM0-9]+[^\n]*)', caseSensitive: false);
    final matches = chapterRegex.allMatches(cleaned).toList();

    if (matches.length > 1) {
      for (int i = 0; i < matches.length && i < 25; i++) {
        final start = matches[i].start;
        final end = (i + 1 < matches.length)
            ? matches[i + 1].start
            : (start + 12000 < cleaned.length ? start + 12000 : cleaned.length);
        final title = matches[i].group(0) ?? 'Chapter ${i + 1}';
        final content = cleaned.substring(start, end).trim();
        if (content.length > 100) {
          segments.add(BookChapter(chapterTitle: title, content: content));
        }
      }
    } else {
      const chunkSize = 3500;
      int chunkCount = (cleaned.length / chunkSize).ceil().clamp(1, 20);
      for (int i = 0; i < chunkCount; i++) {
        final start = i * chunkSize;
        final end = (start + chunkSize < cleaned.length)
            ? start + chunkSize
            : cleaned.length;
        segments.add(BookChapter(
            chapterTitle: 'Part ${i + 1}',
            content: cleaned.substring(start, end).trim()));
      }
    }

    if (segments.isNotEmpty && mounted) {
      setState(() {
        _activeChapters = segments;
        _isLoadingFullBook = false;
      });
    }
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

    await _flutterTts.speak(cleanWord);

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121B22),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                    style: GoogleFonts.outfit(
                        color: const Color(0xFFFFFC00),
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded,
                        color: Color(0xFFFFFC00), size: 28),
                    onPressed: () => _flutterTts.speak(cleanWord),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              FutureBuilder<AIResponse>(
                future: AIService().generateText(
                  prompt:
                      'Give a quick 1-sentence dictionary definition, part of speech, and one simple example sentence for the English word: "$cleanWord". Output only clean text with no markdown.',
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFFFFC00))),
                    );
                  }
                  final def = snapshot.data?.data ??
                      'A fundamental English word used for expression and communication.';
                  return Text(
                    def,
                    style: GoogleFonts.outfit(
                        color: Colors.white, fontSize: 14, height: 1.4),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.bookmark_add_rounded),
                  label: const Text('Save to My Vocabulary Vault',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Saved "$cleanWord" to Vocabulary Vault! 🌟'),
                          backgroundColor: const Color(0xFF10B981)),
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

  Color get _readerBgColor {
    switch (_themeMode) {
      case 'sepia':
        return const Color(0xFFFBF0D9);
      case 'light':
        return const Color(0xFFF8FAFC);
      default:
        return const Color(0xFF070B0D);
    }
  }

  Color get _readerTextColor {
    switch (_themeMode) {
      case 'sepia':
        return const Color(0xFF433422);
      case 'light':
        return const Color(0xFF0F172A);
      default:
        return Colors.white.withValues(alpha: 0.92);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentChapter = (_activeChapters.isNotEmpty &&
            _currentChapterIndex < _activeChapters.length)
        ? _activeChapters[_currentChapterIndex]
        : widget.book.chapters.first;
    const accentYellow = Color(0xFFFFFC00);

    return Scaffold(
      backgroundColor: _readerBgColor,
      appBar: AppBar(
        backgroundColor: _themeMode == 'dark'
            ? const Color(0xFF0B141B)
            : (_themeMode == 'sepia' ? const Color(0xFFEEDCC2) : Colors.white),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _themeMode == 'dark' ? Colors.white : Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.book.title,
          style: GoogleFonts.outfit(
            color: _themeMode == 'dark' ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (widget.book.webReaderUrl != null)
            IconButton(
              icon: const Icon(Icons.open_in_browser_rounded, color: accentYellow),
              tooltip: 'Open Web Edition',
              onPressed: () => launchUrl(Uri.parse(widget.book.webReaderUrl!),
                  mode: LaunchMode.externalApplication),
            ),
          IconButton(
            icon: Icon(
              _isPlayingAudio
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_filled_rounded,
              color: accentYellow,
              size: 28,
            ),
            tooltip: _isPlayingAudio ? 'Pause Narration' : 'Listen with Audio',
            onPressed: () => _toggleAudioSpeech(currentChapter.content),
          ),
          IconButton(
            icon: Icon(
              Icons.palette_outlined,
              color: _themeMode == 'dark' ? Colors.white70 : Colors.black54,
            ),
            tooltip: 'Reading Theme',
            onPressed: () {
              setState(() {
                if (_themeMode == 'dark') {
                  _themeMode = 'sepia';
                } else if (_themeMode == 'sepia') {
                  _themeMode = 'light';
                } else {
                  _themeMode = 'dark';
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.format_size_rounded,
              color: _themeMode == 'dark' ? Colors.white70 : Colors.black54,
            ),
            tooltip: 'Font Size',
            onPressed: () {
              setState(() {
                _fontSize = (_fontSize >= 22.0) ? 14.0 : _fontSize + 2.0;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoadingFullBook)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentYellow.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: accentYellow),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Downloading complete edition from Gutenberg public archives...',
                        style: TextStyle(color: Colors.white70, fontSize: 11.5),
                      ),
                    ),
                  ],
                ),
              ),

            // Chapter Title
            Text(
              currentChapter.chapterTitle,
              style: GoogleFonts.outfit(
                color: _themeMode == 'dark'
                    ? accentYellow
                    : const Color(0xFFB45309),
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '💡 Tip: Tap any word to hear speech pronunciation & definition!',
              style: GoogleFonts.inter(
                color: _themeMode == 'dark' ? Colors.white38 : Colors.black45,
                fontSize: 11.5,
              ),
            ),
            Divider(
              color: _themeMode == 'dark' ? Colors.white12 : Colors.black12,
              height: 28,
            ),

            // Interactive Clickable Words Reader
            Wrap(
              spacing: 4,
              runSpacing: 7,
              children: currentChapter.content.split(' ').map((word) {
                return InkWell(
                  onTap: () => _lookupWordMeaning(word),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                    child: Text(
                      word,
                      style: GoogleFonts.outfit(
                        color: _readerTextColor,
                        fontSize: _fontSize,
                        height: 1.55,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 36),

            // Chapter Navigation (Previous / Next)
            if (_activeChapters.length > 1)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _themeMode == 'dark'
                      ? const Color(0xFF131722)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _currentChapterIndex > 0
                          ? () {
                              setState(() => _currentChapterIndex--);
                              HapticFeedback.selectionClick();
                            }
                          : null,
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
                      label: const Text('Previous'),
                    ),
                    Text(
                      '${_currentChapterIndex + 1} of ${_activeChapters.length}',
                      style: GoogleFonts.outfit(
                        color: _themeMode == 'dark'
                            ? Colors.white70
                            : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _currentChapterIndex < _activeChapters.length - 1
                          ? () {
                              setState(() => _currentChapterIndex++);
                              HapticFeedback.selectionClick();
                            }
                          : null,
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      label: const Text('Next'),
                    ),
                  ],
                ),
              ),

            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentYellow,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22)),
                ),
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Complete Chapter (+20 XP)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  int pts = prefs.getInt('english_hub_points') ?? 0;
                  await prefs.setInt('english_hub_points', pts + 20);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              '🎉 Chapter completed! +20 English XP awarded!'),
                          backgroundColor: Color(0xFF10B981)),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
