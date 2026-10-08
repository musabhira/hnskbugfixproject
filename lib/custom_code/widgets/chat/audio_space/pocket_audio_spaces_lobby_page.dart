import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_audio_space_engine.dart';
import 'pocket_audio_room_sheet.dart';

/// 🎙️ PocketAudioSpacesLobbyPage
/// Clubhouse / Twitter Spaces style live English lobby.
/// Learners can browse active live rooms, listen, or host their own voice stage.
class PocketAudioSpacesLobbyPage extends StatefulWidget {
  final bool showHeader;
  final bool enableSafeArea;

  const PocketAudioSpacesLobbyPage({
    super.key,
    this.showHeader = true,
    this.enableSafeArea = true,
  });

  @override
  State<PocketAudioSpacesLobbyPage> createState() =>
      _PocketAudioSpacesLobbyPageState();
}

class _PocketAudioSpacesLobbyPageState extends State<PocketAudioSpacesLobbyPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final PocketAudioSpaceEngine _engine = PocketAudioSpaceEngine.instance;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Beginner 🌱',
    'Casual ☕',
    'Debates 🔥',
    'Fluency ⚡',
    'Career & IELTS 💼',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        if (widget.showHeader) _buildTopBar(),
        _buildSearchBar(),
        _buildCategoryFilters(),
        Expanded(
          child: _buildSpacesStreamList(),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFF070B0D), // Deep rich dark
      body: widget.enableSafeArea ? SafeArea(bottom: false, child: content) : content,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showHostSpaceModal(context),
        backgroundColor: const Color(0xFFFFFC00),
        foregroundColor: Colors.black,
        elevation: 6,
        icon: const Text('☕', style: TextStyle(fontSize: 20)),
        label: Text(
          'Host Table (Max 4)',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _searchQuery.isNotEmpty
              ? const Color(0xFFFFFC00).withValues(alpha: 0.6)
              : const Color(0xFF1E293B),
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
        onChanged: (val) {
          setState(() {
            _searchQuery = val.trim();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search tables, topics, hosts...',
          hintStyle: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFFFFC00), size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF111726),
        border: Border(
          bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Text('🎙️', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'ENGLISH AUDIO SPACES',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFFC00),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF10B981),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  'Live peer English speaking & voice rooms',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;

          return ChoiceChip(
            label: Text(
              cat,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.black : Colors.white70,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            selected: isSelected,
            onSelected: (val) {
              setState(() {
                _selectedCategory = cat;
              });
            },
            selectedColor: const Color(0xFFFFFC00),
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? const Color(0xFFFFFC00) : const Color(0xFF334155),
              ),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _buildSpacesStreamList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _supabase
          .from('live_audio_spaces')
          .stream(primaryKey: ['id'])
          .eq('is_active', true)
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFFC00)),
          );
        }

        final rawList = snapshot.data ?? [];
        final query = _searchQuery.trim().toLowerCase();
        final filteredList = rawList.where((room) {
          if (_selectedCategory != 'All') {
            final roomCategory = room['category']?.toString() ?? '';
            final matchesCat = _selectedCategory.contains(roomCategory) ||
                roomCategory.contains(_selectedCategory.split(' ').first);
            if (!matchesCat) return false;
          }
          if (query.isNotEmpty) {
            final title = (room['title']?.toString() ?? '').toLowerCase();
            final topic = (room['topic']?.toString() ?? '').toLowerCase();
            final host = (room['host_name']?.toString() ?? '').toLowerCase();
            final category = (room['category']?.toString() ?? '').toLowerCase();
            return title.contains(query) ||
                topic.contains(query) ||
                host.contains(query) ||
                category.contains(query);
          }
          return true;
        }).toList();

        if (filteredList.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          itemCount: filteredList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final space = AudioSpaceModel.fromMap(filteredList[index]);
            return _buildSpaceCard(space);
          },
        );
      },
    );
  }

  Widget _buildSpaceCard(AudioSpaceModel space) {
    final isHostMe = space.hostUserId == _engine.myUserId;
    final occupiedSeats = math.min(space.participantCount, 4);
    final isFull = occupiedSeats >= 4;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111726),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHostMe
              ? const Color(0xFFFFFC00).withValues(alpha: 0.4)
              : const Color(0xFF1E293B),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            if (_engine.isInRoom && _engine.currentSpace?.id == space.id) {
              PocketAudioRoomSheet.show(context);
            } else {
              final myId = Supabase.instance.client.auth.currentUser?.id;
              final role = (space.hostUserId == myId)
                  ? AudioRole.host
                  : (space.participantCount < 4
                      ? AudioRole.speaker
                      : AudioRole.listener);
              await _engine.joinSpace(space, initialRole: role);
              if (mounted) {
                PocketAudioRoomSheet.show(context);
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Level Tag + Category + 4-Seat Status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF0EA5E9).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        space.levelTag,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF38BDF8),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '☕ 4-Seat Table',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),

                    // 4-Seat Status Dots
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(4, (i) => Container(
                          margin: const EdgeInsets.only(right: 3),
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: i < occupiedSeats ? const Color(0xFF10B981) : Colors.white24,
                            shape: BoxShape.circle,
                          ),
                        )),
                        const SizedBox(width: 4),
                        Text(
                          '$occupiedSeats/4',
                          style: GoogleFonts.outfit(
                            color: isFull ? Colors.orangeAccent : const Color(0xFF10B981),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  space.title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Topic
                Text(
                  space.topic,
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // Host info & Seats Action
                Row(
                  children: [
                    // Host Avatar
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFFC00), width: 1.5),
                      ),
                      child: ClipOval(
                        child: space.hostAvatar != null && space.hostAvatar!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: space.hostAvatar!,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => _buildHostInitial(space.hostName),
                              )
                            : _buildHostInitial(space.hostName),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hosted by ${space.hostName}',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Join Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFFC00).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('☕', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 6),
                          Text(
                            isFull ? 'Table Full' : 'Take Seat ($occupiedSeats/4)',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFFC00),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHostInitial(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'H';
    return Container(
      color: const Color(0xFF1E293B),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFC00).withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFFC00).withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Text('🎙️', style: TextStyle(fontSize: 38)),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No Active Voice Rooms',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to start an English discussion room! Host a stage, practice speaking, and learn with friends.',
              style: GoogleFonts.outfit(
                color: Colors.white54,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showHostSpaceModal(context),
              icon: const Text('🚀', style: TextStyle(fontSize: 16)),
              label: Text(
                'Start an English Space',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFC00),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHostSpaceModal(BuildContext context) {
    final titleController = TextEditingController(text: 'Daily English Chit-Chat');
    final topicController =
        TextEditingController(text: 'What made you smile today? Practice speaking freely!');
    String selectedCategory = 'Casual';
    String selectedLevel = 'All Levels';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '☕ Host 4-Seat English Chit-Chat Table',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Title Field
              TextField(
                controller: titleController,
                style: GoogleFonts.outfit(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Space Title',
                  labelStyle: GoogleFonts.outfit(color: Colors.white70),
                  hintText: 'e.g. Speed Speaking Circle',
                  hintStyle: GoogleFonts.outfit(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Topic Field
              TextField(
                controller: topicController,
                maxLines: 2,
                style: GoogleFonts.outfit(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Discussion Topic / Icebreaker',
                  labelStyle: GoogleFonts.outfit(color: Colors.white70),
                  hintText: 'e.g. Favorite movies or life lessons',
                  hintStyle: GoogleFonts.outfit(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category row
              Text(
                'Category',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Casual', 'Beginner', 'Debate', 'Career'].map((cat) {
                  final isSelected = selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) {
                      setModalState(() => selectedCategory = cat);
                    },
                    selectedColor: const Color(0xFFFFFC00),
                    backgroundColor: const Color(0xFF1E293B),
                    labelStyle: GoogleFonts.outfit(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Launch Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final space = await _engine.createSpace(
                      title: titleController.text,
                      topic: topicController.text,
                      category: selectedCategory,
                      levelTag: selectedLevel,
                    );
                    if (!mounted || space == null) return;
                    if (context.mounted) {
                      PocketAudioRoomSheet.show(context);
                    }
                  },
                  icon: const Text('🚀', style: TextStyle(fontSize: 18)),
                  label: Text(
                    'Launch Live Space',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFC00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
