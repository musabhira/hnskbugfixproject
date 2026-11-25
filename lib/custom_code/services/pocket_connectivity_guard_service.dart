import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

/// 🌐 Minimal Internet Connectivity Guard
/// - Home Page: Non-blocking minimal alert with Close + Turn On Internet
/// - Target Page: Blocking minimal alert (auto-closes as soon as Internet is ON)
class PocketConnectivityGuardService {
  static bool _isDialogShowing = false;

  /// Returns true if device has real internet access
  static Future<bool> hasInternetConnection() async {
    if (kIsWeb) return true;
    try {
      final result = await InternetAddress.lookup('dns.google')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Opens device Network / Wi-Fi Settings on Android & iOS
  static Future<void> openInternetSettings() async {
    try {
      if (Platform.isAndroid) {
        final uri = Uri.parse('android.settings.WIRELESS_SETTINGS');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          return;
        }
        await launchUrl(Uri.parse('package:com.android.settings'));
      } else if (Platform.isIOS) {
        final wifiUri = Uri.parse('App-Prefs:WIFI');
        if (await canLaunchUrl(wifiUri)) {
          await launchUrl(wifiUri);
          return;
        }
        await launchUrl(Uri.parse('app-settings:'));
      }
    } catch (e) {
      debugPrint('openInternetSettings error: $e');
    }
  }

  /// Checks internet and shows minimal alert if offline.
  /// Returns true if online, false if offline.
  static Future<bool> ensureConnected(
    BuildContext context, {
    bool isBlocking = false,
  }) async {
    final online = await hasInternetConnection();
    if (online) return true;
    if (!context.mounted || _isDialogShowing) return false;

    _isDialogShowing = true;
    await showDialog(
      context: context,
      barrierDismissible: !isBlocking,
      builder: (ctx) => _MinimalNoInternetDialog(isBlocking: isBlocking),
    );
    _isDialogShowing = false;
    return await hasInternetConnection();
  }
}

class _MinimalNoInternetDialog extends StatefulWidget {
  final bool isBlocking;
  const _MinimalNoInternetDialog({required this.isBlocking});

  @override
  State<_MinimalNoInternetDialog> createState() =>
      _MinimalNoInternetDialogState();
}

class _MinimalNoInternetDialogState extends State<_MinimalNoInternetDialog> {
  Timer? _pollTimer;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    // Auto-close automatically as soon as Internet turns back ON
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final online =
          await PocketConnectivityGuardService.hasInternetConnection();
      if (online && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _retryNow() async {
    if (_checking) return;
    setState(() => _checking = true);
    final online = await PocketConnectivityGuardService.hasInternetConnection();
    if (mounted) {
      setState(() => _checking = false);
      if (online) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isBlocking,
      child: Dialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Colors.white12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  color: Color(0xFFFFD700),
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Internet Required',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.isBlocking
                    ? 'Please turn on Wi-Fi or Mobile Data to continue this mission.'
                    : 'Turn on Wi-Fi or Mobile Data for the best experience.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    PocketConnectivityGuardService.openInternetSettings();
                  },
                  icon: const Icon(Icons.settings_rounded, size: 17),
                  label: Text(
                    'Turn On Internet',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _checking ? null : _retryNow,
                    child: Text(
                      _checking ? 'Checking...' : 'Retry',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (!widget.isBlocking) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Close',
                        style: GoogleFonts.outfit(
                          color: Colors.white38,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
