import 'dart:ui' as ui;
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:ffmpeg_kit_flutter_new_video/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_video/return_code.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class DualVideoRecorderWidget extends StatefulWidget {
  final double? width;
  final double? height;

  const DualVideoRecorderWidget({
    super.key,
    this.width,
    this.height,
  });

  @override
  State<DualVideoRecorderWidget> createState() => _DualVideoRecorderWidgetState();
}

class _DualVideoRecorderWidgetState extends State<DualVideoRecorderWidget> {
  bool _isProcessing = false;
  String _statusMessage = "";
  String? _lastVideoPath;

  Future<void> _processVideo(String inputPath) async {
    setState(() {
      _isProcessing = true;
      _statusMessage = "Processing Recording formats...";
    });

    try {
      final directory = await getTemporaryDirectory();
      final String portraitPath = "${directory.path}/reel_${DateTime.now().millisecondsSinceEpoch}.mp4";

      // FFmpeg command to crop center 9:16 from a 16:9 input (Reel format)
      final String ffmpegCommand = "-i \"$inputPath\" -vf \"crop=ih*9/16:ih\" -c:v libx264 -crf 23 -preset ultrafast -c:a copy \"$portraitPath\"";

      await FFmpegKit.execute(ffmpegCommand).then((session) async {
        final returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          setState(() => _statusMessage = "Saving both versions to Gallery...");
          
          await Gal.putVideo(inputPath); // YouTube/Full version
          await Gal.putVideo(portraitPath); // Reel version

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Success! YouTube (Landscape) and Reel (Portrait) videos saved."),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Format processing failed. Original saved."),
                backgroundColor: Colors.orange,
              ),
            );
          }
          await Gal.putVideo(inputPath);
        }
      });
    } catch (e) {
      debugPrint("Error in _processVideo: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraAwesomeBuilder.custom(
            sensorConfig: SensorConfig.multiple(
              sensors: [
                Sensor.position(SensorPosition.back),
                Sensor.position(SensorPosition.front),
              ],
              aspectRatio: CameraAspectRatios.ratio_16_9,
            ),
            saveConfig: SaveConfig.video(
              pathBuilder: (sensors) async {
                final directory = await getTemporaryDirectory();
                _lastVideoPath = "${directory.path}/yt_video_${DateTime.now().millisecondsSinceEpoch}.mp4";
                return SingleCaptureRequest(_lastVideoPath!, sensors.first);
              },
            ),
            builder: (cameraState, preview) {
              return cameraState.when(
                onPreparingCamera: (state) => const Center(child: CircularProgressIndicator(color: Colors.yellow)),
                onPhotoMode: (state) => _buildCameraUI(state, false),
                onVideoMode: (state) => _buildCameraUI(state, false),
                onVideoRecordingMode: (state) => _buildCameraUI(state, true),
              );
            },
          ),

          if (_isProcessing)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.yellow),
                    const SizedBox(height: 24),
                    Text(
                      _statusMessage,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Preparing your YouTube and Reel versions...",
                      style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraUI(CameraState state, bool isRecording) {
    return Stack(
      children: [
        // Guide Painter for Reels
        Positioned.fill(
          child: CustomPaint(
            painter: DualRecorderGuidePainter(),
          ),
        ),
        
        // Recording UI Controls
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Column(
            children: [
              if (isRecording)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "RECORDING DUAL",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera Flip/Switch
                  IconButton(
                    icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 32),
                    onPressed: () {
                      state.switchCameraSensor();
                    },
                  ),
                  
                  // Record Button
                  GestureDetector(
                    onTap: () {
                      state.when(
                        onVideoMode: (videoState) {
                          videoState.startRecording();
                        },
                        onVideoRecordingMode: (videoState) {
                          videoState.stopRecording();
                          if (_lastVideoPath != null) {
                            Future.delayed(const Duration(milliseconds: 700), () {
                              _processVideo(_lastVideoPath!);
                            });
                          }
                        },
                        onPreparingCamera: (state) {},
                        onPhotoMode: (state) {},
                      );
                    },
                    child: Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isRecording ? Colors.red : Colors.white24,
                          shape: isRecording ? BoxShape.rectangle : BoxShape.circle,
                          borderRadius: isRecording ? BorderRadius.circular(12) : null,
                        ),
                      ),
                    ),
                  ),

                  // Close Button
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DualRecorderGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final dashPaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    double height = size.height;
    double portraitWidth = height * (9 / 16);
    
    Rect portraitRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: portraitWidth,
      height: height,
    );

    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    
    // Mask non-reel areas
    canvas.drawRect(Rect.fromLTRB(0, 0, portraitRect.left, size.height), shadowPaint);
    canvas.drawRect(Rect.fromLTRB(portraitRect.right, 0, size.width, size.height), shadowPaint);

    // Draw borders
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    canvas.drawRect(portraitRect, dashPaint);

    final textStyle = GoogleFonts.outfit(color: Colors.yellow, fontSize: 11, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: TextSpan(text: "REEL CROP ZONE (9:16)", style: textStyle),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, size.height * 0.15));
    
    final ytTextStyle = GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold);
    final ytPainter = TextPainter(
      text: TextSpan(text: "YOUTUBE FULL ZONE (16:9)", style: ytTextStyle),
      textDirection: ui.TextDirection.ltr,
    );
    ytPainter.layout();
    ytPainter.paint(canvas, const Offset(20, 40));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
