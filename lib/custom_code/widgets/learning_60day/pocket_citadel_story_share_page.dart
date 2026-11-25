import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';

import 'pocket_world_street_page.dart';
import 'flame_english_house_game.dart';
import 'painters/citadel_scenic_landscape_painter.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_top_rank_theme.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_citadel_video_export_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/president_avatar_widget.dart';
import '../avatar/vector_avatar_config.dart';
import '../avatar/vector_avatar_widget.dart';

/// 📐 Three Social Aspect Ratios with generous 540p / 1080p target scales
enum CitadelStoryAspectRatio {
  story9x16(9 / 16, 360.0, 640.0, 'Story (9:16)', Icons.stay_current_portrait_rounded),
  feedPortrait4x5(4 / 5, 432.0, 540.0, 'Portrait (4:5)', Icons.crop_portrait_rounded),
  square1x1(1 / 1, 540.0, 540.0, 'Square (1:1)', Icons.crop_square_rounded);

  final double ratio;
  final double designWidth;
  final double designHeight;
  final String label;
  final IconData icon;

  const CitadelStoryAspectRatio(
    this.ratio,
    this.designWidth,
    this.designHeight,
    this.label,
    this.icon,
  );
}

/// 📸 High-Aesthetic Full-Screen Citadel Story Card Preview & Sharing Page
/// Features:
/// - 3 Aspect Ratios: Story (9:16), Portrait (4:5), Square (1:1)
/// - 12 Unique Aesthetic Templates:
///   1. Scrapbook Desk Poster (Image 1 Style - clean without marker doodle)
///   2. Vintage Polaroid Keepsake
///   3. Cinematic Showcase
///   4. Spiral Notebook Journal (Fixed clean footer)
///   5. Airmail Expedition Postcard (Fixed clean footer)
///   6. Nordic Editorial Art Book (Brand new luxury architectural design)
///   7. Washi Moodboard Collage (Fixed clean footer)
///   8. Minimalist Japanese Editorial
///   9. Cosmic Celestial Observatory
///   10. Retro Daily Chronicle
///   11. Retro Instant Film (Fujifilm Instax / Warm Memory)
///   12. Pocket Cosmic Passport (Visa Entry Stamp & Coordinates)
/// - True Horizontal Card Carousel with peek edges & smooth swipe
/// - Direct Download to user's Downloads folder (Windows, Android, iOS) with auto-reveal
/// - Background Music (BGM) with live audio toggle
/// - Minimal, compact bottom action bar
class PocketCitadelStorySharePage extends StatefulWidget {
  final PocketNeighbor neighbor;
  final int level;
  final int pocketScore;
  final int? globalRank;
  final bool isNight;

  const PocketCitadelStorySharePage({
    super.key,
    required this.neighbor,
    required this.level,
    required this.pocketScore,
    this.globalRank,
    this.isNight = false,
  });

  @override
  State<PocketCitadelStorySharePage> createState() => _PocketCitadelStorySharePageState();
}

class _PocketCitadelStorySharePageState extends State<PocketCitadelStorySharePage> {
  final GlobalKey _cardKey = GlobalKey();
  CitadelStoryAspectRatio _selectedFormat = CitadelStoryAspectRatio.story9x16;
  int _currentTemplateIndex = 0;
  late final PageController _pageController;

  bool _isExporting = false;
  String _exportStatusText = '';
  bool _isBgmMuted = false;

