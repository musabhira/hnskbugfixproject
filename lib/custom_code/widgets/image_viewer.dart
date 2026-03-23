import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:gal/gal.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ImageViewer extends StatelessWidget {
  final String imageUrl;
  final String? title;

  const ImageViewer({super.key, required this.imageUrl, this.title});

  Future<void> _downloadImage(BuildContext context) async {
    try {
      // Check permissions (gal handles most of this but we use path_provider for temp)
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Download the file
      await Dio().download(imageUrl, path);

      // Save to gallery
      await Gal.putImage(path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image downloaded to gallery'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      debugPrint(error.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download image: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          title ?? 'View Image',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () => _downloadImage(context),
            tooltip: 'Download Image',
          ),
        ],
      ),
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: PhotoView(
            imageProvider: NetworkImage(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(color: Colors.yellow),
            ),
          ),
        ),
      ),
    );
  }
}
