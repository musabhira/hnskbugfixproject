import 'dart:io' as io;
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image/image.dart' as img;
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';

class StoryStickerItem {
  final String id;
  final String text;
  final String? emoji;
  final String? aura;
  double x;
  double y;
  double scale;
  final bool isAvatarSticker;
  final String? avatarExpression;

  StoryStickerItem({
    required this.id,
    required this.text,
    this.emoji,
    this.aura,
    this.x = 0.5,
    this.y = 0.5,
    this.scale = 1.0,
    this.isAvatarSticker = false,
    this.avatarExpression,
  });
}

class SnapchatStoryCreatorPage extends StatefulWidget {
  final String userId;
  final String profileId;
  final XFile? initialFile;
  final String? initialMediaType;
  final String? sharedContent;
  final String? sharedContentType;
  final Map<String, dynamic>? sharedMetadata;
  final VoidCallback? onStatusUploaded;

  const SnapchatStoryCreatorPage({
    super.key,
    required this.userId,
    required this.profileId,
    this.initialFile,
    this.initialMediaType,
    this.sharedContent,
    this.sharedContentType,
    this.sharedMetadata,
    this.onStatusUploaded,
  });

  @override
  State<SnapchatStoryCreatorPage> createState() => _SnapchatStoryCreatorPageState();
}

class _SnapchatStoryCreatorPageState extends State<SnapchatStoryCreatorPage> {
  final supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedFile;
  Uint8List? _imageBytes;
  String _mediaType = 'image';

  // Privacy: Public Story vs Pocket Mates Only (Private)
  bool _isPrivateStory = false;

  // Story Duration (5s, 10s, 15s)
  int _storyDuration = 5;

