import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image/image.dart' as img;

class SquadThemePreset {
  final String id;
  final String name;
  final IconData icon;
  final List<Color> gradientColors;
  final String defaultTag;

  const SquadThemePreset({
    required this.id,
    required this.name,
    required this.icon,
    required this.gradientColors,
    required this.defaultTag,
  });
}

class CreateGroupPage extends StatefulWidget {
  final VoidCallback onGroupCreated;

  const CreateGroupPage({super.key, required this.onGroupCreated});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  Uint8List? _selectedImageBytes;
  bool _isUsingCustomPhoto = false;

  // Selected Squad Theme Preset
  int _selectedThemeIndex = 0;
  final List<SquadThemePreset> _squadThemes = const [
    SquadThemePreset(
      id: 'english_champs',
      name: 'English Champions 🏆',
      icon: Icons.emoji_events_rounded,
      gradientColors: [Color(0xFFFFD700), Color(0xFFFF8906)],
      defaultTag: 'Speaking & Fluency',
    ),
    SquadThemePreset(
      id: 'cyber_tech',
      name: 'Cyber Coders ⚡',
      icon: Icons.terminal_rounded,
      gradientColors: [Color(0xFF00FF66), Color(0xFF00E5FF)],
      defaultTag: 'Tech & AI Chat',
    ),
    SquadThemePreset(
      id: 'coffee_chat',
      name: 'Coffee & Chill ☕',
      icon: Icons.coffee_rounded,
      gradientColors: [Color(0xFF8D6E63), Color(0xFFD7CCC8)],
      defaultTag: 'Casual Hangout',
    ),
    SquadThemePreset(
      id: 'comic_club',
      name: 'Comic Boomers 💥',
      icon: Icons.auto_awesome,
      gradientColors: [Color(0xFFFF2A6D), Color(0xFFFF8906)],
      defaultTag: 'Art & Stories',
    ),
    SquadThemePreset(
      id: 'bookworms',
      name: 'Book & Debate 📚',
      icon: Icons.menu_book_rounded,
      gradientColors: [Color(0xFF9C27B0), Color(0xFF3F51B5)],
      defaultTag: 'Grammar & Vocab',
    ),
    SquadThemePreset(
      id: 'global_travel',
      name: 'Global Voyagers ✈️',
      icon: Icons.flight_takeoff_rounded,
      gradientColors: [Color(0xFF00BCD4), Color(0xFF2196F3)],
      defaultTag: 'Travel & Culture',
    ),
    SquadThemePreset(
      id: 'secret_squad',
      name: 'Night Owls 🦉',
      icon: Icons.nightlight_round,
      gradientColors: [Color(0xFF311B92), Color(0xFF000000)],
      defaultTag: 'Late Night Chats',
    ),
  ];

  List<dynamic> _searchResults = [];
  final List<dynamic> _selectedMembers = [];

  bool _isCreating = false;
  bool _isSearching = false;
  bool _isImageUploading = false;
  bool _isPublicGroup = true;

  // Creator's Avatar
  VectorAvatarConfig _myAvatarConfig = const VectorAvatarConfig();

  @override
  void initState() {
    super.initState();
    _loadCreatorAvatar();
    _searchUsers('');
  }

