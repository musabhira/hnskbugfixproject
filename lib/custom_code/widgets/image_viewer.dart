import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:flutter/services.dart';

class ImageViewer extends StatelessWidget {
  final String imageUrl;
  final String? title;

  const ImageViewer({super.key, required this.imageUrl, this.title});

  Future<void> _downloadImage(BuildContext context) async {
    try {
      // Check permissions (handled by the library on modern android, but good to be safe)
      var imageId = await ImageDownloader.downloadImage(imageUrl);
      if (imageId == null) {
        return;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image downloaded to gallery'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on PlatformException catch (error) {
      debugPrint(error.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download image: ${error.message}'),
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
