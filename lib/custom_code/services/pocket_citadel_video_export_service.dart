import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new_video/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_video/return_code.dart';

/// 🎬 Citadel Story Video Export Service
/// Generates 15-second high-aesthetic Instagram Story & Reel MP4 videos
/// with background music combined with the captured citadel poster card.
class PocketCitadelVideoExportService {
  static const String defaultBgmAsset = 'assets/audio/bgm/happy_whistler.mp3';

  /// 🎵 Extract BGM asset to temporary file
  static Future<File?> _prepareAudioFile(String? assetPath) async {
    try {
      final effectivePath = assetPath ?? defaultBgmAsset;
      final byteData = await rootBundle.load(effectivePath);
      final tempDir = await getTemporaryDirectory();
      final audioFile = File('${tempDir.path}/citadel_bgm_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await audioFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
      return audioFile;
    } catch (e) {
      debugPrint('Failed to extract BGM asset: $e');
      return null;
    }
  }

  /// 🎥 Render a 15-second MP4 video combining image card and audio track
  static Future<File?> generateStoryVideo({
    required File imageFile,
    int durationSeconds = 15,
    String? bgmAssetPath,
  }) async {
    try {
      // Guard against non-mobile platforms where native FFmpeg binaries are absent
      if (!Platform.isAndroid && !Platform.isIOS) {
        debugPrint('FFmpeg video export is supported on Android and iOS devices.');
        return null;
      }

      final tempDir = await getTemporaryDirectory();
      final audioFile = await _prepareAudioFile(bgmAssetPath);
      final outVideoPath = '${tempDir.path}/PoketMates_Story_${DateTime.now().millisecondsSinceEpoch}.mp4';

      final String ffmpegCmd;
      if (audioFile != null && await audioFile.exists()) {
        // Loop image, add audio, encode H.264 + AAC, clamp duration to 15s
        ffmpegCmd = '-y -loop 1 -i "${imageFile.path}" -i "${audioFile.path}" '
            '-c:v libx264 -t $durationSeconds -pix_fmt yuv420p '
            '-vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" '
            '-c:a aac -b:a 192k -shortest "$outVideoPath"';
      } else {
        // Fallback without audio
        ffmpegCmd = '-y -loop 1 -i "${imageFile.path}" '
            '-c:v libx264 -t $durationSeconds -pix_fmt yuv420p '
            '-vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" "$outVideoPath"';
      }

      debugPrint('Executing FFmpeg Story Video Command: $ffmpegCmd');
      final session = await FFmpegKit.execute(ffmpegCmd);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        final videoFile = File(outVideoPath);
        if (await videoFile.exists() && await videoFile.length() > 0) {
          debugPrint('Successfully rendered story video (${await videoFile.length()} bytes)');
          return videoFile;
        }
      }

      final failLogs = await session.getAllLogsAsString();
      debugPrint('FFmpeg Story Video failed: $failLogs');
      return null;
    } catch (e) {
      debugPrint('Error generating citadel story video: $e');
      return null;
    }
  }
}