  Future<void> _loadCreatorAvatar() async {
    try {
      final supabase = SupaFlow.client;
      final userId = supabase.auth.currentUser!.id;
      final res = await supabase
          .from('profile')
          .select('avatar_config')
          .eq('user_id', userId)
          .maybeSingle();
      if (res != null && res['avatar_config'] != null && mounted) {
        setState(() {
          _myAvatarConfig = VectorAvatarConfig.fromMap(
              Map<String, dynamic>.from(res['avatar_config']));
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _isImageUploading = true);
        final bytes = await image.readAsBytes();

        img.Image? decoded = img.decodeImage(bytes);
        if (decoded != null) {
          final resized = img.copyResize(decoded, width: 400, height: 400);
          final compressed = Uint8List.fromList(img.encodeJpg(resized, quality: 80));
          setState(() {
            _selectedImageBytes = compressed;
            _isUsingCustomPhoto = true;
            _isImageUploading = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isImageUploading = false);
    }
  }

  Future<void> _searchUsers(String query) async {
    setState(() => _isSearching = true);
    try {
      final supabase = SupaFlow.client;
      final currentUserId = supabase.auth.currentUser!.id;

      var q = supabase
          .from('profile')
          .select('id, user_id, name, profile_image_url, avatar_config')
          .neq('user_id', currentUserId);

      if (query.trim().isNotEmpty) {
        q = q.ilike('name', '%$query%');
      }

      final results = await q.limit(25);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _toggleMember(dynamic member) {
    setState(() {
      final exists = _selectedMembers.any((m) => m['id'] == member['id']);
      if (exists) {
        _selectedMembers.removeWhere((m) => m['id'] == member['id']);
      } else {
        _selectedMembers.add(member);
      }
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _createGroup() async {
    final groupName = _nameController.text.trim();
    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Group Name!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final supabase = SupaFlow.client;
      final userId = supabase.auth.currentUser!.id;

      final profileRes = await supabase
          .from('profile')
          .select('id')
          .eq('user_id', userId)
          .single();
      final currentUserProfileId = profileRes['id'];

      final activeTheme = _squadThemes[_selectedThemeIndex];

      final groupData = {
        'name': groupName,
        'description': _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : activeTheme.defaultTag,
        'created_by': userId,
        'is_public': _isPublicGroup,
      };

      final groupResponse =
          await supabase.from('groups').insert(groupData).select().single();
      final groupId = groupResponse['id'];

      // Upload Custom Photo if selected
      if (_selectedImageBytes != null && _isUsingCustomPhoto) {
        final fileName = 'group_${groupId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from('group_images').uploadBinary(
              fileName,
              _selectedImageBytes!,
              fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
            );
        final imageUrl = supabase.storage.from('group_images').getPublicUrl(fileName);
        await supabase.from('groups').update({'group_image_url': imageUrl}).eq('id', groupId);
      }

      // Add Creator as Admin
      final membersToAdd = <Map<String, dynamic>>[
        {
          'group_id': groupId,
          'profile_id': currentUserProfileId,
          'user_id': userId,
          'role': 'admin',
          'is_active': true,
        }
      ];

      // Add Selected Members
      for (final m in _selectedMembers) {
        membersToAdd.add({
          'group_id': groupId,
          'profile_id': m['id'],
          'user_id': m['user_id'],
          'role': 'member',
          'is_active': true,
        });
      }

      await supabase.from('group_members').insert(membersToAdd);

      widget.onGroupCreated();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.groups, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  '🎉 Squad "$groupName" created with ${_selectedMembers.length + 1} Mates!',
                  style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFFFFC00),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating squad: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTheme = _squadThemes[_selectedThemeIndex];
    final groupName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'New Pocket Squad';

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0D14),
        elevation: 0,
        title: Text(
          'Create Pocket Squad 👥',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 19),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Group Squad Avatar / Badge Generator Preview (Crest Shield)
            Center(
              child: Column(
                children: [
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: LinearGradient(
                        colors: [
                          ...activeTheme.gradientColors,
                          const Color(0xFF14141E),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: const Color(0xFFFFFC00), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: activeTheme.gradientColors.first.withValues(alpha: 0.45),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: _isUsingCustomPhoto && _selectedImageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.memory(
                              _selectedImageBytes!,
                              fit: BoxFit.cover,
                              width: 170,
                              height: 170,
                            ),
                          )
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              // Decorative Background Crest Rings
                              Positioned(
                                top: -20,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                ),
                              ),
                              // Multi-avatar 3D Depth squad formation
                              if (_selectedMembers.isNotEmpty)
                                Positioned(
                                  left: 12,
                                  top: 28,
                                  child: Transform.scale(
                                    scale: 0.85,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white38, width: 2),
                                      ),
                                      child: VectorAvatarWidget(
                                        config: _getMemberAvatarConfig(_selectedMembers.first),
                                        size: 46,
                                        showAura: false,
                                      ),
                                    ),
                                  ),
                                ),
                              if (_selectedMembers.length > 1)
                                Positioned(
                                  right: 12,
                                  top: 28,
                                  child: Transform.scale(
                                    scale: 0.85,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white38, width: 2),
                                      ),
                                      child: VectorAvatarWidget(
                                        config: _getMemberAvatarConfig(_selectedMembers[1]),
                                        size: 46,
                                        showAura: false,
                                      ),
                                    ),
                                  ),
                                ),
                              // Captain Avatar (Foreground Center)
                              Positioned(
                                top: 22,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFFFFC00), width: 2.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: VectorAvatarWidget(
                                    config: _myAvatarConfig,
                                    size: 58,
                                    showAura: true,
                                  ),
                                ),
                              ),
                              // Squad Emblem Ribbon
                              Positioned(
                                bottom: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F1016),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.6), width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.6),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(activeTheme.icon, color: const Color(0xFFFFFC00), size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${_selectedMembers.length + 1} SQUAD MATES',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    groupName,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '${activeTheme.name} • ${_isPublicGroup ? "Public English Squad 🌟" : "Private Pocket Squad 🔒"}',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),

                  // Avatar Mode vs Photo Mode Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isUsingCustomPhoto = false;
                            _selectedImageBytes = null;
                          });
                        },
                        icon: const Icon(Icons.auto_awesome, size: 15, color: Color(0xFFFFFC00)),
                        label: Text(
                          'Squad Avatar Badge',
                          style: GoogleFonts.outfit(
                            color: !_isUsingCustomPhoto ? const Color(0xFFFFFC00) : Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: !_isUsingCustomPhoto ? const Color(0xFFFFFC00) : Colors.white24,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: _selectImage,
                        icon: const Icon(Icons.photo_camera, size: 15, color: Colors.white),
                        label: Text(
                          'Upload Photo',
                          style: GoogleFonts.outfit(
                            color: _isUsingCustomPhoto ? const Color(0xFFFFFC00) : Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: _isUsingCustomPhoto ? const Color(0xFFFFFC00) : Colors.white24,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(color: Colors.white12),
            const SizedBox(height: 14),

            // 2. Squad Theme Picker Carousel
            Text(
              'Select Squad Theme & Badge Style',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _squadThemes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final themeItem = _squadThemes[index];
                  final isSelected = _selectedThemeIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedThemeIndex = index;
                        if (_descriptionController.text.isEmpty) {
                          _descriptionController.text = themeItem.defaultTag;
                        }
                      });
                      HapticFeedback.selectionClick();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(colors: themeItem.gradientColors)
                            : null,
                        color: isSelected ? null : const Color(0xFF1E202C),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFFFC00) : Colors.white12,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            themeItem.icon,
                            color: isSelected ? Colors.black : Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            themeItem.name,
                            style: GoogleFonts.outfit(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
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

            // 3. Name & Description Fields
            Text(
              'Squad Name',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161824),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _nameController,
                style: GoogleFonts.inter(color: Colors.white),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'e.g. Oxford Fluency Warriors 🎯',
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 14),
            Text(
              'Description / English Goals',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161824),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _descriptionController,
                style: GoogleFonts.inter(color: Colors.white),
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'What is this squad about? (Daily speaking, voice notes...)',
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 4. Privacy Toggle (Public vs Private)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF161824),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Icon(
                    _isPublicGroup ? Icons.public : Icons.lock_person,
                    color: _isPublicGroup ? const Color(0xFFFFFC00) : const Color(0xFF00E5FF),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isPublicGroup ? 'Public Squad 🌟' : 'Private Squad 🔒',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _isPublicGroup
                              ? 'Anyone can discover and join this English hub.'
                              : 'Only invited Pocket Mates can join.',
                          style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isPublicGroup,
                    activeColor: const Color(0xFFFFFC00),
                    onChanged: (val) => setState(() => _isPublicGroup = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // 5. Add Members Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Pocket Mates (${_selectedMembers.length} selected)',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                if (_selectedMembers.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() => _selectedMembers.clear()),
                    child: const Text('Clear All', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Selected Members Horizontal Chip List
            if (_selectedMembers.isNotEmpty)
              Container(
                height: 60,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedMembers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final member = _selectedMembers[index];
                    return Chip(
                      backgroundColor: const Color(0xFF1F2232),
                      side: const BorderSide(color: Color(0xFFFFFC00)),
                      avatar: VectorAvatarWidget(
                        config: _getMemberAvatarConfig(member),
                        size: 26,
                        showAura: false,
                      ),
                      label: Text(
                        member['name'] ?? 'Mate',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white70),
                      onDeleted: () => _toggleMember(member),
                    );
                  },
                ),
              ),

            // Search Mates Input
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161824),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(color: Colors.white),
                onChanged: _searchUsers,
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.white38, size: 20),
                  hintText: 'Search mates by name...',
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Search Results List
            _isSearching
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: Color(0xFFFFFC00)),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final member = _searchResults[index];
                      final isSelected = _selectedMembers.any((m) => m['id'] == member['id']);

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        leading: VectorAvatarWidget(
                          config: _getMemberAvatarConfig(member),
                          size: 42,
                          showAura: true,
                        ),
                        title: Text(
                          member['name'] ?? 'Pocket Mate',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isSelected ? Icons.check_circle : Icons.add_circle_outline,
                            color: isSelected ? const Color(0xFFFFFC00) : Colors.white38,
                          ),
                          onPressed: () => _toggleMember(member),
                        ),
                        onTap: () => _toggleMember(member),
                      );
                    },
                  ),

            const SizedBox(height: 30),

            // 6. Create Squad Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _createGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFC00),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: _isCreating
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                          ),
                          SizedBox(width: 10),
                          Text('Creating Squad...', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Create "${groupName}" (${_selectedMembers.length + 1} Mates)',
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, color: Colors.black, size: 18),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  VectorAvatarConfig _getMemberAvatarConfig(dynamic member) {
    if (member['avatar_config'] != null) {
      try {
        return VectorAvatarConfig.fromMap(Map<String, dynamic>.from(member['avatar_config']));
      } catch (_) {}
    }
    final nameHash = (member['name'] ?? 'Mate').hashCode.abs();
    final idHash = (member['id'] ?? 'id').hashCode.abs();
    final hairs = VectorAvatarPalette.hairStyles;
    final hairColors = VectorAvatarPalette.hairColors;
    final outfits = VectorAvatarPalette.outfitStyles;
    final auras = VectorAvatarPalette.auraStyles;

    return VectorAvatarConfig(
      hairStyle: hairs[nameHash % hairs.length]['id'],
      hairColor: hairColors[(idHash ~/ 3) % hairColors.length],
      outfitStyle: outfits[(nameHash ~/ 5) % outfits.length]['id'],
      auraStyle: auras[(idHash ~/ 7) % auras.length]['id'],
    );
  }
}
