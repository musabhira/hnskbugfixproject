import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final userUploadedDir = Directory(
      r'C:\Users\user\.gemini\antigravity-ide\brain\2f3efc10-6c0e-4791-8d30-cdc0ace6d98c\.user_uploaded');
  final outDir = Directory(r'f:\pocket-mates-app-ne72dv\assets\images');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  print('Starting NFT asset extraction...');

  // 1. Single Trippy King Crown Ape
  final trippyApeFile =
      File('${userUploadedDir.path}\\media_1788431178654.png');
  if (trippyApeFile.existsSync()) {
    final bytes = trippyApeFile.readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded != null) {
      final outFile = File('${outDir.path}\\nft_trippy_king_ape.png');
      outFile.writeAsBytesSync(img.encodePng(decoded));
      print('Saved: nft_trippy_king_ape.png (${decoded.width}x${decoded.height})');
    }
  }

  // 2. Doges grid (3 rows x 5 cols)
  final dogesFile = File('${userUploadedDir.path}\\media_1788431073268.png');
  if (dogesFile.existsSync()) {
    final bytes = dogesFile.readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded != null) {
      final cellW = (decoded.width / 5).floor();
      final cellH = (decoded.height / 3).floor();
      int count = 1;
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 5; c++) {
          final cropped = img.copyCrop(
            decoded,
            x: c * cellW,
            y: r * cellH,
            width: cellW,
            height: cellH,
          );
          final outFile = File('${outDir.path}\\nft_doge_$count.png');
          outFile.writeAsBytesSync(img.encodePng(cropped));
          count++;
        }
      }
      print('Saved 15 Doge NFTs (nft_doge_1.png to nft_doge_15.png)');
    }
  }

  // 3. Apes grid (2 rows x 3 cols)
  final apesFile = File('${userUploadedDir.path}\\media_1788431237622.png');
  if (apesFile.existsSync()) {
    final bytes = apesFile.readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded != null) {
      final cellW = (decoded.width / 3).floor();
      final cellH = (decoded.height / 2).floor();
      int count = 1;
      for (int r = 0; r < 2; r++) {
        for (int c = 0; c < 3; c++) {
          final cropped = img.copyCrop(
            decoded,
            x: c * cellW,
            y: r * cellH,
            width: cellW,
            height: cellH,
          );
          final outFile = File('${outDir.path}\\nft_ape_$count.png');
          outFile.writeAsBytesSync(img.encodePng(cropped));
          count++;
        }
      }
      print('Saved 6 Ape NFTs (nft_ape_1.png to nft_ape_6.png)');
    }
  }

  // 4. Foxes/Wolves grid (3 rows x 3 cols)
  final foxesFile = File('${userUploadedDir.path}\\media_1788431134329.png');
  if (foxesFile.existsSync()) {
    final bytes = foxesFile.readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded != null) {
      final cellW = (decoded.width / 3).floor();
      final cellH = (decoded.height / 3).floor();
      int count = 1;
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          final cropped = img.copyCrop(
            decoded,
            x: c * cellW,
            y: r * cellH,
            width: cellW,
            height: cellH,
          );
          final outFile = File('${outDir.path}\\nft_fox_$count.png');
          outFile.writeAsBytesSync(img.encodePng(cropped));
          count++;
        }
      }
      print('Saved 9 Fox NFTs (nft_fox_1.png to nft_fox_9.png)');
    }
  }

  print('All NFT assets extracted successfully!');
}
