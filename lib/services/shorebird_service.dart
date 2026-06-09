import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class ShorebirdService {
  static final ShorebirdService _instance = ShorebirdService._internal();
  factory ShorebirdService() => _instance;
  ShorebirdService._internal();

  // v2 API: ShorebirdCodePush renamed to ShorebirdUpdater
  final _updater = ShorebirdUpdater();

  /// Initializes Shorebird and checks for updates (non-blocking)
  Future<void> initialize() async {
    if (kIsWeb) return;

    debugPrint('Shorebird: Initializing...');

    try {
      // Check if Shorebird is available on this platform
      final isAvailable = _updater.isAvailable;
      if (!isAvailable) {
        debugPrint('Shorebird: Not available on this device/platform.');
        return;
      }

      // Read current patch info
      final currentPatch = await _updater.readCurrentPatch();
      debugPrint(
        'Shorebird: Current patch: ${currentPatch?.number ?? "None (Base Build)"}',
      );

      // Check for updates without blocking startup
      checkForUpdates();
    } catch (e) {
      debugPrint('Shorebird: Initialization error: $e');
    }
  }

  /// Checks for updates and downloads them if available.
  /// Non-blocking — does not await in caller.
  Future<void> checkForUpdates() async {
    try {
      final status = await _updater.checkForUpdate();

      switch (status) {
        case UpdateStatus.upToDate:
          debugPrint('Shorebird: App is up to date.');
        case UpdateStatus.outdated:
          debugPrint('Shorebird: New update found! Downloading...');
          await _updater.update();
          debugPrint('Shorebird: Update downloaded. Will apply on next restart.');
        case UpdateStatus.restartRequired:
          debugPrint('Shorebird: Update already downloaded. Please restart the app.');
        case UpdateStatus.unavailable:
          debugPrint('Shorebird: Updates unavailable (not a Shorebird build).');
      }
    } catch (e) {
      debugPrint('Shorebird: Error checking for updates: $e');
    }
  }
}
