import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class DynamicWebViewPage extends StatefulWidget {
  final String title;
  final String url;

  const DynamicWebViewPage({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  @override
  State<DynamicWebViewPage> createState() => _DynamicWebViewPageState();
}

class _DynamicWebViewPageState extends State<DynamicWebViewPage> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _isSupported = true;

  @override
  void initState() {
    super.initState();
    String initUrl = widget.url;
    if (!initUrl.startsWith('http://') && !initUrl.startsWith('https://')) {
      initUrl = 'https://$initUrl';
    }

    try {
      if (initUrl.contains('web.whatsapp.com')) {
        _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setUserAgent(
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
          ..setBackgroundColor(const Color(0xFF1E1E1E))
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
          ..loadRequest(Uri.parse(initUrl));
      } else {
        _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0xFF1E1E1E))
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
          ..loadRequest(Uri.parse(initUrl));
      }
    } catch (e) {
      debugPrint('WebView initialization error: $e');
      _isSupported = false;
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSupported || _controller == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          title: Text(
            widget.title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF1E1E1E),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Web views are not currently supported on this platform.\n\nPlease open this link on a mobile device:\n${widget.url}',
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _controller!.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller!),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            ),
        ],
      ),
    );
  }
}
