import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Adult Track Games
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/sentence_builder_flame_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/pocket_essential_spelling_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/pocket_vocab_open_world_drive_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/meadow_runner_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/word_catcher_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/town_quest_dialogue_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/pocket_alphabet_balloon_sky_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_alphabet_phonics_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_mission_curriculum_registry.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/pocket_open_world_theory_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_house_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_house_defense_chat_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_english_house_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_world_ranking_trail_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_open_world_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_interactive_teacher_game.dart';

// Kids Games
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_game_session_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_day_open_world_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_house_challenge_page.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';

// 40 Universal Arcade Games
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/pocket_20days_40games_spec.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/pocket_universal_arcade_engine_page.dart';

// Career Adventure (15 Games)
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/career_adventure_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/adventure_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/city_navigator_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/city_navigator_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/cyber_vocab_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/cyber_vocab_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/memory_break_in_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/memory_break_in_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/word_factory_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/word_factory_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/signal_hunt_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/signal_hunt_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/lost_package_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/lost_package_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/busy_day_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/busy_day_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/fast_fix_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/fast_fix_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/market_master_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/market_master_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/word_detective_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/word_detective_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/voice_cafe_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/voice_cafe_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/message_runner_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/message_runner_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/bridge_builder_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/bridge_builder_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/travel_rush_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/travel_rush_models.dart';

// English Realm Games
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/english_realm/english_realm_game_session_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/english_realm/english_realm_data_p1.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/english_realm/english_realm_data_p2.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/english_realm/english_realm_data_p3.dart';

// Classic & External Games
import 'package:pocket_mates_app/custom_code/widgets/chess_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/poki_games_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/crazy_games_page.dart';

/// 🎮 Representation of an Admin Game Item
class AdminGameItem {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final String category; // 'Adult', 'Kids', 'Arcade', 'Career', 'Realm', 'Classic'
  final String engineBadge; // 'Flame', '2D Canvas', 'RPG', 'Audio/TTS', 'Arcade', 'Web'
  final Color primaryColor;
  final String descriptionEn;
  final String descriptionMl;
  final int minDay;
  final int maxDay;
  final bool hasDaySelection;
  final Future<void> Function(BuildContext context, int selectedDay) onPlay;

  const AdminGameItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.category,
    required this.engineBadge,
    required this.primaryColor,
    required this.descriptionEn,
    required this.descriptionMl,
    this.minDay = 1,
    this.maxDay = 90,
    this.hasDaySelection = false,
    required this.onPlay,
  });
}

/// 🕹️ Complete Admin Games Arena & Quality Control Hub
class AdminGamesHubWidget extends StatefulWidget {
  const AdminGamesHubWidget({super.key});

  @override
  State<AdminGamesHubWidget> createState() => _AdminGamesHubWidgetState();
}