  final List<String> _templateTitles = [
    'Scrapbook Desk Poster',
    'Vintage Polaroid',
    'Cinematic Showcase',
    'Spiral Notebook Journal',
    'Airmail Postcard',
    'Nordic Editorial Art',
    'Washi Moodboard Collage',
    'Japanese Editorial',
    'Cosmic Observatory',
    'Retro Daily Chronicle',
    'Retro Instant Film',
    'Cosmic Passport Visa',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.86,
    );
    _initAudio();
  }

  void _initAudio() {
    try {
      PocketGameAudioService.instance.playAmbientBgm();
      _isBgmMuted = PocketGameAudioService.instance.isMutedNotifier.value;
    } catch (_) {}
  }

  void _toggleBgm() {
    HapticFeedback.lightImpact();
    setState(() {
      _isBgmMuted = !_isBgmMuted;
      PocketGameAudioService.instance.isMutedNotifier.value = _isBgmMuted;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<Directory> _getExportDirectory() async {
    if (Platform.isWindows) {
      try {
        final downloads = await getDownloadsDirectory();
        if (downloads != null && downloads.existsSync()) return downloads;
      } catch (_) {}
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        final winDownloads = Directory('$userProfile\\Downloads');
        if (winDownloads.existsSync()) return winDownloads;
      }
    } else if (Platform.isAndroid) {
      try {
        final downloads = await getDownloadsDirectory();
        if (downloads != null && downloads.existsSync()) return downloads;
      } catch (_) {}
      try {
        final ext = await getExternalStorageDirectory();
        if (ext != null && ext.existsSync()) return ext;
      } catch (_) {}
    }
    return await getApplicationDocumentsDirectory();
  }

  Future<File?> _captureCardImage({double? pixelRatio}) async {
    try {
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final double ratio = pixelRatio ?? 6.0;
      final ui.Image image = await boundary.toImage(pixelRatio: ratio);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final safeName = widget.neighbor.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final templateSafe = _templateTitles[_currentTemplateIndex].replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
      final fileName = 'PoketMates_${templateSafe}_${safeName}_Day${widget.level}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pngBytes, flush: true);
      return file;
    } catch (e) {
      debugPrint('Story card capture error: $e');
      return null;
    }
  }

  Future<void> _showSaveQualitySheet() async {
    if (_isExporting) return;
    double selectedRatio = 6.0; // Default: High / Ultra HD

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141210),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget buildOption({
              required String title,
              required String subtitle,
              required double ratio,
              String? badge,
            }) {
              final isSelected = selectedRatio == ratio;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setModalState(() => selectedRatio = ratio);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFD95D39).withValues(alpha: 0.14)
                        : const Color(0xFF1E1B18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFD95D39)
                          : Colors.white12,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: isSelected
                            ? const Color(0xFFD95D39)
                            : Colors.white38,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  title,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (badge != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD4A373)
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      badge,
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFD4A373),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: GoogleFonts.inter(
                                color: Colors.white54,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Select Image Quality',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose export resolution for your Story Card',
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 14),
                    buildOption(
                      title: 'Ultra HD (4K)',
                      subtitle: 'Maximum sharpness for Instagram & WhatsApp Status',
                      ratio: 6.0,
                      badge: 'DEFAULT',
                    ),
                    buildOption(
                      title: 'High HD (2K)',
                      subtitle: 'Crisp quality with balanced file size',
                      ratio: 4.0,
                    ),
                    buildOption(
                      title: 'Standard HD (1080p)',
                      subtitle: 'Fast export & lightweight file',
                      ratio: 3.0,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD95D39),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _downloadImage(pixelRatio: selectedRatio);
                      },
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: Text(
                        'Save Image',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _downloadImage({double pixelRatio = 6.0}) async {
    if (_isExporting) return;
    setState(() {
      _isExporting = true;
      _exportStatusText =
          pixelRatio >= 6.0 ? 'Saving Ultra HD Image...' : 'Saving HD Image...';
    });
    HapticFeedback.mediumImpact();

    try {
      final file = await _captureCardImage(pixelRatio: pixelRatio);
      if (file == null) throw Exception('Could not render image');

      final targetDir = await _getExportDirectory();
      final permanentPath = '${targetDir.path}${Platform.pathSeparator}${file.uri.pathSegments.last}';
      await file.copy(permanentPath);

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        try {
          await Gal.putImage(permanentPath, album: 'PoketMates');
        } catch (galErr) {
          debugPrint('Gal image save notice: $galErr');
        }
      }

      if (Platform.isWindows) {
        try {
          Process.run('explorer.exe', ['/select,', permanentPath]);
        } catch (_) {}
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  Platform.isWindows
                      ? 'Saved to Downloads: ${file.uri.pathSegments.last} 📸'
                      : 'Saved to Gallery & Downloads: ${file.uri.pathSegments.last} 📸',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          content: Text('Failed to save: $e', style: GoogleFonts.outfit(color: Colors.white)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  static const List<Map<String, String>> _availableBgmTracks = [
    {
      'title': 'Happy Whistler',
      'mood': '☀️ Cheerful & Uplifting',
      'asset': 'assets/audio/bgm/happy_whistler.mp3',
    },
    {
      'title': 'Adventure Quest',
      'mood': '🗺️ Epic Journey & Heroic',
      'asset': 'assets/audio/bgm/adventure_quest.mp3',
    },
    {
      'title': 'Speedy Duel',
      'mood': '⚔️ Fast & Energetic Battle',
      'asset': 'assets/audio/bgm/speedy_duel.mp3',
    },
    {
      'title': 'Citadel Defense',
      'mood': '🛡️ Majestic Sovereign Guard',
      'asset': 'assets/audio/bgm/citadel_defense.mp3',
    },
    {
      'title': 'Dancing Stardust',
      'mood': '✨ Magical & Dreamy',
      'asset': 'assets/audio/bgm/dancing_stardust.mp3',
    },
    {
      'title': 'Pocket Sailor',
      'mood': '⛵ Oceanic Breeze & Chill',
      'asset': 'assets/audio/bgm/pocket_sailor.mp3',
    },
    {
      'title': 'Market Square',
      'mood': '🎪 Lively Town Square',
      'asset': 'assets/audio/bgm/market_square.mp3',
    },
    {
      'title': 'Arcade Retro',
      'mood': '🕹️ 8-Bit Pixel Nostalgia',
      'asset': 'assets/audio/bgm/arcade_short.mp3',
    },
    {
      'title': 'Peaceful Lullaby',
      'mood': '🍃 Serene & Calming',
      'asset': 'assets/audio/bgm/peaceful_lullaby.mp3',
    },
    {
      'title': 'Run & Catch',
      'mood': '🏃‍♂️ Playful & Fast',
      'asset': 'assets/audio/bgm/run_and_catch.mp3',
    },
  ];

  String _selectedBgmAsset = 'assets/audio/bgm/happy_whistler.mp3';
  String? _previewingTrackAsset;

  Future<void> _showBgmSelectionModal() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141210),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.72,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
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
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Story Music 🎵',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pick background track for your 15s Story/Reel',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFFD4A373),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        onPressed: () {
                          PocketGameAudioService.instance.stop();
                          _previewingTrackAsset = null;
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _availableBgmTracks.length,
                      itemBuilder: (context, idx) {
                        final track = _availableBgmTracks[idx];
                        final asset = track['asset']!;
                        final isSelected = _selectedBgmAsset == asset;
                        final isPlaying = _previewingTrackAsset == asset;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2E1F18) : const Color(0xFF1C1917),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFF59E0B)
                                  : Colors.white.withValues(alpha: 0.08),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: ListTile(
                            onTap: () {
                              setSheetState(() => _selectedBgmAsset = asset);
                              setState(() => _selectedBgmAsset = asset);
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            leading: GestureDetector(
                              onTap: () async {
                                if (isPlaying) {
                                  await PocketGameAudioService.instance.stop();
                                  setSheetState(() => _previewingTrackAsset = null);
                                } else {
                                  await PocketGameAudioService.instance.playTrack(
                                    PocketMusicTrack(
                                      id: 'preview_${track['title']}',
                                      title: track['title']!,
                                      genre: track['mood']!,
                                      url: asset,
                                    ),
                                  );
                                  setSheetState(() => _previewingTrackAsset = asset);
                                }
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isPlaying
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFF292524),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: isPlaying ? Colors.black : Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                            title: Text(
                              track['title']!,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? const Color(0xFFF59E0B) : Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              track['mood']!,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.white60,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle_rounded, color: Color(0xFFF59E0B), size: 22)
                                : const Icon(Icons.radio_button_unchecked_rounded, color: Colors.white24, size: 20),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.movie_creation_rounded, size: 18),
                        label: Text(
                          'Render 15s Story Video 🎬',
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          PocketGameAudioService.instance.stop();
                          _previewingTrackAsset = null;
                          Navigator.pop(ctx);
                          _downloadVideo(_selectedBgmAsset);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _downloadVideo([String? customBgmAsset]) async {
    if (_isExporting) return;
    setState(() {
      _isExporting = true;
      _exportStatusText = 'Creating 15s Video...';
    });
    HapticFeedback.heavyImpact();

    try {
      final imageFile = await _captureCardImage();
      if (imageFile == null) throw Exception('Could not render image for video');

      final videoFile = await PocketCitadelVideoExportService.generateStoryVideo(
        imageFile: imageFile,
        durationSeconds: 15,
        bgmAssetPath: customBgmAsset ?? _selectedBgmAsset,
      );

      if (videoFile == null) {
        await _downloadImage();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF3B82F6),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            content: Text(
              '🎬 15s Story Video with chosen BGM renders natively on Android & iOS! Saved Story card image.',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 12.5),
            ),
          ),
        );
        return;
      }

      final targetDir = await _getExportDirectory();
      final permanentPath = '${targetDir.path}${Platform.pathSeparator}${videoFile.uri.pathSegments.last}';
      await videoFile.copy(permanentPath);

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        try {
          await Gal.putVideo(permanentPath, album: 'PoketMates');
        } catch (galErr) {
          debugPrint('Gal video save notice: $galErr');
        }
      }

      if (Platform.isWindows) {
        try {
          Process.run('explorer.exe', ['/select,', permanentPath]);
        } catch (_) {}
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              const Icon(Icons.movie_creation_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  Platform.isWindows
                      ? '15s Video saved to Downloads: ${videoFile.uri.pathSegments.last} 🎬'
                      : '15s Video saved to Gallery & Downloads: ${videoFile.uri.pathSegments.last} 🎬',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          content: Text('Failed to create video: $e', style: GoogleFonts.outfit(color: Colors.white)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _shareCard() async {
    if (_isExporting) return;
    setState(() {
      _isExporting = true;
      _exportStatusText = 'Sharing...';
    });
    HapticFeedback.mediumImpact();

    try {
      final file = await _captureCardImage();
      if (file == null) throw Exception('Could not render image');

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: '🏰 Check out my Day ${widget.level} Citadel in PoketMates! Speak English Every Day ✨',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          content: Text('Failed to share: $e', style: GoogleFonts.outfit(color: Colors.white)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _previousTemplate() {
    if (_currentTemplateIndex > 0) {
      setState(() => _currentTemplateIndex--);
      _pageController.animateToPage(
        _currentTemplateIndex,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextTemplate() {
    if (_currentTemplateIndex < _templateTitles.length - 1) {
      setState(() => _currentTemplateIndex++);
      _pageController.animateToPage(
        _currentTemplateIndex,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141210),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141210),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Story Card',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isBgmMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: _isBgmMuted ? Colors.white38 : const Color(0xFFF59E0B),
              size: 20,
            ),
            tooltip: _isBgmMuted ? 'Unmute BGM' : 'Mute BGM',
            onPressed: _toggleBgm,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🏷️ Aspect Ratio Selector Pills (Story 9:16, Portrait 4:5, Square 1:1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
              child: Container(
                padding: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF221E1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4A373).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: CitadelStoryAspectRatio.values.map((format) {
                    final isSelected = _selectedFormat == format;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedFormat = format);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFD95D39) : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                format.icon,
                                size: 12.5,
                                color: isSelected ? Colors.white : Colors.white60,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                format.label,
                                style: GoogleFonts.outfit(
                                  fontSize: 10.5,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? Colors.white : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // 📑 Template Carousel Selector Bar with arrows
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: Colors.white70, size: 22),
                    onPressed: _currentTemplateIndex > 0 ? _previousTemplate : null,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_currentTemplateIndex + 1}/${_templateTitles.length}  •  ',
                          style: GoogleFonts.outfit(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFD4A373),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            _templateTitles[_currentTemplateIndex],
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 22),
                    onPressed: _currentTemplateIndex < _templateTitles.length - 1 ? _nextTemplate : null,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  ),
                ],
              ),
            ),

            // 🖼️ Horizontal Card-to-Card Carousel Viewport with Peek Edges
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _templateTitles.length,
                onPageChanged: (idx) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentTemplateIndex = idx);
                },
                itemBuilder: (context, index) {
                  final bool isActive = index == _currentTemplateIndex;

                  Widget cardContent = _buildTemplateByIndex(index);

                  if (isActive) {
                    cardContent = RepaintBoundary(
                      key: _cardKey,
                      child: cardContent,
                    );
                  }

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: AspectRatio(
                        aspectRatio: _selectedFormat.ratio,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width: _selectedFormat.designWidth,
                            height: _selectedFormat.designHeight,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: cardContent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ⚡ Minimal Bottom Action Bar
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateByIndex(int index) {
    switch (index) {
      case 0:
        return _buildTemplate1ScrapbookDesk();
      case 1:
        return _buildTemplate2PolaroidKeepsake();
      case 2:
        return _buildTemplate3CinematicShowcase();
      case 3:
        return _buildTemplate4SpiralNotebook();
      case 4:
        return _buildTemplate5AirmailPostcard();
      case 5:
        return _buildTemplate6NordicEditorial();
      case 6:
        return _buildTemplate7WashiMoodboard();
      case 7:
        return _buildTemplate8JapaneseEditorial();
      case 8:
        return _buildTemplate9CosmicObservatory();
      case 9:
        return _buildTemplate10RetroChronicle();
      case 10:
        return _buildTemplate11RetroInstantFilm();
      case 11:
      default:
        return _buildTemplate12CosmicPassport();
    }
  }

  // =========================================================================
  // 🎨 TEMPLATE 1: "Scrapbook Desk Poster" (Image 1 Style - Clean)
  // =========================================================================
  Widget _buildTemplate1ScrapbookDesk() {
    final isSquare = _selectedFormat == CitadelStoryAspectRatio.square1x1;
    final isPortrait = _selectedFormat == CitadelStoryAspectRatio.feedPortrait4x5;

    final double topMargin = isSquare ? 12 : (isPortrait ? 12 : 14);
    final double cardTop = isSquare ? 88 : (isPortrait ? 88 : 105);
    final double cardBottom = isSquare ? 42 : (isPortrait ? 48 : 66);
    final double cardHorizontal = isSquare ? 28 : (isPortrait ? 22 : 18);

    return Container(
      decoration: const BoxDecoration(color: Color(0xFFE5D5BA)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _KraftPaperTexturePainter()),

          // Top Torn Paper Header
          Positioned(
            top: topMargin,
            left: cardHorizontal,
            right: cardHorizontal,
            child: _buildTornPaperHeader(isSquare: isSquare),
          ),

          // Center Boxed Citadel Card
          Positioned(
            top: cardTop,
            bottom: cardBottom,
            left: cardHorizontal,
            right: cardHorizontal,
            child: _buildBoxedCitadelCard(isSquare: isSquare),
          ),

          // Paperclip top-left
          Positioned(
            top: topMargin - 4,
            left: cardHorizontal + 10,
            child: _buildRealisticPaperclip(),
          ),

          // Washi Tapes on corners
          Positioned(
            top: cardTop - 10,
            left: cardHorizontal - 8,
            child: Transform.rotate(
              angle: -0.12,
              child: Container(
                width: 58,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF99F6E4).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Positioned(
            top: cardTop - 10,
            right: cardHorizontal - 8,
            child: Transform.rotate(
              angle: 0.12,
              child: Container(
                width: 58,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBCFE8).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Stickers
          Positioned(
            left: cardHorizontal - 8,
            bottom: cardBottom + 12,
            child: const Text('⭐', style: TextStyle(fontSize: 18)),
          ),
          Positioned(
            bottom: isSquare ? 8 : (isPortrait ? 10 : 12),
            right: cardHorizontal,
            child: _buildFlowerSticker(),
          ),

          // Brand Footer
          Positioned(
            bottom: isSquare ? 10 : (isPortrait ? 12 : 14),
            left: 16,
            right: 16,
            child: _buildVintageBrandFooter(),
          ),
        ],
      ),
    );
  }

  Widget _buildTornPaperHeader({bool isSquare = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: isSquare ? 8 : 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.14), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Speak English.',
              style: GoogleFonts.outfit(
                fontSize: isSquare ? 19 : 17,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2E1810),
                letterSpacing: -0.2,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Meet Your POKETMates.',
              style: GoogleFonts.outfit(
                fontSize: isSquare ? 17 : 15.5,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFD95D39),
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            'Chat. Connect. Build your Home.',
            style: GoogleFonts.outfit(
              fontSize: isSquare ? 10.5 : 9.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6E5443),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxedCitadelCard({bool isSquare = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildCitadelScenicViewport(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: _buildKraftPlayerPod(isSquare: isSquare),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKraftPlayerPod({bool isSquare = false}) {
    final isPresident = widget.neighbor.isPresident;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: isSquare ? 8 : 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD4A373), width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isSquare ? 38 : 34,
            height: isSquare ? 38 : 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isPresident ? const Color(0xFFD95D39) : const Color(0xFF6E5443),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: isPresident
                  ? PresidentAvatarWidget(size: isSquare ? 38 : 34, showGlow: false)
                  : VectorAvatarWidget(
                      config: VectorAvatarConfig.getEvolutionAvatarForStage(
                          widget.level > 0 ? widget.level : widget.neighbor.day),
                      size: isSquare ? 38 : 34,
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.neighbor.name,
                  style: GoogleFonts.outfit(
                    fontSize: isSquare ? 14.5 : 13,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2E1810),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTerracottaRankBadge(),
                      const SizedBox(width: 5),
                      Text(
                        'Day ${widget.level}',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6E5443),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFF59E0B), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.pocketScore}',
                  style: GoogleFonts.outfit(
                    fontSize: isSquare ? 13 : 11.5,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF92400E),
                  ),
                ),
                Text(
                  'PS',
                  style: GoogleFonts.outfit(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 📷 TEMPLATE 2: "Vintage Polaroid Keepsake"
  // =========================================================================
  Widget _buildTemplate2PolaroidKeepsake() {
    final isSquare = _selectedFormat == CitadelStoryAspectRatio.square1x1;
    final isPortrait = _selectedFormat == CitadelStoryAspectRatio.feedPortrait4x5;

    final double polaroidH = isSquare ? 420 : (isPortrait ? 430 : 500);
    final double photoAspectRatio = isSquare ? 1.45 : (isPortrait ? 1.25 : 1.05);

    return Container(
      decoration: const BoxDecoration(color: Color(0xFFDECDB4)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _KraftPaperTexturePainter()),
          Center(
            child: Container(
              width: isSquare ? 460 : (isPortrait ? 380 : 310),
              height: polaroidH,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.22), blurRadius: 16, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: AspectRatio(
                          aspectRatio: photoAspectRatio,
                          child: _buildCitadelScenicViewport(),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Day ${widget.level} Citadel • ${widget.neighbor.name}',
                                style: GoogleFonts.caveat(
                                  fontSize: isSquare ? 18 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2E1810),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Text('❤️', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildTerracottaRankBadge(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '🪙 ${widget.pocketScore} PS',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF92400E),
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
            ),
          ),
          Positioned(
            top: isSquare ? 16 : 8,
            left: 0,
            right: 0,
            child: Center(
              child: Transform.rotate(
                angle: 0.04,
                child: Container(
                  width: 70,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE047).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: isSquare ? 12 : 8,
            left: 16,
            right: 16,
            child: _buildVintageBrandFooter(),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 🏔️ TEMPLATE 3: "Cinematic Showcase"
  // =========================================================================
  Widget _buildTemplate3CinematicShowcase() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4A373).withValues(alpha: 0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildCitadelScenicViewport(),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.35), Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                  stops: const [0.0, 0.35, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E1810).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD4A373).withValues(alpha: 0.7)),
                ),
                child: Text(
                  '🏰 Day ${widget.level} Citadel',
                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 14,
              right: 14,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildKraftPlayerPod(),
                  const SizedBox(height: 6),
                  _buildVintageBrandFooter(darkTone: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 📓 TEMPLATE 4: "Spiral Notebook Journal" (Zero Footer Overlap)
  // =========================================================================
  Widget _buildTemplate4SpiralNotebook() {
    final isSquare = _selectedFormat == CitadelStoryAspectRatio.square1x1;

    return Container(
      decoration: const BoxDecoration(color: Color(0xFFDFCFB7)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _KraftPaperTexturePainter()),
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: isSquare ? 28 : 18, vertical: isSquare ? 24 : 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.16), blurRadius: 14, offset: const Offset(0, 4)),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 6,
                    top: 12,
                    bottom: 12,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        isSquare ? 9 : 12,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(26, 12, 14, 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('✏️ ', style: TextStyle(fontSize: 14)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DAILY CITADEL JOURNAL',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF1E293B),
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  Text(
                                    'Learn with PoketMates • Day ${widget.level} Edition',
                                    style: GoogleFonts.outfit(fontSize: 9.5, color: const Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Color(0xFFCBD5E1), height: 14),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildCitadelScenicViewport(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.neighbor.name,
                              style: GoogleFonts.caveat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E1810),
                              ),
                            ),
                            _buildTerracottaRankBadge(),
                            Text(
                              '🪙 ${widget.pocketScore} PS',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildVintageBrandFooter(),
                      ],
                    ),
                  ),
                  Positioned(top: -4, left: 30, child: _buildRealisticPaperclip()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // ✉️ TEMPLATE 5: "Airmail Postcard" (Zero Footer Overlap)
  // =========================================================================
  Widget _buildTemplate5AirmailPostcard() {
    final isSquare = _selectedFormat == CitadelStoryAspectRatio.square1x1;

    return Container(
      decoration: const BoxDecoration(color: Color(0xFFDBC9B0)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _KraftPaperTexturePainter()),
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: isSquare ? 26 : 18, vertical: isSquare ? 20 : 16),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F0),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD4A373), width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 14),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D4ED8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PAR AVION / AIR MAIL',
                          style: GoogleFonts.outfit(fontSize: 8.5, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          border: Border.all(color: const Color(0xFFEF4444), width: 1),
                        ),
                        child: Text(
                          'POKETMATES • DAY ${widget.level}',
                          style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: _buildCitadelScenicViewport(),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildKraftPlayerPod(isSquare: isSquare),
                  const SizedBox(height: 6),
                  _buildVintageBrandFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 🏛️ TEMPLATE 6: "Nordic Editorial Art Book" (Luxury Architectural Replacement)
  // =========================================================================
  Widget _buildTemplate6NordicEditorial() {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFFFBF9F5)),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'POKETMATES ARCHITECTURE',
                style: GoogleFonts.cinzel(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E1E1E),
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'ISSUE NO. ${widget.level}',
                style: GoogleFonts.outfit(fontSize: 9.5, fontWeight: FontWeight.bold, color: const Color(0xFFD95D39)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(color: Color(0xFFE2DCD5), height: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD6CEC5), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: _buildCitadelScenicViewport(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.neighbor.name.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E1E1E),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Level ${widget.level} Citadel • ${widget.pocketScore} PS',
                    style: GoogleFonts.outfit(fontSize: 10.5, color: const Color(0xFF78716C)),
                  ),
                ],
              ),
              _buildTerracottaRankBadge(),
            ],
          ),
          const SizedBox(height: 6),
          _buildVintageBrandFooter(),
        ],
      ),
    );
  }

  // =========================================================================
  // 🎨 TEMPLATE 7: "Washi Moodboard Collage" (Zero Footer Overlap)
  // =========================================================================
  Widget _buildTemplate7WashiMoodboard() {
    final isSquare = _selectedFormat == CitadelStoryAspectRatio.square1x1;

    return Container(
      decoration: const BoxDecoration(color: Color(0xFFE8DCB8)),
      padding: EdgeInsets.symmetric(horizontal: isSquare ? 24 : 16, vertical: isSquare ? 18 : 12),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildCitadelScenicViewport(),
                ),
                Positioned(
                  top: -4,
                  left: 20,
                  child: Container(width: 50, height: 16, color: const Color(0xFFFDE047).withValues(alpha: 0.85)),
                ),
                Positioned(
                  top: -4,
                  right: 20,
                  child: Container(width: 50, height: 16, color: const Color(0xFF86EFAC).withValues(alpha: 0.85)),
                ),
                Positioned(
                  bottom: 12,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    color: const Color(0xFFFBCFE8),
                    child: Text(
                      'MY CITADEL ✨',
                      style: GoogleFonts.permanentMarker(fontSize: 10, color: const Color(0xFF831843)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          _buildKraftPlayerPod(isSquare: isSquare),
          const SizedBox(height: 6),
          _buildVintageBrandFooter(),
        ],
      ),
    );
  }

  // =========================================================================
  // ⛩️ TEMPLATE 8: "Minimalist Japanese Editorial"
  // =========================================================================
  Widget _buildTemplate8JapaneseEditorial() {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFFF5EFEB)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CITADEL NO. ${widget.level}',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1F1D1B),
                  letterSpacing: 2.0,
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFDC2626), width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text('城', style: GoogleFonts.notoSans(fontSize: 11, color: const Color(0xFFDC2626))),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildCitadelScenicViewport(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.neighbor.name.toUpperCase(),
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF1F1D1B)),
              ),
              Text(
                'DAY ${widget.level} • ${widget.pocketScore} PS',
                style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF78716C)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildVintageBrandFooter(),
        ],
      ),
    );
  }

  // =========================================================================
  // 🪐 TEMPLATE 9: "Cosmic Celestial Observatory"
  // =========================================================================
  Widget _buildTemplate9CosmicObservatory() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF030712),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildCitadelScenicViewport(),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.88)],
                  radius: 0.85,
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF38BDF8), width: 1),
                    ),
                    child: Text(
                      'SECTOR ${widget.neighbor.effectivePlanetCode}',
                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF38BDF8)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFA855F7), width: 1),
                    ),
                    child: Text(
                      'ORBIT DAY ${widget.level}',
                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFA855F7)),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 12,
              left: 14,
              right: 14,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildKraftPlayerPod(),
                  const SizedBox(height: 6),
                  _buildVintageBrandFooter(darkTone: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 📰 TEMPLATE 10: "Retro Daily Chronicle"
  // =========================================================================
  Widget _buildTemplate10RetroChronicle() {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFFF4ECD8)),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(
            'THE POKETMATES CHRONICLE',
            style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF1E1B18), letterSpacing: 1.0),
          ),
          Text(
            'Special Spoken English Gazette • Day ${widget.level} Milestone Edition',
            style: GoogleFonts.playfairDisplay(fontSize: 8.5, fontStyle: FontStyle.italic, color: const Color(0xFF57534E)),
          ),
          const Divider(color: Color(0xFF292524), thickness: 1.2, height: 10),
          Text(
            'EXTRA! ${widget.neighbor.name.toUpperCase()} EXPANDS CITADEL ESTATE!',
            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF1C1917)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: _buildCitadelScenicViewport(),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(border: Border.all(color: const Color(0xFF44403C))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RANK: #${widget.globalRank ?? 1}',
                  style: GoogleFonts.outfit(fontSize: 9.5, fontWeight: FontWeight.bold, color: const Color(0xFF1C1917)),
                ),
                Text(
                  'SCORE: ${widget.pocketScore} PS',
                  style: GoogleFonts.outfit(fontSize: 9.5, fontWeight: FontWeight.bold, color: const Color(0xFF1C1917)),
                ),
                Text(
                  'DEFENSE: ACTIVE',
                  style: GoogleFonts.outfit(fontSize: 9.5, fontWeight: FontWeight.bold, color: const Color(0xFFD97706)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          _buildVintageBrandFooter(),
        ],
      ),
    );
  }

  // =========================================================================
  // 📸 TEMPLATE 11: "Retro Instant Film" (Fujifilm Instax Warmth)
  // =========================================================================
  Widget _buildTemplate11RetroInstantFilm() {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFFF3E8D8)),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'INSTANT MEMORY // POKETMATES',
                style: GoogleFonts.spaceMono(fontSize: 9.5, fontWeight: FontWeight.bold, color: const Color(0xFF78716C)),
              ),
              Text(
                '#D${widget.level}',
                style: GoogleFonts.spaceMono(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFFD95D39)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildCitadelScenicViewport(),
            ),
          ),
          const SizedBox(height: 8),
          _buildKraftPlayerPod(),
          const SizedBox(height: 6),
          _buildVintageBrandFooter(),
        ],
      ),
    );
  }

  // =========================================================================
  // 🛂 TEMPLATE 12: "Pocket Cosmic Passport"
  // =========================================================================
  Widget _buildTemplate12CosmicPassport() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🛂 ', style: TextStyle(fontSize: 14)),
                  Text(
                    'POKET COSMOS PASSPORT',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF10B981)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'VISA VERIFIED',
                  style: GoogleFonts.spaceMono(fontSize: 8, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildCitadelScenicViewport(),
            ),
          ),
          const SizedBox(height: 6),
          _buildKraftPlayerPod(),
          const SizedBox(height: 6),
          _buildVintageBrandFooter(darkTone: false),
        ],
      ),
    );
  }

  // =========================================================================
  // 🏞️ Shared Scenic Viewport
  // =========================================================================
  Widget _buildCitadelScenicViewport() {
    final isPresident = widget.neighbor.isPresident;
    final isDay90 = widget.level >= 90 || isPresident;

    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: CitadelInfiniteOceanSkyBackdropPainter(
            isNight: widget.isNight,
            ambientProg: 0.5,
            planetCode: widget.neighbor.effectivePlanetCode,
          ),
        ),
        FittedBox(
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.15),
          child: SizedBox(
            width: 1200,
            height: 1600,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: CitadelScenicLandscapePainter(
                      isDamaged: false,
                      groundBaseY: 920.0,
                      isNight: widget.isNight,
                      isDay90: isDay90,
                      ambientProg: 0.5,
                      isPresident: isPresident,
                      planetCode: widget.neighbor.effectivePlanetCode,
                    ),
                  ),
                ),
                if (isPresident)
                  Positioned(
                    left: (1200 - 540) / 2,
                    top: 920 - 14 - 380 + (380 - 410),
                    width: 540,
                    height: 410,
                    child: RepaintBoundary(
                      child: FlameEnglishHouseWidget(
                        currentDay: 90,
                        streak: 90,
                        isDamaged: false,
                        houseId: 'pocket_president',
                        paletteId: widget.neighbor.paletteId,
                        isPresident: true,
                        showTestingControls: false,
                      ),
                    ),
                  )
                else
                  Positioned(
                    left: (1200 - 420) / 2,
                    top: 920 - 14 - 380,
                    width: 420,
                    height: 380,
                    child: RepaintBoundary(
                      child: FlameEnglishHouseWidget(
                        currentDay: widget.level,
                        streak: widget.neighbor.streak > 0 ? widget.neighbor.streak : widget.level,
                        isDamaged: false,
                        houseId: widget.neighbor.id,
                        paletteId: widget.neighbor.paletteId,
                        showTestingControls: false,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 🏷️ Shared Badges & Accents
  // =========================================================================
  Widget _buildTerracottaRankBadge() {
    final isRobot = (widget.neighbor.isPocketRobo ||
            PocketRobotService.isRobotId(widget.neighbor.id)) &&
        !widget.neighbor.isPresident;
    final rank = widget.globalRank;
    final rankText = isRobot
        ? '🤖 Robot #${rank ?? widget.level.clamp(1, 90)}'
        : (widget.neighbor.isPresident
            ? '👑 Rank #1'
            : (rank != null && rank > 0 ? '🏆 Rank #$rank' : '🏆 Challenger'));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFD95D39),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        rankText,
        style: GoogleFonts.outfit(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildVintageBrandFooter({bool darkTone = true}) {
    final textColor = darkTone ? const Color(0xFF4A2E1B) : Colors.white;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              'assets/images/pocket_mates_logo.png',
              width: 13,
              height: 13,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.chat_bubble_rounded,
                size: 12,
                color: Color(0xFFF59E0B),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'PoketMates',
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
          Text(
            ' • Speak English Every Day',
            style: GoogleFonts.outfit(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.8),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealisticPaperclip() {
    return Container(
      width: 12,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF94A3B8), width: 2.2),
      ),
    );
  }

  Widget _buildFlowerSticker() {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFDE8E8)),
      alignment: Alignment.center,
      child: const Text('🌸', style: TextStyle(fontSize: 14)),
    );
  }

  // =========================================================================
  // ⚡ Minimal Bottom Action Bar
  // =========================================================================
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF141210),
        border: Border(top: BorderSide(color: Color(0xFF221E1A), width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isExporting)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD95D39)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _exportStatusText,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD4A373),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              // 📥 Save Image Button
              Expanded(
                child: GestureDetector(
                  onTap: _isExporting ? null : _showSaveQualitySheet,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF221E1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD4A373).withValues(alpha: 0.35), width: 1.2),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.download_rounded, color: Color(0xFFD4A373), size: 17),
                        const SizedBox(width: 6),
                        Text(
                          'Save Image',
                          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 🚀 Share Button
              Expanded(
                child: GestureDetector(
                  onTap: _isExporting ? null : _shareCard,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD95D39), Color(0xFFB45309)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD95D39).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.share_rounded, color: Colors.white, size: 17),
                        const SizedBox(width: 6),
                        Text(
                          'Share',
                          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 🎨 Subtle Kraft Paper Textured Background Painter
class _KraftPaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7A5C3D).withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const spacing = 28.0;
    for (double x = 4; x < size.width; x += spacing) {
      for (double y = 6; y < size.height; y += spacing) {
        final offset = (x * 7 + y * 13) % 9;
        canvas.drawCircle(Offset(x + offset, y + (offset / 2)), 0.7, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
