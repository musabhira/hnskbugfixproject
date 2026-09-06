import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pocket_mates_app/custom_code/widgets/chat/pocket_ambient_flame_background.dart';

class CrazyGamesPage extends StatefulWidget {
  const CrazyGamesPage({super.key});

  @override
  State<CrazyGamesPage> createState() => _CrazyGamesPageState();
}

class _CrazyGamesPageState extends State<CrazyGamesPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0F172A))
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
      ..loadRequest(Uri.parse('https://www.crazygames.com/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥 ', style: TextStyle(fontSize: 18)),
            Text(
              'Crazy Games Arena',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFFC00),
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
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
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFFFFC00)),
            onPressed: () => _controller.reload(),
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
          WebViewWidget(controller: _controller),
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
                        'IGNITING CRAZY GAMES...',
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
