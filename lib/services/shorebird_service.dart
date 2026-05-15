import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class ShorebirdService {
  static final ShorebirdService _instance = ShorebirdService._internal();
  factory ShorebirdService() => _instance;
  ShorebirdService._internal();

  final _shorebirdCodePush = ShorebirdCodePush();

  /// Initializes Shorebird and checks for updates
  Future<void> initialize() async {
    if (kIsWeb) return;

    debugPrint('Shorebird: Initializing...');
    
    // Check if Shorebird is available on this platform
    final isShorebirdAvailable = await _shorebirdCodePush.isShorebirdAvailable();
    if (!isShorebirdAvailable) {
      debugPrint('Shorebird: Not available on this device/platform.');
      return;
    }

    // Get current patch number
    final currentPatch = await _shorebirdCodePush.currentPatchNumber();
    debugPrint('Shorebird: Current patch number: ${currentPatch ?? "None (Base Build)"}');

    // Check for updates
    await checkForUpdates();
  }

  /// Checks for updates and downloads them if available
  Future<void> checkForUpdates() async {
    try {
      final isUpdateAvailable = await _shorebirdCodePush.isNewPatchAvailableForDownload();
      
      if (isUpdateAvailable) {
        debugPrint('Shorebird: New update found! Downloading...');
        await _shorebirdCodePush.downloadUpdateIfAvailable();
        debugPrint('Shorebird: Update downloaded. It will be applied on next restart.');
      } else {
        debugPrint('Shorebird: No new updates available.');
      }
    } catch (e) {
      debugPrint('Shorebird: Error checking for updates: $e');
    }
  }
}
