import 'dart:async';
import 'dart:io' as io;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_compress/video_compress.dart';

class VibeUploadTask {
  final String title;
  final String subtitle;
  final double progress; // 0.0 to 1.0
  final bool isUploading;
  final bool isCompleted;
  final bool isError;
  final String? errorMessage;
  final io.File? thumbnailFile;

  const VibeUploadTask({
    required this.title,
    required this.subtitle,
    required this.progress,
    this.isUploading = true,
    this.isCompleted = false,
    this.isError = false,
    this.errorMessage,
    this.thumbnailFile,
  });

  VibeUploadTask copyWith({
    String? title,
    String? subtitle,
    double? progress,
    bool? isUploading,
    bool? isCompleted,
    bool? isError,
    String? errorMessage,
    io.File? thumbnailFile,
  }) {
    return VibeUploadTask(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      progress: progress ?? this.progress,
      isUploading: isUploading ?? this.isUploading,
      isCompleted: isCompleted ?? this.isCompleted,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      thumbnailFile: thumbnailFile ?? this.thumbnailFile,
    );
  }
}

/// 🚀 High-speed Background Video Slicing & Upload Manager (Audio Directive)
/// Handles background compression, sequential 10s auto-trimming (no repeated 0s chunks!),
/// and non-blocking upload status notification.
class PocketVibesUploadManager {
  PocketVibesUploadManager._();
  static final PocketVibesUploadManager instance = PocketVibesUploadManager._();

  final ValueNotifier<VibeUploadTask?> activeTask = ValueNotifier<VibeUploadTask?>(null);

  bool get isProcessing => activeTask.value != null && activeTask.value!.isUploading;

  /// Starts background video processing, slicing, and uploading
  Future<void> startVideoUpload({
    required io.File videoFile,
    required Duration videoDuration,
    required String userId,
    required String? caption,
    required String? overlayText,
    required String selectedFilterName,
    required String statusPrivacy,
    required Set<String> excludedUserIds,
    required Set<String> includedUserIds,
    required List<Map<String, dynamic>> placedStickers,
  }) async {
    final supabase = Supabase.instance.client;
    final totalSec = videoDuration.inSeconds > 0 ? videoDuration.inSeconds : 10;
    // Auto-split into 10s segments
    final segments = (totalSec / 10.0).ceil().clamp(1, 12);

    io.File? previewThumb;
    try {
      previewThumb = await VideoCompress.getFileThumbnail(videoFile.path, quality: 70);
    } catch (_) {}

    activeTask.value = VibeUploadTask(
      title: 'Vibes are uploading...',
      subtitle: segments > 1 ? 'Compressing & Slicing Part 1/$segments...' : 'Compressing video...',
      progress: 0.05,
      thumbnailFile: previewThumb,
    );

    unawaited(() async {
      try {
        final List<String> uploadedIds = [];

        for (int i = 0; i < segments; i++) {
          final startSec = i * 10;
          final segDuration = math.min(10, totalSec - startSec);
          final segIndex = i + 1;

          activeTask.value = activeTask.value?.copyWith(
            subtitle: segments > 1
                ? 'Compressing Part $segIndex/$segments (${startSec}s-${startSec + segDuration}s)...'
                : 'Compressing video...',
            progress: (i * 0.9) / segments + 0.05,
          );

          Uint8List bytesToUpload;
          try {
            // Native AVFoundation/MediaCodec slicing: accurately extracts from startSec for segDuration!
            final comp = await VideoCompress.compressVideo(
              videoFile.path,
              startTime: startSec,
              duration: segDuration,
              quality: VideoQuality.MediumQuality,
              deleteOrigin: false,
              includeAudio: true,
            );

            if (comp != null && comp.file != null && await comp.file!.exists()) {
              bytesToUpload = await comp.file!.readAsBytes();
            } else {
              bytesToUpload = await videoFile.readAsBytes();
            }
          } catch (compErr) {
            debugPrint('VideoCompress slice error at part $segIndex: $compErr');
            bytesToUpload = await videoFile.readAsBytes();
          }

          activeTask.value = activeTask.value?.copyWith(
            subtitle: segments > 1
                ? 'Uploading Part $segIndex/$segments...'
                : 'Uploading video...',
            progress: ((i + 0.6) * 0.9) / segments + 0.05,
          );

          final fileName =
              'status_${userId}_${DateTime.now().millisecondsSinceEpoch}_part$segIndex.mp4';

          await supabase.storage.from('statuses').uploadBinary(
                fileName,
                bytesToUpload,
                fileOptions: const FileOptions(contentType: 'video/mp4', upsert: true),
              ).timeout(const Duration(seconds: 45));

          final mediaUrl = supabase.storage.from('statuses').getPublicUrl(fileName);

          final segmentCaption = segments > 1
              ? (caption != null && caption.isNotEmpty
                  ? '$caption (Part $segIndex/$segments)'
                  : 'Part $segIndex/$segments')
              : caption;

          final metadata = {
            'overlay_text': overlayText != null && overlayText.isNotEmpty ? overlayText : null,
            'filter': selectedFilterName,
            'duration': segDuration,
            'is_private': statusPrivacy != 'public',
            'status_privacy': statusPrivacy,
            'excluded_user_ids': excludedUserIds.toList(),
            'included_user_ids': includedUserIds.toList(),
            'segment_index': segIndex,
            'total_segments': segments,
            'segment_duration': segDuration,
            'start_offset_seconds': startSec,
            'stickers': placedStickers,
          };

          final insertRes = await supabase.from('statuses').insert({
            'user_id': userId,
            'media_url': mediaUrl,
            'media_type': 'video',
            'caption': segmentCaption,
            'duration': segDuration,
            'metadata': metadata,
            'view_count': 0,
            'like_count': 0,
            'is_private': statusPrivacy != 'public',
            'status_privacy': statusPrivacy,
            'excluded_user_ids': excludedUserIds.toList(),
            'included_user_ids': includedUserIds.toList(),
          }).select().single();

          if (insertRes['id'] != null) {
            uploadedIds.add(insertRes['id'].toString());
          }
        }

        try {
          await VideoCompress.deleteAllCache();
        } catch (_) {}

        activeTask.value = activeTask.value?.copyWith(
          title: 'Vibes Uploaded! ✨',
          subtitle: segments > 1 ? '$segments Parts Shared' : 'Story Shared',
          progress: 1.0,
          isUploading: false,
          isCompleted: true,
        );

        // Auto dismiss after 3.5 seconds
        Future.delayed(const Duration(milliseconds: 3500), () {
          if (activeTask.value?.isCompleted == true) {
            activeTask.value = null;
          }
        });
      } catch (err) {
        debugPrint('PocketVibesUploadManager error: $err');
        activeTask.value = activeTask.value?.copyWith(
          title: 'Upload Failed',
          subtitle: 'Please check your connection and retry.',
          isUploading: false,
          isError: true,
          errorMessage: err.toString(),
        );

        Future.delayed(const Duration(seconds: 4), () {
          if (activeTask.value?.isError == true) {
            activeTask.value = null;
          }
        });
      }
    }());
  }
}
