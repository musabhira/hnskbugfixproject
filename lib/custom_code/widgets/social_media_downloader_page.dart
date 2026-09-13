import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SocialMediaDownloaderPage extends StatefulWidget {
  const SocialMediaDownloaderPage({super.key});

  @override
  State<SocialMediaDownloaderPage> createState() =>
      _SocialMediaDownloaderPageState();
}

class _SocialMediaDownloaderPageState extends State<SocialMediaDownloaderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _urlController = TextEditingController();
  final Dio _dio = Dio();

  bool _isLoading = false;
  double _downloadProgress = 0.0;
  bool _isDownloading = false;
  String? _statusMessage;

  // Media preview details
  Map<String, dynamic>? _resolvedMedia;
  VideoPlayerController? _videoPlayerController;
  bool _isVideoInitialized = false;

  // Download History
  List<Map<String, dynamic>> _history = [];

  // Webview for in-app story/reel grabber
  WebViewController? _webViewController;
  bool _isWebViewLoading = false;
  String? _detectedVideoUrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
    _initWebView();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyRaw = prefs.getString('media_download_history');
      if (historyRaw != null) {
        final List decoded = jsonDecode(historyRaw);
        setState(() {
          _history = decoded.cast<Map<String, dynamic>>();
        });
      }
    } catch (_) {}
  }

  Future<void> _saveHistoryItem(Map<String, dynamic> item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _history.insert(0, item);
      if (_history.length > 50) _history.removeLast();
      await prefs.setString('media_download_history', jsonEncode(_history));
      setState(() {});
    } catch (_) {}
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0F172A))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isWebViewLoading = true;
              _detectedVideoUrl = null;
            });
          },
          onPageFinished: (url) async {
            setState(() => _isWebViewLoading = false);
            _injectVideoSniffer();
          },
          onWebResourceError: (error) {
            setState(() => _isWebViewLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.instagram.com'));
  }

  void _injectVideoSniffer() async {
    if (_webViewController == null) return;
    try {
      // JavaScript to detect any active HTML5 video tag source
      final result = await _webViewController!.runJavaScriptReturningResult(
        "(function() {"
        "  var v = document.querySelector('video');"
        "  if (v && v.src) return v.src;"
        "  var s = document.querySelector('video source');"
        "  if (s && s.src) return s.src;"
        "  return '';"
        "})()",
      );
      final raw = result.toString().replaceAll('"', '').trim();
      if (raw.isNotEmpty && (raw.startsWith('http://') || raw.startsWith('https://'))) {
        setState(() => _detectedVideoUrl = raw);
      }
    } catch (_) {}
  }

  Future<void> _pasteFromClipboard() async {
    HapticFeedback.selectionClick();
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      setState(() {
        _urlController.text = data.text!.trim();
      });
      _fetchMedia();
    } else {
      _showToast('Clipboard is empty');
    }
  }

  Future<void> _fetchMedia() async {
    final rawUrl = _urlController.text.trim();
    if (rawUrl.isEmpty) {
      _showToast('Please enter or paste an Instagram / social media link');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _statusMessage = 'Connecting to media resolver...';
      _resolvedMedia = null;
      _videoPlayerController?.dispose();
      _videoPlayerController = null;
      _isVideoInitialized = false;
    });

    try {
      // Attempt 1: Cobalt Tools public high-performance media endpoint
      final cobaltEndpoints = [
        'https://api.cobalt.tools',
        'https://cobalt-api.kwiatekm.pl',
      ];

      Map<String, dynamic>? mediaResult;

      for (final endpoint in cobaltEndpoints) {
        try {
          final res = await _dio.post(
            endpoint,
            data: {
              'url': rawUrl,
              'videoQuality': '720',
              'filenameStyle': 'basic',
            },
            options: Options(
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
              receiveTimeout: const Duration(seconds: 12),
              sendTimeout: const Duration(seconds: 8),
            ),
          );

          if (res.statusCode == 200 && res.data != null) {
            final data = res.data;
            if (data['url'] != null) {
              mediaResult = {
                'url': data['url'] as String,
                'type': 'video',
                'title': 'Instagram Media',
                'thumbnail': data['thumbnail'] ?? '',
                'source': rawUrl,
              };
              break;
            } else if (data['picker'] != null && (data['picker'] as List).isNotEmpty) {
              final first = (data['picker'] as List).first;
              mediaResult = {
                'url': first['url'] as String,
                'type': first['type'] ?? 'video',
                'title': 'Instagram Media',
                'thumbnail': first['thumb'] ?? '',
                'source': rawUrl,
              };
              break;
            }
          }
        } catch (_) {}
      }

      // Attempt 2: If public resolver fails or rate-limits, format direct preview stream
      if (mediaResult == null) {
        // Provide stream format or route to in-app Web Inspector
        mediaResult = {
          'url': rawUrl,
          'type': rawUrl.contains('.mp4') ? 'video' : 'web_stream',
          'title': 'Instagram Post / Story',
          'thumbnail': '',
          'source': rawUrl,
        };
      }

      setState(() {
        _resolvedMedia = mediaResult;
        _isLoading = false;
      });

      // If resolved URL is direct video, initialize video player
      if (mediaResult['type'] == 'video' &&
          mediaResult['url'].toString().startsWith('http')) {
        _initVideoPreview(mediaResult['url']);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = null;
      });
      _showToast('Failed to resolve link. Try the In-App Web Grabber tab.');
    }
  }

  void _initVideoPreview(String videoUrl) {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
            _videoPlayerController!.setLooping(true);
            _videoPlayerController!.play();
          }
        }).catchError((_) {
          setState(() => _isVideoInitialized = false);
        });
    } catch (_) {}
  }

  Future<void> _downloadMedia(String mediaUrl, String type) async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.05;
      _statusMessage = 'Downloading high-resolution media...';
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final isVideo = type == 'video' || mediaUrl.contains('.mp4');
      final ext = isVideo ? 'mp4' : 'jpg';
      final fileName =
          'PocketMates_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final savePath = '${tempDir.path}/$fileName';

      await _dio.download(
        mediaUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = (received / total).clamp(0.05, 0.98);
            });
          }
        },
      );

      // Check gallery permission & save with Gal
      final hasAccess = await Gal.hasAccess(toAlbum: false);
      if (!hasAccess) {
        await Gal.requestAccess(toAlbum: false);
      }

      if (isVideo) {
        await Gal.putVideo(savePath);
      } else {
        await Gal.putImage(savePath);
      }

      HapticFeedback.heavyImpact();

      // Save to history
      _saveHistoryItem({
        'title': _resolvedMedia?['title'] ?? 'Instagram Download',
        'type': isVideo ? 'video' : 'image',
        'path': savePath,
        'date': DateTime.now().toIso8601String(),
        'source': _urlController.text.trim(),
      });

      setState(() {
        _downloadProgress = 1.0;
        _isDownloading = false;
        _statusMessage = 'Saved directly to your Phone Gallery!';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Success! ${isVideo ? 'Video' : 'Photo'} saved to Gallery.',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _statusMessage = null;
      });
      _showToast('Download error: Please check storage permissions');
    }
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.outfit()),
        backgroundColor: const Color(0xFF334155),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const instaGradient = LinearGradient(
      colors: [
        Color(0xFF833AB4),
        Color(0xFFFD1D1D),
        Color(0xFFFCB045),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: instaGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.download_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insta & Media Saver',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Reels • Stories • Posts • Shorts',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white70),
            onPressed: _showHistorySheet,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFD1D1D),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle:
              GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.link_rounded, size: 18), text: 'Fast Link Downloader'),
            Tab(icon: Icon(Icons.public_rounded, size: 18), text: 'In-App Web Grabber'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLinkDownloaderTab(instaGradient),
          _buildWebGrabberTab(instaGradient),
        ],
      ),
    );
  }

  // TAB 1: FAST LINK DOWNLOADER
  Widget _buildLinkDownloaderTab(Gradient instaGradient) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E1B4B),
                  const Color(0xFF1E293B),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: instaGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1-Tap Direct Media Download',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Paste Instagram Story, Reel, YouTube Short, or TikTok link to download in HD.',
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // URL Input Field
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF131D2D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.link_rounded, color: Color(0xFFFD1D1D), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Paste Instagram Story / Reel URL...',
                      hintStyle: GoogleFonts.inter(
                          color: const Color(0xFF64748B), fontSize: 13),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                if (_urlController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white54, size: 18),
                    onPressed: () => setState(() => _urlController.clear()),
                  ),
                GestureDetector(
                  onTap: _pasteFromClipboard,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.content_paste_rounded,
                            size: 14, color: Colors.yellow),
                        const SizedBox(width: 4),
                        Text(
                          'Paste',
                          style: GoogleFonts.outfit(
                            color: Colors.yellow,
                            fontSize: 12,
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

          const SizedBox(height: 16),

          // Resolve Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _fetchMedia,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                shadowColor: Colors.transparent,
              ).copyWith(
                elevation: WidgetStateProperty.all(0),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: instaGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Fetch & Download Media',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),

          if (_statusMessage != null) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                _statusMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: _statusMessage!.contains('Saved')
                      ? const Color(0xFF10B981)
                      : Colors.white70,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          if (_isDownloading) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _downloadProgress,
                minHeight: 8,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFD1D1D)),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(_downloadProgress * 100).toInt()}%',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Resolved Media Result Card
          if (_resolvedMedia != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF131D2D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFD1D1D).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _resolvedMedia!['type'].toString().toUpperCase(),
                          style: GoogleFonts.inter(
                            color: const Color(0xFFFD1D1D),
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.share_rounded,
                            color: Colors.white70, size: 20),
                        onPressed: () {
                          SharePlus.instance.share(ShareParams(
                            text:
                                'Check out this media: ${_resolvedMedia!['url']}',
                          ));
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Video or Web Stream Preview
                  if (_resolvedMedia!['type'] == 'video' &&
                      _isVideoInitialized &&
                      _videoPlayerController != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: AspectRatio(
                        aspectRatio:
                            _videoPlayerController!.value.aspectRatio > 0
                                ? _videoPlayerController!.value.aspectRatio
                                : 9 / 16,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayer(_videoPlayerController!),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _videoPlayerController!.value.isPlaying
                                      ? _videoPlayerController!.pause()
                                      : _videoPlayerController!.play();
                                });
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: !_videoPlayerController!.value.isPlaying
                                    ? Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.play_arrow_rounded,
                                            color: Colors.white, size: 36),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.video_library_rounded,
                              size: 40, color: Colors.white54),
                          const SizedBox(height: 8),
                          Text(
                            'Media stream detected',
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ready to download to your camera roll',
                            style: GoogleFonts.inter(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Download Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isDownloading
                          ? null
                          : () => _downloadMedia(
                                _resolvedMedia!['url'],
                                _resolvedMedia!['type'],
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.download_for_offline_rounded,
                          size: 20),
                      label: Text(
                        'Save to Phone Gallery',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // TAB 2: IN-APP WEB GRABBER (Direct Instagram browser with Story detector)
  Widget _buildWebGrabberTab(Gradient instaGradient) {
    return Stack(
      children: [
        if (_webViewController != null)
          WebViewWidget(controller: _webViewController!),
        if (_isWebViewLoading)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              color: Color(0xFFFD1D1D),
              minHeight: 3,
            ),
          ),
        // Floating Bottom Grabber Bar when media is detected
        Positioned(
          bottom: 20,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                  onPressed: () {
                    _webViewController?.reload();
                    _injectVideoSniffer();
                  },
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _detectedVideoUrl != null
                            ? '🎯 Story/Reel Video Detected!'
                            : 'Browse story & tap Scan',
                        style: GoogleFonts.outfit(
                          color: _detectedVideoUrl != null
                              ? const Color(0xFF10B981)
                              : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _detectedVideoUrl != null
                            ? 'Ready to save directly to Gallery'
                            : 'Open any Story or Reel to extract',
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_detectedVideoUrl != null)
                  ElevatedButton.icon(
                    onPressed: () =>
                        _downloadMedia(_detectedVideoUrl!, 'video'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: Text(
                      'Save',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: _injectVideoSniffer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.yellow,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Scan Video',
                      style: GoogleFonts.outfit(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // DOWNLOAD HISTORY SHEET
  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saved Downloads',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_history.isNotEmpty)
                    TextButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('media_download_history');
                        setState(() => _history.clear());
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Clear',
                        style: GoogleFonts.inter(
                            color: Colors.redAccent, fontSize: 13),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _history.isEmpty
                    ? Center(
                        child: Text(
                          'No downloaded media yet',
                          style: GoogleFonts.inter(color: Colors.white38),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _history.length,
                        itemBuilder: (context, i) {
                          final item = _history[i];
                          final isVid = item['type'] == 'video';
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isVid
                                    ? Icons.video_library_rounded
                                    : Icons.image_rounded,
                                color: isVid
                                    ? const Color(0xFFFD1D1D)
                                    : Colors.yellow,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              item['title'] ?? 'Media Item',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              item['source'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                  color: Colors.white38, fontSize: 11),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.share_rounded,
                                  color: Colors.white54, size: 18),
                              onPressed: () {
                                final path = item['path'];
                                if (path != null && File(path).existsSync()) {
                                  SharePlus.instance.share(ShareParams(
                                    files: [XFile(path)],
                                  ));
                                }
                              },
                            ),
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
}
