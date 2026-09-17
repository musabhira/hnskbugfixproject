import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pocket_mates_app/custom_code/widgets/chat/pocket_ambient_flame_background.dart';

class PokiGamesPage extends StatefulWidget {
  const PokiGamesPage({super.key});

  @override
  State<PokiGamesPage> createState() => _PokiGamesPageState();
}

class _PokiGamesPageState extends State<PokiGamesPage> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _isSupported = false;

  @override
  void initState() {
    super.initState();
    _isSupported = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (_isSupported) {
      try {
        _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0xFF0B0D13))
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                if (mounted) setState(() => _isLoading = true);
              },
              onPageFinished: (String url) {
                if (mounted) setState(() => _isLoading = false);
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint('Webview Error: ${error.description}');
              },
              onNavigationRequest: (NavigationRequest request) {
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse('https://poki.com/'));
      } catch (e) {
        debugPrint('Webview init error: $e');
      }
    } else {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D13),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥 ', style: TextStyle(fontSize: 18)),
            Text(
              'Poki Games Arena',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFFC00),
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF131722),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFFC00), Color(0xFFFF8906), Colors.transparent],
              ),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isSupported && _controller != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFFFFFC00)),
              onPressed: () => _controller?.reload(),
            ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: PocketAmbientFlameBackground(
              showTopFlameGlow: true,
              emberDensity: 0.75,
            ),
          ),
          if (_isSupported && _controller != null)
            WebViewWidget(controller: _controller!)
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131722),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF1E2333)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.videogame_asset_rounded,
                          color: Color(0xFFFFFC00), size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Poki Games Arena',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Online multiplayer gaming is optimized for mobile touchscreens. Tap below to launch Poki in your browser.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => launchUrl(
                          Uri.parse('https://poki.com/'),
                          mode: LaunchMode.externalApplication,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFC00),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.open_in_browser_rounded),
                        label: Text('Open Poki Games',
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: const Color(0xFF0B0F17),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFF8906)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF8906).withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Text('🔥', style: TextStyle(fontSize: 32)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'IGNITING POKI ARENA...',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFFC00),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(
                        width: 140,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFFC00)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
