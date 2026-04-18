import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

enum VideoType { asset, network, file }

class FlutterFlowVideoLayer extends StatefulWidget {
  const FlutterFlowVideoLayer({
    super.key,
    required this.path,
    this.videoType = VideoType.network,
    this.autoPlay = false,
    this.looping = false,
    this.showControls = true,
    this.allowFullScreen = false,
    this.allowPlaybackSpeedMenu = false,
    this.onProgress,
    this.onCompleted,
  });

  final String path;
  final VideoType videoType;
  final bool autoPlay;
  final bool looping;
  final bool showControls;
  final bool allowFullScreen;
  final bool allowPlaybackSpeedMenu;
  final Function(double)? onProgress;
  final VoidCallback? onCompleted;

  @override
  State<FlutterFlowVideoLayer> createState() => _FlutterFlowVideoLayerState();
}

class _FlutterFlowVideoLayerState extends State<FlutterFlowVideoLayer> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    switch (widget.videoType) {
      case VideoType.network:
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.path));
        break;
      case VideoType.asset:
        _controller = VideoPlayerController.asset(widget.path);
        break;
      case VideoType.file:
        // Use a fallback to network if it's file type, or assuming it's an absolute path that can be parsed as URI
        _controller = VideoPlayerController.networkUrl(Uri.file(widget.path));
        break;
    }

    _controller?.initialize().then((_) {
      if (mounted) {
        setState(() {});
        if (widget.looping) {
          _controller?.setLooping(true);
        }
        if (widget.autoPlay) {
          _controller?.play();
        }
        _controller?.addListener(_videoListener);
      }
    }).catchError((error) {
      debugPrint('Video initialization error: $error');
    });
  }

  void _videoListener() {
    if (!mounted || _controller == null) return;

    if (_isPlaying != _controller?.value.isPlaying) {
      setState(() {
        _isPlaying = _controller?.value.isPlaying ?? false;
      });
    }

    if (_controller!.value.isInitialized) {
      final position = _controller!.value.position;
      final duration = _controller!.value.duration;

      if (duration.inMilliseconds > 0) {
        final progress =
            position.inMilliseconds / duration.inMilliseconds;
        widget.onProgress?.call(progress);

        if (position >= duration && !_controller!.value.isPlaying) {
          widget.onCompleted?.call();
        }
      }
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.yellow));
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),
          ),
          if (widget.showControls) _buildControls(),
        ],
      );
    });
  }

  Widget _buildControls() {
    return GestureDetector(
      onTap: () {
        if (_controller!.value.isPlaying) {
          _controller!.pause();
        } else {
          _controller!.play();
        }
      },
      child: Container(
        color: Colors.black.withValues(alpha: 0.01), // Capture taps smoothly
        child: Center(
          child: AnimatedOpacity(
            opacity: _isPlaying ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 32.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
