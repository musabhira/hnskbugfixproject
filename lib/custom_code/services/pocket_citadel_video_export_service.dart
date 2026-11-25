import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new_video/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_video/return_code.dart';

/// 🎬 Citadel Story Video Export Service
/// Generates HD animated MP4 videos (Square, Portrait, or Story)
/// with smooth Ken Burns zoom motion + background music for Android & iOS.
class PocketCitadelVideoExportService {
  static const String defaultBgmAsset = 'assets/audio/bgm/happy_whistler.mp3';

  /// 🎵 Extract BGM asset to temporary file
  static Future<File?> _prepareAudioFile(String? assetPath) async {
    try {
      final effectivePath = assetPath ?? defaultBgmAsset;
      final byteData = await rootBundle.load(effectivePath);
      final tempDir = await getTemporaryDirectory();
      final audioFile = File(
        '${tempDir.path}/citadel_bgm_${DateTime.now().millisecondsSinceEpoch}.mp3',
      );
      await audioFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
      return audioFile;
    } catch (e) {
      debugPrint('Failed to extract BGM asset: $e');
      return null;
    }
  }

  /// Read PNG dimensions from header (bytes 16..23) and scale to crisp HD (max width 1080, even dims)
  static Future<(int, int)> _computeHdVideoSize(File imageFile) async {
    try {
      final raf = await imageFile.open();
      final header = await raf.read(24);
      await raf.close();
      if (header.length >= 24 &&
          header[0] == 0x89 &&
          header[1] == 0x50 &&
          header[2] == 0x4E &&
          header[3] == 0x47) {
        final bd = ByteData.sublistView(header);
        final rawW = bd.getUint32(16, Endian.big);
        final rawH = bd.getUint32(20, Endian.big);
        if (rawW > 0 && rawH > 0) {
          const int targetMaxW = 1080;
          final double scale = rawW > targetMaxW ? targetMaxW / rawW : 1.0;
          int outW = ((rawW * scale).round() ~/ 2) * 2;
          int outH = ((rawH * scale).round() ~/ 2) * 2;
          if (outW < 480) outW = 480;
          if (outH < 480) outH = 480;
          return (outW, outH);
        }
      }
    } catch (e) {
      debugPrint('Could not read PNG dimensions: $e');
    }
    return (1080, 1920);
  }

  /// 🎥 Render an HD animated MP4 video combining image card and audio track
  static Future<File?> generateStoryVideo({
    required File imageFile,
    int durationSeconds = 5,
    String? bgmAssetPath,
    bool animate = true,
  }) async {
    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        debugPrint(
            'FFmpeg video export is supported on Android and iOS devices.');
        return null;
      }

      final tempDir = await getTemporaryDirectory();
      final audioFile = await _prepareAudioFile(bgmAssetPath);
      final outVideoPath =
          '${tempDir.path}/PoketMates_Story_${DateTime.now().millisecondsSinceEpoch}.mp4';

      final (outW, outH) = await _computeHdVideoSize(imageFile);
      const int fps = 30;
      final int totalFrames = durationSeconds * fps;

      // Smooth Ken Burns zoom-in + subtle fade-in preserving exact aspect ratio
      final String vfFilter = animate
          ? 'scale=${outW * 2}:${outH * 2}:flags=lanczos,'
              "zoompan=z='min(zoom+0.0012,1.14)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=$totalFrames:s=${outW}x$outH:fps=$fps,"
              'fade=t=in:st=0:d=0.35,format=yuv420p'
          : 'scale=$outW:$outH:flags=lanczos,format=yuv420p';

      final bool hasAudio = audioFile != null && await audioFile.exists();
      final String inputPart = hasAudio
          ? '-y -loop 1 -i "${imageFile.path}" -i "${audioFile.path}"'
          : '-y -loop 1 -i "${imageFile.path}"';
      final String audioPart =
          hasAudio ? '-c:a aac -b:a 192k -shortest' : '-an';

      // iOS: prefer hardware h264_videotoolbox (works without GPL libx264), then libx264, then mpeg4
      final List<String> codecCandidates = Platform.isIOS
          ? [
              '-c:v h264_videotoolbox -b:v 6M -profile:v main',
              '-c:v libx264 -preset veryfast -crf 18 -profile:v main',
              '-c:v mpeg4 -q:v 2',
            ]
          : [
              '-c:v libx264 -preset veryfast -crf 18 -profile:v main',
              '-c:v mpeg4 -q:v 2',
            ];

      for (final videoCodec in codecCandidates) {
        final cmd =
            '$inputPart -t $durationSeconds -vf "$vfFilter" $videoCodec -pix_fmt yuv420p -movflags +faststart $audioPart "$outVideoPath"';
        debugPrint('Executing FFmpeg Story Video Command: $cmd');
        final session = await FFmpegKit.execute(cmd);
        final returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          final videoFile = File(outVideoPath);
          if (await videoFile.exists() && await videoFile.length() > 0) {
            debugPrint(
              'Successfully rendered animated story video (${await videoFile.length()} bytes) with $videoCodec',
            );
            return videoFile;
          }
        } else {
          final failLogs = await session.getAllLogsAsString();
          debugPrint('FFmpeg attempt ($videoCodec) failed: $failLogs');
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error generating citadel story video: $e');
      return null;
    }
  }
}