class _AdminGamesHubWidgetState extends State<AdminGamesHubWidget> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final Map<String, int> _selectedDays = {};

  late final List<AdminGameItem> _allGames;

  @override
  void initState() {
    super.initState();
    _allGames = _buildComprehensiveGameRegistry();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getDayForGame(AdminGameItem game) {
    return _selectedDays[game.id] ?? game.minDay;
  }

  void _setDayForGame(AdminGameItem game, int day) {
    setState(() {
      _selectedDays[game.id] = day;
    });
  }

  List<AdminGameItem> get _filteredGames {
    return _allGames.where((game) {
      final matchesCategory = _selectedCategory == 'All' || game.category == _selectedCategory;
      if (!matchesCategory) return false;

      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return game.title.toLowerCase().contains(q) ||
          game.subtitle.toLowerCase().contains(q) ||
          game.descriptionEn.toLowerCase().contains(q) ||
          game.descriptionMl.toLowerCase().contains(q) ||
          game.engineBadge.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredGames;
    final totalGamesCount = _allGames.length;

    return Container(
      color: const Color(0xFF070B11),
      child: Column(
        children: [
          _buildHeaderBanner(totalGamesCount),
          _buildSearchBar(),
          _buildCategoryPills(),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _buildGameCard(filtered[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner(int totalCount) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Text('🎮', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'GAMES HUB & ARENA',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFC00),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$totalCount GAMES',
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Admin Quality Control: Direct play for all Adult, Kids, 40 Arcade, Career, English Realm & Classic games.',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search game name, genre, engine, or keywords...',
          hintStyle: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFFFFC00), size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF131D2A),
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFFFC00), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPills() {
    final categories = [
      {'id': 'All', 'label': 'All Games 🌟'},
      {'id': 'Adult', 'label': 'Adult Track 👨‍🎓'},
      {'id': 'Kids', 'label': 'Kids 100-Day 🦁'},
      {'id': 'Arcade', 'label': '40 Arcades 🕹️'},
      {'id': 'Career', 'label': 'Career 15 🚀'},
      {'id': 'Realm', 'label': 'Realm 180 🏰'},
      {'id': 'Classic', 'label': 'Classic & Web ♟️'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat['id'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(
                cat['label']!,
                style: GoogleFonts.outfit(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFFFFFC00),
              backgroundColor: const Color(0xFF131D2A),
              side: BorderSide(
                color: isSelected ? const Color(0xFFFFFC00) : Colors.white12,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onSelected: (val) {
                if (val) setState(() => _selectedCategory = cat['id']!);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGameCard(AdminGameItem game) {
    final currentDay = _getDayForGame(game);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF101826),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: game.primaryColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        game.primaryColor.withValues(alpha: 0.35),
                        game.primaryColor.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: game.primaryColor.withValues(alpha: 0.5)),
                  ),
                  alignment: Alignment.center,
                  child: Text(game.emoji, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              game.title,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: game.primaryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: game.primaryColor.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              game.engineBadge,
                              style: GoogleFonts.outfit(
                                color: game.primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        game.subtitle,
                        style: GoogleFonts.outfit(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Descriptions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (game.descriptionEn.isNotEmpty)
                  Text(
                    game.descriptionEn,
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11),
                  ),
                if (game.descriptionMl.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    game.descriptionMl,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFFC00).withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1, color: Colors.white10),

          // Action Bar (Day Picker + Direct Play Button)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            child: Row(
              children: [
                if (game.hasDaySelection) ...[
                  InkWell(
                    onTap: () => _showDayPickerDialog(game, currentDay),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFFFFFC00)),
                          const SizedBox(width: 6),
                          Text(
                            'Day $currentDay',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down_rounded, size: 16, color: Colors.white70),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ] else ...[
                  Text(
                    'Standalone / All Days',
                    style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11),
                  ),
                ],
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded, size: 18, color: Colors.black),
                  label: Text(
                    'PLAY / TEST',
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFC00),
                    foregroundColor: Colors.black,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    game.onPlay(context, currentDay);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDayPickerDialog(AdminGameItem game, int initialDay) {
    int tempDay = initialDay;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select Day for ${game.title}',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose any day from Day ${game.minDay} to Day ${game.maxDay}',
                    style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
                        onPressed: tempDay > game.minDay
                            ? () => setModalState(() => tempDay--)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFFFC00)),
                        ),
                        child: Text(
                          'DAY $tempDay',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFFC00),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
                        onPressed: tempDay < game.maxDay
                            ? () => setModalState(() => tempDay++)
                            : null,
                      ),
                    ],
                  ),
                  Slider(
                    value: tempDay.toDouble(),
                    min: game.minDay.toDouble(),
                    max: game.maxDay.toDouble(),
                    divisions: game.maxDay - game.minDay,
                    activeColor: const Color(0xFFFFFC00),
                    inactiveColor: Colors.white12,
                    onChanged: (val) {
                      setModalState(() => tempDay = val.toInt());
                    },
                  ),
                  Wrap(
                    spacing: 8,
                    children: [1, 5, 10, 20, 45, 60, 90, 100]
                        .where((d) => d >= game.minDay && d <= game.maxDay)
                        .map((d) {
                      final isSel = tempDay == d;
                      return ActionChip(
                        label: Text('Day $d', style: TextStyle(fontSize: 11, color: isSel ? Colors.black : Colors.white)),
                        backgroundColor: isSel ? const Color(0xFFFFFC00) : const Color(0xFF1E293B),
                        onPressed: () => setModalState(() => tempDay = d),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.white60)),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFC00),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            _setDayForGame(game, tempDay);
                            Navigator.pop(ctx);
                          },
                          child: Text('Apply Day $tempDay', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sports_esports_outlined, size: 56, color: Colors.white24),
          const SizedBox(height: 12),
          Text(
            'No matching games found',
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search query or category filter',
            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // COMPREHENSIVE GAME REGISTRY BUILDER
  // ───────────────────────────────────────────────────────────────────────────

  List<AdminGameItem> _buildComprehensiveGameRegistry() {
    final List<AdminGameItem> items = [];

    // =========================================================================
    // 1. ADULT TRACK GAMES (Days 1..90)
    // =========================================================================

    items.add(
      AdminGameItem(
        id: 'adult_sentence_builder',
        title: 'Sentence Builder (Flame Game)',
        subtitle: 'Word Block Stacking & Sentence Engineering',
        emoji: '🧱',
        category: 'Adult',
        engineBadge: 'Flame Engine',
        primaryColor: const Color(0xFF38BDF8),
        descriptionEn: 'Flame 2D physics engine for dragging, arranging, and validating complete English sentences.',
        descriptionMl: 'വാക്യങ്ങൾ ശരിയായ ക്രമത്തിൽ വെച്ച് നിർമ്മിക്കുന്ന ഫ്ലെയിം എൻജിൻ ഗെയിം.',
        minDay: 1,
        maxDay: 90,
        hasDaySelection: true,
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => PocketSentenceBuilderGamePage(day: day),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'adult_essential_spelling',
        title: 'Essential Spelling Challenge',
        subtitle: 'Letter Shuffle, Audio Pronunciation & XP Ring',
        emoji: '🔤',
        category: 'Adult',
        engineBadge: 'Audio / TTS',
        primaryColor: const Color(0xFFF59E0B),
        descriptionEn: 'Daily spelling mastery with interactive letter blocks, Malayalm hints, audio replay, and streak bonuses.',
        descriptionMl: 'സ്പെല്ലിംഗ് കേട്ട് അക്ഷരങ്ങൾ തെറ്റാതെ തെരഞ്ഞെടുക്കുന്ന ഗെയിം.',
        minDay: 1,
        maxDay: 90,
        hasDaySelection: true,
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => PocketEssentialSpellingPage(day: day),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'adult_vocab_open_world_drive',
        title: 'Vocab Open-World Drive',
        subtitle: 'Car / Bike / Rocket Vocabulary Runner',
        emoji: '🚗',
        category: 'Adult',
        engineBadge: 'Flame / Canvas',
        primaryColor: const Color(0xFF10B981),
        descriptionEn: 'Cruise down scenic highways, steer into correct vocabulary lanes, collect fuel points, and dodge obstacles.',
        descriptionMl: 'കാർ/ബൈക്ക്/റോക്കറ്റ് ഓടിച്ച് ശരിയായ വാക്കുകൾ കണ്ടെത്തുക.',
        minDay: 1,
        maxDay: 90,
        hasDaySelection: true,
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => PocketVocabOpenWorldDrivePage(day: day),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'adult_meadow_runner',
        title: 'Meadow Hunt Quest',
        subtitle: 'Alpine Explorer & Mystery Chest Discovery',
        emoji: '🌳',
        category: 'Adult',
        engineBadge: '2D Canvas',
        primaryColor: const Color(0xFF84CC16),
        descriptionEn: 'Explore lush green meadows, open golden mystery chests, and solve contextual English prompts.',
        descriptionMl: 'പച്ചപ്പ് നിറഞ്ഞ താഴ്‌വരയിൽ നിധിപ്പെട്ടി തുറന്ന് ചോദ്യങ്ങൾക്ക് ഉത്തരം നൽകുക.',
        hasDaySelection: false,
        onPlay: (ctx, day) async {
          final sampleRounds = [
            {
              "round": 1,
              "target": "apple",
              "prompt": {"en": "Find the Apple", "ml": "ആപ്പിൾ കണ്ടെത്തുക"},
              "options": ["Apple", "Orange", "Banana", "Grapes"],
              "correct": "Apple"
            },
            {
              "round": 2,
              "target": "car",
              "prompt": {"en": "Find the Car", "ml": "കാർ കണ്ടെത്തുക"},
              "options": ["Car", "Bus", "Bicycle", "Train"],
              "correct": "Car"
            },
            {
              "round": 3,
              "target": "house",
              "prompt": {"en": "Find the House", "ml": "വീട് കണ്ടെത്തുക"},
              "options": ["House", "Tower", "Bridge", "Castle"],
              "correct": "House"
            }
          ];
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => Scaffold(
                backgroundColor: const Color(0xFF0A1118),
                appBar: AppBar(
                  backgroundColor: const Color(0xFF0F172A),
                  title: Text('🌳 Meadow Hunt Quest', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
                body: MeadowRunnerGamePage(
                  rounds: sampleRounds,
                  initialRound: 0,
                  nativeLanguage: 'Malayalam',
                  isFullscreen: true,
                ),
              ),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'adult_word_catcher',
        title: 'Word Catcher (Falling Blocks)',
        subtitle: 'Arcade Basket & Rapid Reflex Word Catcher',
        emoji: '🧺',
        category: 'Adult',
        engineBadge: 'Arcade Physics',
        primaryColor: const Color(0xFFEC4899),
        descriptionEn: 'Catch falling English vocabulary items before they strike the ground, avoiding incorrect distractors.',
        descriptionMl: 'മേലെ നിന്ന് വീഴുന്ന വാക്കുകൾ കൊട്ടയിൽ പിടിക്കുന്ന ആർക്കേഡ് ഗെയിം.',
        hasDaySelection: false,
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const WordCatcherGamePage(),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'adult_town_quest_dialogue',
        title: 'Town Quest Dialogue RPG',
        subtitle: 'Interactive NPC Conversations across Town',
        emoji: '🏘️',
        category: 'Adult',
        engineBadge: 'RPG Dialogue',
        primaryColor: const Color(0xFF6366F1),
        descriptionEn: 'Explore bustling city districts, converse with colorful NPCs, and pick appropriate conversational replies.',
        descriptionMl: 'പട്ടണത്തിലെ ആളുകളുമായി ഇംഗ്ലീഷിൽ സംസാരിച്ചു മുന്നേറുന്ന RPG ഗെയിം.',
        minDay: 1,
        maxDay: 90,
        hasDaySelection: true,
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => TownQuestDialogueGamePage(day: day),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'adult_alphabet_balloon_sky',
        title: 'Alphabet Balloon Sky',
        subtitle: 'Floating Balloons & Voice Echo Practice',
        emoji: '🎈',
        category: 'Adult',
        engineBadge: 'Speech Recognition',
        primaryColor: const Color(0xFF06B6D4),
        descriptionEn: 'Gentle sky ascent with colorful letter balloons and microphone speech triggers.',
        descriptionMl: 'ആകാശത്തു പറക്കുന്ന ബലൂണുകളിലെ അക്ഷരങ്ങൾ പറഞ്ഞു പൊട്ടിക്കുന്ന ഗെയിം.',
        hasDaySelection: false,
        onPlay: (ctx, day) async {
          await PocketAlphabetBalloonSkyGamePage.show(ctx);
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'adult_alphabet_phonics',
        title: 'Alphabet & 44 Phonics Practice',
        subtitle: 'International Phonetic Sounds & Visual Guides',
        emoji: '🗣️',
        category: 'Adult',
        engineBadge: 'Phonics Guide',
        primaryColor: const Color(0xFFA855F7),
        descriptionEn: 'Master the 44 English phonics sounds, mouth shape diagrams, and voice comparison.',
        descriptionMl: 'ഇംഗ്ലീഷിലെ 44 ഫോണിക്‌സ് ശബ്ദങ്ങളും ശരിയായ ഉച്ചാരണവും പരിശീലിക്കുക.',
        minDay: 1,
        maxDay: 90,
        hasDaySelection: true,
        onPlay: (ctx, day) async {
          final list = PocketMissionCurriculumRegistry.getAlphabetPhonics(day);
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => PocketAlphabetPhonicsGamePage(
                day: day,
                selectedLanguage: 'Malayalam',
                phonicsList: list,
              ),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'adult_open_world_theory',
        title: 'Open World Theory Challenge',
        subtitle: 'Grammar Rules & Interactive Theory Trials',
        emoji: '📖',
        category: 'Adult',
        engineBadge: 'Interactive Quiz',
        primaryColor: const Color(0xFF14B8A6),
        descriptionEn: 'Interactive theory challenge with animated explanations, grammar breakdown, and XP scoring.',
        descriptionMl: 'തിയറിയും ഗ്രാമർ നിയമങ്ങളും എളുപ്പത്തിൽ പഠിക്കുന്ന ചലഞ്ച്.',
        minDay: 1,
        maxDay: 90,
        hasDaySelection: true,
        onPlay: (ctx, day) async {
          await PocketOpenWorldTheoryGamePage.launch(ctx, day: day);
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'adult_house_attack',
        title: 'Citadel Raid & Attack Game',
        subtitle: 'Tactical Raid with English Battle Traps',
        emoji: '⚔️',
        category: 'Adult',
        engineBadge: 'Battle Simulation',
        primaryColor: const Color(0xFFEF4444),
        descriptionEn: 'Raid rival houses by solving grammar and vocabulary questions to breach defenses.',
        descriptionMl: 'മറ്റു ഉപയോക്താക്കളുടെ വീടുകൾ റൈഡ് ചെയ്തു പോയിന്റ് നേടുക.',
        minDay: 1,
        maxDay: 90,
        hasDaySelection: true,
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => PocketHouseAttackPage(day: day),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'adult_house_defense',
        title: 'Citadel Defense Builder',
        subtitle: 'Shield Repair & Anti-Raid Question Bank',
        emoji: '🛡️',
        category: 'Adult',
        engineBadge: 'Defense Engine',
        primaryColor: const Color(0xFF3B82F6),
        descriptionEn: 'Fortify your estate with active shields, deploy defense questions, and repair damage.',
        descriptionMl: 'സ്വന്തം വീട് സംരക്ഷിക്കാൻ ഷീൽഡ് ഉറപ്പിക്കുകയും ചോദ്യങ്ങൾ സെറ്റ് ചെയ്യുകയും ചെയ്യുക.',
        minDay: 1,
        maxDay: 90,
        hasDaySelection: true,
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => PocketHouseDefenseChatPage(day: day),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'adult_flame_english_house',
        title: 'Flame English House Estate',
        subtitle: 'Dynamic 90-Day Estate Visual Progression',
        emoji: '🏰',
        category: 'Adult',
        engineBadge: 'Flame Visualizer',
        primaryColor: const Color(0xFFEAB308),
        descriptionEn: 'View the living estate citadel with smoke, ambient lighting, tier evolutions, and color palettes.',
        descriptionMl: 'ദിവസങ്ങൾ കൂടുന്തോറും വളരുന്ന വീടിന്റെ ഫ്ലെയിം ഗ്രാഫിക്സ് ഡിസൈൻ.',
        minDay: 1,
        maxDay: 90,
        hasDaySelection: true,
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => Scaffold(
                backgroundColor: const Color(0xFF0F172A),
                appBar: AppBar(
                  backgroundColor: const Color(0xFF1E293B),
                  title: Text('Flame Estate Day $day', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
                body: FlameEnglishHouseWidget(
                  currentDay: day,
                  showTestingControls: true,
                ),
              ),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'adult_motocross_trail',
        title: 'Motocross Canyon Trail (World Ranking)',
        subtitle: 'Flame Physics Bike Drive with Wall Cushion & Houses',
        emoji: '🏍️',
        category: 'Adult',
        engineBadge: 'Flame Physics',
        primaryColor: const Color(0xFF00FF66),
        descriptionEn: 'Drive your motocross bike down the majestic canyon summit to explore real-time houses on the valley floor.',
        descriptionMl: 'മലമുകളിൽ നിന്ന് താഴ്‌വരയിലെ വീടുകൾ വരെ ബൈക്കോടിച്ചു കാണുന്ന വേൾഡ് റാങ്കിംഗ് ഗെയിം.',
        hasDaySelection: false,
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => Scaffold(
                backgroundColor: const Color(0xFF071209),
                appBar: AppBar(
                  backgroundColor: const Color(0xFF0F172A),
                  title: Text('🏍️ Canyon Motocross Trail', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
                body: const PocketWorldRankingTrailWidget(mode: RankingTrailMode.world),
              ),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'adult_open_world_road',
        title: 'Open World Road Adventure',
        subtitle: 'Coastal Highway, Ocean Bridges & Neighbor Estates',
        emoji: '🌉',
        category: 'Adult',
        engineBadge: 'Flame 2D Engine',
        primaryColor: const Color(0xFF0284C7),
        descriptionEn: 'Seamless 2D scrolling world connecting all 90 days across suspension bridges, dolphins, and road stops.',
        descriptionMl: 'പാലങ്ങളും കടലുകളും താണ്ടി റോഡിലൂടെ പോകുന്ന ഓപ്പൺ വേൾഡ് അഡ്വഞ്ചർ.',
        minDay: 1,
        maxDay: 90,
        hasDaySelection: true,
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => PocketOpenWorldGamePage(currentDay: day, streak: 5),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'adult_interactive_teacher',
        title: 'Interactive AI Voice Teacher Game',
        subtitle: 'Flame Interactive Voice Speaking Game',
        emoji: '🧑‍🏫',
        category: 'Adult',
        engineBadge: 'Flame + Voice',
        primaryColor: const Color(0xFF8B5CF6),
        descriptionEn: 'Interactive voice teacher with dynamic classroom flame graphics, voice response, and step scoring.',
        descriptionMl: 'സംസാരിച്ചു ഗെയിം കളിച്ചുകൊണ്ട് ഇംഗ്ലീഷ് പഠിപ്പിക്കുന്ന ടീച്ചർ ഗെയിം.',
        minDay: 1,
        maxDay: 90,
        hasDaySelection: true,
        onPlay: (ctx, day) async {
          await PocketInteractiveTeacherGamePage.show(
            ctx,
            day: day,
            onCompleted: () {},
          );
        },
      ),
    );

    // =========================================================================
    // 2. KIDS TRACK GAMES (100 Days / 10 Mechanics)
    // =========================================================================

    items.add(
      AdminGameItem(
        id: 'kids_10_mechanics_session',
        title: 'Kids 10-Mechanics Game Session',
        subtitle: '10 Fun Child Mechanics across 100 Days',
        emoji: '🦁',
        category: 'Kids',
        engineBadge: 'Kids Engine',
        primaryColor: const Color(0xFFFFB300),
        descriptionEn: 'Includes Balloon Pop, Cargo Train, Animal Feast, Safari Memory, Slingshot, River Hopper, Spy Seek, Sentence Jigsaw, Voice Echo & Day 100 Lion Boss.',
        descriptionMl: 'കുട്ടികൾക്കായി 10 തരം ഗെയിമുകൾ (ട്രെയിൻ, ബലൂൺ, ഫ്രോഗ് ജമ്പ്, മെമ്മറി കാർഡുകൾ, ലയൺ ബോസ്സ്).',
        minDay: 1,
        maxDay: 100,
        hasDaySelection: true,
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => PocketKidsGameSessionPage(day: day),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'kids_sunny_mountain_open_world',
        title: 'Kids Sunny Mountain Open World',
        subtitle: 'Animated Sun, Rolling Hills & Castle Summit',
        emoji: '☀️',
        category: 'Kids',
        engineBadge: '2D Landscape',
        primaryColor: const Color(0xFF10B981),
        descriptionEn: 'Child-friendly sunny adventure world with smiling rotating sun, clouds, stepping stones, and star rewards.',
        descriptionMl: 'കുട്ടികളുടെ സുന്ദരമായ സണ്ണി മൗണ്ടൻ വേൾഡ്.',
        minDay: 1,
        maxDay: 100,
        hasDaySelection: true,
        onPlay: (ctx, day) async {
          await PocketKidsDayOpenWorldPage.open(ctx, day);
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'kids_friendly_house_challenge',
        title: 'Kids Friendly House Challenge',
        subtitle: 'Friendly Defense & Animal Buddy Raids',
        emoji: '🐾',
        category: 'Kids',
        engineBadge: 'Friendly Raid',
        primaryColor: const Color(0xFFF43F5E),
        descriptionEn: 'Gentle, friendly challenge where children pop 3 defense bubbles with speech hints to earn golden stars.',
        descriptionMl: 'കുട്ടികൾക്കായുള്ള സൗഹൃദപരമായ ഹൗസ് ചലഞ്ച്.',
        hasDaySelection: false,
        onPlay: (ctx, day) async {
          const defender = KidMate(
            id: 'leo_lion',
            name: 'Leo the Lion King',
            avatar: '🦁',
            dayLevel: 10,
            stars: 50,
            bio: 'Guardian of the Jungle Citadel',
            houseTier: 'Tier 5 Castle',
            challengeSentence: 'The brave lion protects the golden treasure!',
          );
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const PocketKidsHouseChallengePage(defender: defender),
            ),
          );
        },
      ),
    );

    // =========================================================================
    // 3. 20 DAYS 40 MULTI-GENRE ARCADE GAMES
    // =========================================================================

    for (final spec in Pocket20Days40GamesRegistry.allGames) {
      items.add(
        AdminGameItem(
          id: 'arcade_day_${spec.day}_g${spec.gameIndex}',
          title: 'Day ${spec.day}: ${spec.title}',
          subtitle: 'Genre: ${spec.genre.name.toUpperCase()} (Day ${spec.day} Game ${spec.gameIndex})',
          emoji: spec.emoji,
          category: 'Arcade',
          engineBadge: spec.genre.name.toUpperCase(),
          primaryColor: const Color(0xFF00E5FF),
          descriptionEn: '${spec.descriptionEn} • Target: ${spec.englishTarget}',
          descriptionMl: spec.descriptionMl,
          minDay: spec.day,
          maxDay: spec.day,
          hasDaySelection: false,
          onPlay: (ctx, day) async {
            await PocketUniversalArcadeEnginePage.launch(
              ctx,
              day: spec.day,
              gameIndex: spec.gameIndex,
              spec: spec,
            );
          },
        ),
      );
    }

    // =========================================================================
    // 4. CAREER ADVENTURE (15 GAMES)
    // =========================================================================

    items.add(
      AdminGameItem(
        id: 'career_m01_onboarding',
        title: 'Career M01: Office Onboarding',
        subtitle: 'Workplace Essentials & Virtual Office Exploration',
        emoji: '🏢',
        category: 'Career',
        engineBadge: 'RPG Adventure',
        primaryColor: const Color(0xFF6366F1),
        descriptionEn: 'Explore modern office workspaces, chat with coworkers, and learn essential corporate English.',
        descriptionMl: 'ഓഫീസ് ഇംഗ്ലീഷും ആശയവിനിമയങ്ങളും പഠിക്കുന്ന കരിയർ അഡ്വഞ്ചർ.',
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const CareerAdventureGamePage(levelData: kMission01LevelData),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'career_m02_city_navigator',
        title: 'Career M02: City Navigator',
        subtitle: 'Metropolitan Logistics & Transit Coordination',
        emoji: '🗺️',
        category: 'Career',
        engineBadge: 'Navigation RPG',
        primaryColor: const Color(0xFF06B6D4),
        descriptionEn: 'Navigate metro lines, interpret city signs, and assist travelers with transit directions.',
        descriptionMl: 'മെട്രോയും നഗര യാത്രകളും സംബന്ധിച്ച ഇംഗ്ലീഷ് ആശയവിനിമയം.',
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const CityNavigatorGamePage(levelData: kMission02CityData),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'career_m02b_cyber_vocab',
        title: 'Career M02B: Cyber Vocab Striker',
        subtitle: 'Tech Industry Vocabulary & Cyber Striker Action',
        emoji: '⚡',
        category: 'Career',
        engineBadge: 'Cyber Action',
        primaryColor: const Color(0xFF10B981),
        descriptionEn: 'Defend technical servers by striking matching terminology and decoding IT phrases.',
        descriptionMl: 'ഐടി/ടെക്നിക്കൽ വാക്കുകൾ വേഗത്തിൽ കണ്ടെത്തുന്ന സൈബർ ഗെയിം.',
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const CyberVocabGamePage(levelData: kMission02VocabStrikerData),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'career_m03_memory_breakin',
        title: 'Career M03: Server Room Memory Break-in',
        subtitle: 'Cybersecurity Memory Puzzles & Vault Security',
        emoji: '💾',
        category: 'Career',
        engineBadge: 'Memory Puzzle',
        primaryColor: const Color(0xFF8B5CF6),
        descriptionEn: 'Decrypt confidential encrypted vaults by recalling technical terms and sequential security codes.',
        descriptionMl: 'സെക്യൂരിറ്റി കോഡുകൾ ഓർത്തെടുത്ത് സിസ്റ്റം തുറക്കുന്ന ഗെയിം.',
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const MemoryBreakInGamePage(levelData: kMission03MemoryData),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'career_m04_word_factory',
        title: 'Career M04: Word Factory Assembly Line',
        subtitle: 'Industrial Assembly & Production Grammar',
        emoji: '🏭',
        category: 'Career',
        engineBadge: 'Factory Assembly',
        primaryColor: const Color(0xFFF59E0B),
        descriptionEn: 'Assemble precision phrases on conveyor belts to keep the manufacturing plant running.',
        descriptionMl: 'ഫാക്ടറിയിൽ വാക്കുകൾ ക്രമീകരിച്ചു പ്രൊഡക്ഷൻ നടത്തുന്ന ഗെയിം.',
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const WordFactoryGamePage(levelData: kMission04WordFactoryData),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'career_m05_signal_hunt',
        title: 'Career M05: Signal Hunt Communications',
        subtitle: 'Telecommunications & Radio Frequency Alignment',
        emoji: '📡',
        category: 'Career',
        engineBadge: 'Signal Hunt',
        primaryColor: const Color(0xFF38BDF8),
        descriptionEn: 'Locate broadcast signal frequencies and establish clear communication protocols.',
        descriptionMl: 'റേഡിയോ സിഗ്നലുകൾ ട്യൂൺ ചെയ്തു സന്ദേശങ്ങൾ കണ്ടെത്തുക.',
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const SignalHuntGamePage(levelData: kMission05SignalHuntData),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'career_m06_lost_package',
        title: 'Career M06: Warehouse Lost Package',
        subtitle: 'Supply Chain & High-Tech Parcel Retrieval',
        emoji: '📦',
        category: 'Career',
        engineBadge: 'Logistics RPG',
        primaryColor: const Color(0xFFE11D48),
        descriptionEn: 'Inspect logistics manifests, track missing inventory, and dispatch express packages.',
        descriptionMl: 'വെയർഹൗസിലെ കാണാതായ പാഴ്സലുകൾ തിരഞ്ഞുപിടിക്കുന്ന ഗെയിം.',
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const LostPackageGamePage(levelData: kMission06LostPackageData),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'career_m07_busy_day',
        title: 'Career M07: The Busy Day Operations',
        subtitle: 'Time Management, Agendas & Executive Scheduling',
        emoji: '📅',
        category: 'Career',
        engineBadge: 'Time Manager',
        primaryColor: const Color(0xFFD97706),
        descriptionEn: 'Prioritize meetings, resolve conflicting appointments, and handle urgent client calls.',
        descriptionMl: 'മീറ്റിംഗുകളും ഷെഡ്യൂളുകളും കൈകാര്യം ചെയ്യുന്ന എക്സിക്യൂട്ടീവ് ഗെയിം.',
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => BusyDayGamePage(levelData: kMission07BusyDayData),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'career_m08_fast_fix',
        title: 'Career M08: Fast Fix Workshop',
        subtitle: 'Hardware Diagnostics & Technical Troubleshooting',
        emoji: '🔧',
        category: 'Career',
        engineBadge: 'Workshop Flame',
        primaryColor: const Color(0xFF14B8A6),
        descriptionEn: 'Diagnose electronic faults, read schematics, and execute rapid repairs.',
        descriptionMl: 'വർക്ക്‌ഷോപ്പിലെ ഉപകരണങ്ങൾ ശരിയാക്കുന്ന ഗെയിം.',
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => FastFixGamePage(levelData: kMission08FastFixData),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'career_m09_market_master',
        title: 'Career M09: Market Master Negotiation',
        subtitle: 'Commerce, Pricing & Business Deals',
        emoji: '📈',
        category: 'Career',
        engineBadge: 'Negotiation RPG',
        primaryColor: const Color(0xFF10B981),
        descriptionEn: 'Negotiate contract terms, balance budgets, and strike successful international business deals.',
        descriptionMl: 'കച്ചവടവും ബിസിനസ്സ് ചർച്ചകളും നടത്തുന്ന ഗെയിം.',
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => MarketMasterGamePage(levelData: kMission09MarketMasterData),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'career_m10_word_detective',
        title: 'Career M10: Word Detective Crime Case',
        subtitle: 'Mystery Solving, Clue Analysis & Interrogations',
        emoji: '🔍',
        category: 'Career',
        engineBadge: 'Detective RPG',
        primaryColor: const Color(0xFFA855F7),
        descriptionEn: 'Interview suspects, analyze forensic crime scene clues, and deduce the true perpetrator.',
        descriptionMl: 'കുറ്റാന്വേഷണം നടത്തി രഹസ്യങ്ങൾ കണ്ടെത്തുന്ന ഗെയിം.',
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => WordDetectiveGamePage(levelData: kMission10WordDetectiveData),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'career_m11_voice_cafe',
        title: 'Career M11: Voice Cafe Hospitality',
        subtitle: 'Restaurant Service & Customer Experience',
        emoji: '☕',
        category: 'Career',
        engineBadge: 'Hospitality Flame',
        primaryColor: const Color(0xFFF97316),
        descriptionEn: 'Manage a cozy international cafe, take custom culinary orders, and delight demanding patrons.',
        descriptionMl: 'കഫേയിൽ ഓർഡറുകൾ എടുത്തു കസ്റ്റമർ സർവീസ് നൽകുന്ന ഗെയിം.',
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => VoiceCafeGamePage(levelData: kMission11VoiceCafeData),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'career_m12_message_runner',
        title: 'Career M12: Message Runner Express',
        subtitle: 'Diplomatic Dispatch & Fast Urban Courier',
        emoji: '🏃',
        category: 'Career',
        engineBadge: 'Courier Runner',
        primaryColor: const Color(0xFF06B6D4),
        descriptionEn: 'Dash through high-speed city avenues delivering time-sensitive diplomatic messages.',
        descriptionMl: 'നഗരത്തിലൂടെ സന്ദേശങ്ങൾ എത്തിക്കുന്ന സ്പീഡ് റണ്ണർ.',
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const MessageRunnerGamePage(levelData: kMission12MessageRunnerData),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'career_m13_bridge_builder',
        title: 'Career M13: Bridge Builder Construction',
        subtitle: 'Civil Engineering & Sentence Truss Bridges',
        emoji: '🏗️',
        category: 'Career',
        engineBadge: 'Civil Flame',
        primaryColor: const Color(0xFF38BDF8),
        descriptionEn: 'Erect suspension bridges by assembling grammatically sound word support trusses.',
        descriptionMl: 'പാലങ്ങൾ പണിതു ബന്ധങ്ങൾ സ്ഥാപിക്കുന്ന എൻജിനീയറിങ് ഗെയിം.',
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const BridgeBuilderGamePage(levelData: kMission13BridgeBuilderData),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'career_m14_travel_rush',
        title: 'Career M14: Airport & Transit Travel Rush',
        subtitle: 'Aviation Gate Control & International Travel',
        emoji: '✈️',
        category: 'Career',
        engineBadge: 'Airport Flame',
        primaryColor: const Color(0xFFEC4899),
        descriptionEn: 'Handle international flight check-ins, passport control, and gate changes during peak travel rush.',
        descriptionMl: 'വിമാനത്താവളത്തിലെ യാത്രകൾ നിയന്ത്രിക്കുന്ന ഗെയിം.',
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const TravelRushGamePage(levelData: kMission14TravelRushData),
            ),
          );
        },
      ),
    );

    // =========================================================================
    // 5. ENGLISH REALM (180 QUESTS ACROSS 9 REGIONS)
    // =========================================================================

    // Add representative game sessions for English Realm
    final allRealmSpecs = [
      ...englishRealmPhase1Games,
      ...englishRealmPhase2Games,
      ...englishRealmPhase3Games,
    ];

    for (final spec in allRealmSpecs) {
      items.add(
        AdminGameItem(
          id: spec.gameKey,
          title: 'Day ${spec.day}: ${spec.title}',
          subtitle: '${spec.regionId.replaceAll('_', ' ').toUpperCase()} (Game ${spec.gameIndex})',
          emoji: '🏰',
          category: 'Realm',
          engineBadge: 'Realm Quest',
          primaryColor: const Color(0xFFFFD700),
          descriptionEn: '${spec.descriptionEn} • Archetype: ${spec.archetype.name}',
          descriptionMl: spec.descriptionMl,
          minDay: spec.day,
          maxDay: spec.day,
          hasDaySelection: false,
          onPlay: (ctx, day) async {
            await EnglishRealmGameSessionPage.launch(ctx, spec: spec);
          },
        ),
      );
    }

    // =========================================================================
    // 6. CLASSIC & EXTERNAL WEB GAMES
    // =========================================================================

    items.add(
      AdminGameItem(
        id: 'classic_chess_ai',
        title: 'Chess (VS AI Practice)',
        subtitle: 'Practice against Pocket AI Chess Engine',
        emoji: '♟️',
        category: 'Classic',
        engineBadge: 'Chess AI',
        primaryColor: const Color(0xFFC084FC),
        descriptionEn: 'Full chessboard with piece movements, legal validation, captured tray, and AI engine.',
        descriptionMl: 'ആർട്ടിഫിഷ്യൽ ഇന്റലിജൻസുമായി ചെസ്സ് കളിക്കുക.',
        hasDaySelection: false,
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const ChessPlayPage(
                matchId: 'admin_ai_practice',
                isWhite: true,
                isAi: true,
              ),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'classic_chess_matchmaking',
        title: 'Chess (Multiplayer Matchmaking)',
        subtitle: 'Live Realtime PvP Chess with Mates',
        emoji: '🏆',
        category: 'Classic',
        engineBadge: 'Realtime PvP',
        primaryColor: const Color(0xFFA855F7),
        descriptionEn: 'Challenge online mates in real-time Supabase multiplayer chess matches.',
        descriptionMl: 'സുഹൃത്തുക്കളുമായി തത്സമയം ചെസ്സ് കളിക്കുക.',
        hasDaySelection: false,
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const ChessMatchmakingPage(),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'classic_poki_games',
        title: 'Poki Games Arena',
        subtitle: 'Curated Web Arcade with 1000+ Games',
        emoji: '🕹️',
        category: 'Classic',
        engineBadge: 'Web Arcade',
        primaryColor: const Color(0xFF00E5FF),
        descriptionEn: 'Integrated mobile webview browser featuring thousands of instant games.',
        descriptionMl: 'ഓൺലൈൻ മൾട്ടിപ്ലെയർ വെബ് ഗെയിംസ് അരീന.',
        hasDaySelection: false,
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const PokiGamesPage(),
            ),
          );
        },
      ),
    );

    items.add(
      AdminGameItem(
        id: 'classic_crazy_games',
        title: 'Crazy Games Arena',
        subtitle: 'Action, Racing & Multiplayer Web Games',
        emoji: '🏎️',
        category: 'Classic',
        engineBadge: 'Web Arcade',
        primaryColor: const Color(0xFF8B5CF6),
        descriptionEn: 'Popular external action and driving web arcade platform embedded in app.',
        descriptionMl: 'ആക്ഷൻ & ഡ്രൈവിംഗ് ക്രേസി ഗെയിംസ്.',
        hasDaySelection: false,
        onPlay: (ctx, day) async {
          await Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const CrazyGamesPage(),
            ),
          );
        },
      ),
    );

    return items;
  }
}