  // Active Filter index
  int _selectedFilterIndex = 0;
  final List<Map<String, dynamic>> _filters = [
    {'name': 'Normal', 'color': Colors.transparent, 'matrix': null},
    {
      'name': 'Sunset',
      'color': Colors.amber.withValues(alpha: 0.18),
      'matrix': [
        1.15, 0.0, 0.0, 0.0, 15.0,
        0.0, 1.05, 0.0, 0.0, 5.0,
        0.0, 0.0, 0.85, 0.0, -10.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    },
    {
      'name': 'Cyber Neon',
      'color': Colors.purpleAccent.withValues(alpha: 0.15),
      'matrix': [
        1.2, 0.0, 0.0, 0.0, 20.0,
        0.0, 0.9, 0.0, 0.0, 0.0,
        0.0, 0.0, 1.4, 0.0, 30.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    },
    {
      'name': 'Tokyo Noir',
      'color': Colors.black.withValues(alpha: 0.1),
      'matrix': [
        0.33, 0.33, 0.33, 0.0, 0.0,
        0.33, 0.33, 0.33, 0.0, 0.0,
        0.33, 0.33, 0.33, 0.0, 0.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    },
    {
      'name': 'Anime Pastel',
      'color': Colors.pinkAccent.withValues(alpha: 0.12),
      'matrix': [
        1.1, 0.0, 0.0, 0.0, 10.0,
        0.0, 1.15, 0.0, 0.0, 15.0,
        0.0, 0.0, 1.1, 0.0, 20.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    },
    {
      'name': 'Gold Hour',
      'color': const Color(0xFFFFD700).withValues(alpha: 0.15),
      'matrix': [
        1.2, 0.0, 0.0, 0.0, 25.0,
        0.0, 1.1, 0.0, 0.0, 15.0,
        0.0, 0.0, 0.7, 0.0, -15.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    },
    {
      'name': 'Matrix Code',
      'color': Colors.greenAccent.withValues(alpha: 0.15),
      'matrix': [
        0.8, 0.0, 0.0, 0.0, -20.0,
        0.0, 1.35, 0.0, 0.0, 30.0,
        0.0, 0.0, 0.8, 0.0, -20.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    },
    {
      'name': 'Retro VHS',
      'color': Colors.deepOrange.withValues(alpha: 0.12),
      'matrix': [
        1.25, 0.0, 0.0, 0.0, 10.0,
        0.0, 1.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.9, 0.0, 10.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    },
    {
      'name': 'Cinema 35mm',
      'color': const Color(0xFF2C3E50).withValues(alpha: 0.1),
      'matrix': [
        1.1, 0.0, 0.0, 0.0, -5.0,
        0.0, 1.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 1.2, 0.0, 15.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    },
    {
      'name': 'Emerald Glow',
      'color': Colors.tealAccent.withValues(alpha: 0.12),
      'matrix': [
        0.9, 0.0, 0.0, 0.0, 0.0,
        0.0, 1.25, 0.0, 0.0, 15.0,
        0.0, 0.0, 1.1, 0.0, 10.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    },
    {
      'name': 'Lavender Dream',
      'color': Colors.deepPurpleAccent.withValues(alpha: 0.15),
      'matrix': [
        1.15, 0.0, 0.0, 0.0, 20.0,
        0.0, 0.95, 0.0, 0.0, 0.0,
        0.0, 0.0, 1.35, 0.0, 25.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    },
  ];

  // Text Overlay State
  bool _isAddingText = false;
  final TextEditingController _textOverlayController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  Color _selectedTextColor = Colors.white;
  Color _selectedTextBg = Colors.black54;
  int _selectedFontStyleIndex = 0;
  final List<String> _fontStyles = ['Modern', 'Comic', 'Neon', 'Typewriter', 'Serif'];
  String _overlayText = '';

  // Stickers on Canvas
  final List<StoryStickerItem> _placedStickers = [];

  // Mentions
  String? _selectedGroupId;
  String? _selectedGroupName;
  String? _selectedProfileId;
  String? _selectedProfileName;

  // User's own Avatar
  VectorAvatarConfig _myAvatarConfig = const VectorAvatarConfig();

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  bool _showFiltersBar = false;

  // Photo Canvas Pan & Zoom Transformation Controller
  final TransformationController _transformController = TransformationController();

  @override
  void initState() {
    super.initState();
    _loadUserAvatar();
    if (widget.initialFile != null) {
      _selectedFile = widget.initialFile;
      _mediaType = widget.initialMediaType ?? 'image';
      _loadFileBytes();
    }
    // Canvas opens instantly with ZERO lag. User can pick image, record video, or use stickers on canvas.

    if (widget.sharedContent != null) {
      _captionController.text = widget.sharedContent!;
    }
  }

  Future<void> _loadUserAvatar() async {
    try {
      final res = await supabase
          .from('profile')
          .select('avatar_config')
          .eq('user_id', widget.userId)
          .maybeSingle();
      if (res != null && res['avatar_config'] != null && mounted) {
        setState(() {
          _myAvatarConfig = VectorAvatarConfig.fromMap(
              Map<String, dynamic>.from(res['avatar_config']));
        });
      }
    } catch (_) {}
  }

  Future<void> _loadFileBytes() async {
    if (_selectedFile == null) return;
    try {
      final bytes = await _selectedFile!.readAsBytes();
      if (mounted) {
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error reading file bytes: $e');
    }
  }

  Future<void> _pickMedia(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 95,
      );
      if (picked != null) {
        setState(() {
          _selectedFile = picked;
          _mediaType = 'image';
        });
        await _loadFileBytes();
      }
    } catch (e) {
      debugPrint('Error picking media: $e');
    }
  }

  @override
  void dispose() {
    _textOverlayController.dispose();
    _captionController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  TextStyle _getTextStyle() {
    switch (_selectedFontStyleIndex) {
      case 1:
        return GoogleFonts.bangers(
          color: _selectedTextColor,
          fontSize: 26,
          letterSpacing: 1.5,
        );
      case 2:
        return GoogleFonts.monoton(
          color: _selectedTextColor,
          fontSize: 24,
        );
      case 3:
        return GoogleFonts.courierPrime(
          color: _selectedTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        );
      case 4:
        return GoogleFonts.playfairDisplay(
          color: _selectedTextColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        );
      default:
        return GoogleFonts.outfit(
          color: _selectedTextColor,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        );
    }
  }

  void _openStickerPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Color(0xFF141418),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFFFFFC00), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Pocket Avatar & English Stickers',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12),
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      const TabBar(
                        indicatorColor: Color(0xFFFFFC00),
                        labelColor: Color(0xFFFFFC00),
                        unselectedLabelColor: Colors.white60,
                        tabs: [
                          Tab(text: '🎭 Avatars'),
                          Tab(text: '💥 SFX Badges'),
                          Tab(text: '📚 English Vibes'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // 1. Avatar Stickers
                            GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.9,
                              ),
                              itemCount: 9,
                              itemBuilder: (context, index) {
                                final expressions = [
                                  {'text': 'Let\'s Chat!', 'exp': 'happy', 'badge': '💬'},
                                  {'text': 'Grammar Pro 🎯', 'exp': 'winking', 'badge': '✨'},
                                  {'text': 'Super Star ⭐', 'exp': 'cool_glasses', 'badge': '🔥'},
                                  {'text': 'Good Morning ☀️', 'exp': 'excited', 'badge': '☕'},
                                  {'text': 'Level Up 🚀', 'exp': 'surprised', 'badge': '⚡'},
                                  {'text': 'High Five 🙌', 'exp': 'happy', 'badge': '🎉'},
                                  {'text': 'Word Power 📖', 'exp': 'thinking', 'badge': '🧠'},
                                  {'text': 'Speech Master 🎤', 'exp': 'excited', 'badge': '🏆'},
                                  {'text': 'Pocket Mate 💛', 'exp': 'cool_glasses', 'badge': '👑'},
                                ];
                                final item = expressions[index];

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _placedStickers.add(
                                        StoryStickerItem(
                                          id: 'avatar_${DateTime.now().millisecondsSinceEpoch}',
                                          text: item['text']!,
                                          emoji: item['badge'],
                                          isAvatarSticker: true,
                                          avatarExpression: item['exp'],
                                          x: 0.3 + (math.Random().nextDouble() * 0.4),
                                          y: 0.3 + (math.Random().nextDouble() * 0.3),
                                        ),
                                      );
                                    });
                                    Navigator.pop(context);
                                    HapticFeedback.lightImpact();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        VectorAvatarWidget(
                                          config: _myAvatarConfig.copyWith(
                                            mouthStyle: item['exp'] == 'laugh' ? 'laugh' : (item['exp'] == 'wink' ? 'smirk' : 'smile'),
                                            eyeStyle: item['exp'] == 'wink' ? 'wink' : (item['exp'] == 'fire' ? 'sparkle' : 'anime'),
                                          ),
                                          size: 48,
                                          showAura: true,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item['text']!,
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                            // 2. Comic SFX Badges
                            GridView.count(
                              padding: const EdgeInsets.all(16),
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              children: [
                                _buildComicBadgeOption('POW! 💥', const Color(0xFFFF2A6D)),
                                _buildComicBadgeOption('BOOM! 💣', const Color(0xFFFF8906)),
                                _buildComicBadgeOption('VIBE! ✨', const Color(0xFFFFFC00)),
                                _buildComicBadgeOption('POCKET! 🎒', const Color(0xFF00FF66)),
                                _buildComicBadgeOption('COOL! 😎', const Color(0xFF00E5FF)),
                                _buildComicBadgeOption('AHA! 💡', const Color(0xFFE056FD)),
                              ],
                            ),

                            // 3. English Learning Badges
                            ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                _buildEnglishPillOption('🗣️ Daily Speaking Challenge'),
                                _buildEnglishPillOption('🎯 Word of the Day: SERENDIPITY'),
                                _buildEnglishPillOption('⚡ 21-Day Streak Explorer'),
                                _buildEnglishPillOption('🎧 Practice Listening with Me'),
                              ],
                            ),
                          ],
                        ),
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

  Widget _buildComicBadgeOption(String text, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _placedStickers.add(
            StoryStickerItem(
              id: 'badge_${DateTime.now().millisecondsSinceEpoch}',
              text: text,
              aura: color.value.toString(),
              x: 0.4,
              y: 0.4,
            ),
          );
        });
        Navigator.pop(context);
        HapticFeedback.lightImpact();
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Text(
          text,
          style: GoogleFonts.bangers(
            color: color,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildEnglishPillOption(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: Colors.white.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: const Icon(Icons.school, color: Color(0xFFFFFC00)),
        title: Text(
          text,
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
        ),
        trailing: const Icon(Icons.add, color: Color(0xFFFFFC00)),
        onTap: () {
          setState(() {
            _placedStickers.add(
              StoryStickerItem(
                id: 'eng_${DateTime.now().millisecondsSinceEpoch}',
                text: text,
                x: 0.3,
                y: 0.5,
              ),
            );
          });
          Navigator.pop(context);
          HapticFeedback.lightImpact();
        },
      ),
    );
  }

  Future<void> _uploadStory() async {
    if (_isUploading) return;
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.1;
    });

    try {
      String mediaUrl = '';
      if (_selectedFile != null) {
        final bytes = _imageBytes ?? await _selectedFile!.readAsBytes();
        
        Uint8List bytesToUpload = bytes;
        // Fast compression only if image is huge (> 1.5MB) to avoid UI freezing
        if (bytes.lengthInBytes > 1500 * 1024) {
          try {
            img.Image? originalImage = img.decodeImage(bytes);
            if (originalImage != null) {
              final resized = img.copyResize(originalImage, width: 1080);
              bytesToUpload = Uint8List.fromList(img.encodeJpg(resized, quality: 80));
            }
          } catch (e) {
            debugPrint('Compression skipped/fallback: $e');
          }
        }

        setState(() => _uploadProgress = 0.5);

        final fileName = 'status_${widget.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        try {
          await supabase.storage.from('statuses').uploadBinary(
                fileName,
                bytesToUpload,
                fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
              ).timeout(const Duration(seconds: 15));

          mediaUrl = supabase.storage.from('statuses').getPublicUrl(fileName);
        } catch (storageErr) {
          debugPrint('Storage upload error: $storageErr');
          // If storage fails, fallback to base64 or continue
        }
        setState(() => _uploadProgress = 0.8);
      }

      // Metadata for overlay text & stickers
      final metadata = {
        'overlay_text': _overlayText.isNotEmpty ? _overlayText : null,
        'filter': _filters[_selectedFilterIndex]['name'],
        'duration': _storyDuration,
        'is_private': _isPrivateStory,
        'stickers': _placedStickers
            .map((s) => {
                  'text': s.text,
                  'emoji': s.emoji,
                  'is_avatar': s.isAvatarSticker,
                  'exp': s.avatarExpression,
                  'x': s.x,
                  'y': s.y,
                })
            .toList(),
      };

      final statusData = {
        'user_id': widget.userId,
        'profile_id': widget.profileId,
        'media_type': _selectedFile != null ? _mediaType : 'thought',
        'media_url': mediaUrl.isNotEmpty ? mediaUrl : (widget.sharedContent ?? ''),
        'caption': _captionController.text.trim().isEmpty ? null : _captionController.text.trim(),
        'metadata': metadata,
        'duration': _storyDuration,
        'expires_at': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
        'mentioned_group_id': _selectedGroupId,
        'mentioned_profile_id': _selectedProfileId,
        'is_active': true,
      };

      await supabase.from('statuses').insert(statusData).timeout(const Duration(seconds: 10));

      // Record activity points for Fortress Defense Credits
      PocketFortressDefenseService.recordActivityPoints('vibe_post');

      setState(() => _uploadProgress = 1.0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.black),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isPrivateStory
                        ? '🔒 Shared to Pocket Mates Story! (+15 FDC)'
                        : '🌟 Shared to Public Vibes! (+15 FDC)',
                    style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFFFFC00),
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onStatusUploaded?.call();
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Story upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading vibe: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = _filters[_selectedFilterIndex];
    final colorMatrix = filter['matrix'] as List<double>?;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Story Canvas Area with Snapchat-style horizontal swipe to switch filters
          Positioned.fill(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null && details.primaryVelocity!.abs() > 200) {
                  if (details.primaryVelocity! < 0) {
                    // Swipe Left -> Next Filter
                    setState(() {
                      _selectedFilterIndex = (_selectedFilterIndex + 1) % _filters.length;
                    });
                  } else {
                    // Swipe Right -> Previous Filter
                    setState(() {
                      _selectedFilterIndex = (_selectedFilterIndex - 1 + _filters.length) % _filters.length;
                    });
                  }
                  HapticFeedback.lightImpact();
                }
              },
              child: _imageBytes != null
                  ? ColorFiltered(
                      colorFilter: colorMatrix != null
                          ? ColorFilter.matrix(colorMatrix)
                          : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                      child: InteractiveViewer(
                        transformationController: _transformController,
                        minScale: 0.5,
                        maxScale: 4.0,
                        panEnabled: true,
                        scaleEnabled: true,
                        boundaryMargin: const EdgeInsets.all(150),
                        child: Center(
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1B182B), Color(0xFF090A10)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          VectorAvatarWidget(config: _myAvatarConfig, size: 90, showAura: true),
                          const SizedBox(height: 16),
                          Text(
                            'Pocket Mates Story Canvas',
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _pickMedia(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library, color: Colors.black),
                            label: const Text('Pick from Gallery', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFFC00)),
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
          ),

          // 2. Placed Stickers Overlay
          ..._placedStickers.map((sticker) {
            return Positioned(
              left: MediaQuery.of(context).size.width * sticker.x,
              top: MediaQuery.of(context).size.height * sticker.y,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    sticker.x += details.delta.dx / MediaQuery.of(context).size.width;
                    sticker.y += details.delta.dy / MediaQuery.of(context).size.height;
                  });
                },
                child: sticker.isAvatarSticker
                    ? Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFFC00), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            VectorAvatarWidget(
                              config: _myAvatarConfig.copyWith(
                                mouthStyle: sticker.avatarExpression == 'laugh' ? 'laugh' : (sticker.avatarExpression == 'wink' ? 'smirk' : 'smile'),
                                eyeStyle: sticker.avatarExpression == 'wink' ? 'wink' : 'anime',
                              ),
                              size: 40,
                              showAura: false,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              sticker.text,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFC00),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFFC00).withValues(alpha: 0.4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Text(
                          sticker.text,
                          style: GoogleFonts.bangers(
                            color: Colors.black,
                            fontSize: 18,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
              ),
            );
          }),

          // 3. User Text Overlay
          if (_overlayText.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              left: 20,
              right: 20,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedTextBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _overlayText,
                    style: _getTextStyle(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          // 4. Snapchat-style Active Filter Name HUD Pill
          if (_selectedFilterIndex != 0)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.6)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFFFFFC00), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        _filters[_selectedFilterIndex]['name'],
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 5. Top Header & Snapchat Tool Ribbon (Right Side)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close Button
                  CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Privacy Switch Indicator (Public vs Pocket Mates Only)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPrivateStory = !_isPrivateStory;
                      });
                      HapticFeedback.lightImpact();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isPrivateStory
                            ? const Color(0xFF00E5FF).withValues(alpha: 0.3)
                            : const Color(0xFFFFFC00).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isPrivateStory ? const Color(0xFF00E5FF) : const Color(0xFFFFFC00),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isPrivateStory ? Icons.lock_person : Icons.public,
                            color: _isPrivateStory ? const Color(0xFF00E5FF) : const Color(0xFFFFFC00),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isPrivateStory ? 'Pocket Mates Only 🔒' : 'Public Vibe 🌟',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right-side Snapchat Tools Ribbon
                  Column(
                    children: [
                      // Text Tool (Aa)
                      _buildToolIcon(
                        icon: Icons.title,
                        label: 'Text',
                        onTap: () => setState(() => _isAddingText = true),
                      ),
                      const SizedBox(height: 14),

                      // Stickers Tool
                      _buildToolIcon(
                        icon: Icons.sticky_note_2_rounded,
                        label: 'Stickers',
                        onTap: _openStickerPicker,
                      ),
                      const SizedBox(height: 14),

                      // Filter Carousel Toggle
                      _buildToolIcon(
                        icon: Icons.auto_awesome,
                        label: 'Filters',
                        isActive: _showFiltersBar,
                        onTap: () => setState(() => _showFiltersBar = !_showFiltersBar),
                      ),
                      const SizedBox(height: 14),

                      // Duration / Timer Tool
                      _buildToolIcon(
                        icon: Icons.timer,
                        label: '${_storyDuration}s',
                        onTap: () {
                          setState(() {
                            if (_storyDuration == 5) {
                              _storyDuration = 10;
                            } else if (_storyDuration == 10) {
                              _storyDuration = 15;
                            } else {
                              _storyDuration = 5;
                            }
                          });
                          HapticFeedback.lightImpact();
                        },
                      ),
                      const SizedBox(height: 14),

                      // Re-pick Image
                      _buildToolIcon(
                        icon: Icons.photo_library_outlined,
                        label: 'Media',
                        onTap: () => _pickMedia(ImageSource.gallery),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 5. Bottom Filter Carousel (when enabled)
          if (_showFiltersBar)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final f = _filters[index];
                    final isSelected = _selectedFilterIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedFilterIndex = index);
                        HapticFeedback.selectionClick();
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? const Color(0xFFFFFC00) : Colors.white24,
                                width: isSelected ? 2.5 : 1,
                              ),
                              gradient: const LinearGradient(
                                colors: [Colors.purple, Colors.orange],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            f['name'],
                            style: GoogleFonts.outfit(
                              color: isSelected ? const Color(0xFFFFFC00) : Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

          // 6. Bottom Story Action Bar (Post to Public vs Post to Mates)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.95), Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Caption bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _captionController,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Add a vibe story caption...',
                        hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Action Buttons (Post Story)
                  Row(
                    children: [
                      // User Avatar Thumbnail
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFFFC00), width: 1.5),
                        ),
                        child: VectorAvatarWidget(config: _myAvatarConfig, size: 42, showAura: true),
                      ),
                      const SizedBox(width: 12),

                      // Send to Story Button
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _isUploading ? null : _uploadStory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFFC00),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 4,
                            ),
                            child: _isUploading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          value: _uploadProgress,
                                          strokeWidth: 2,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Posting Vibe...',
                                        style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _isPrivateStory ? 'Post to Pocket Mates 🔒' : 'Post to Story 🌟',
                                        style: GoogleFonts.outfit(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.send_rounded, color: Colors.black, size: 18),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 7. Full-screen Text Editor Overlay (when typing text)
          if (_isAddingText)
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Font Style Switcher
                        DropdownButton<int>(
                          value: _selectedFontStyleIndex,
                          dropdownColor: const Color(0xFF262626),
                          underline: const SizedBox(),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFFFFC00)),
                          items: List.generate(
                            _fontStyles.length,
                            (index) => DropdownMenuItem(
                              value: index,
                              child: Text(
                                _fontStyles[index],
                                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedFontStyleIndex = val);
                          },
                        ),

                        // Done Button
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _overlayText = _textOverlayController.text.trim();
                              _isAddingText = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFC00),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text('Done', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Spacer(),
                    TextField(
                      controller: _textOverlayController,
                      autofocus: true,
                      style: _getTextStyle(),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Type something cool...',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                    ),
                    const Spacer(),
                    // Color bar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Colors.white,
                          const Color(0xFFFFFC00),
                          Colors.pinkAccent,
                          Colors.cyanAccent,
                          Colors.orangeAccent,
                          Colors.greenAccent,
                          Colors.purpleAccent,
                        ].map((c) {
                          return GestureDetector(
                            onTap: () => setState(() => _selectedTextColor = c),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedTextColor == c ? Colors.white : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolIcon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFFFFC00) : Colors.black45,
              shape: BoxShape.circle,
              border: Border.all(color: isActive ? const Color(0xFFFFFC00) : Colors.white38),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.black : Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
