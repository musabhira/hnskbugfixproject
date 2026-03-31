// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:universal_html/html.dart' as html;

class ImageCropSplitPage extends StatefulWidget {
  const ImageCropSplitPage({super.key, this.width, this.height});
  final double? width;
  final double? height;

  @override
  State<ImageCropSplitPage> createState() => _ImageCropSplitPageState();
}

class _ImageCropSplitPageState extends State<ImageCropSplitPage> {
  File? _selectedImage;
  Uint8List? _imageBytes;
  ui.Image? _uiImage;

  final List<Map<String, dynamic>> _cropFormats = [
    {
      'name': 'Instagram Square',
      'size': const Size(1080, 1080),
      'icon': Icons.crop_square
    },
    {
      'name': 'Instagram Portrait',
      'size': const Size(1080, 1350),
      'icon': Icons.crop_portrait
    },
    {
      'name': 'Instagram Story',
      'size': const Size(1080, 1920),
      'icon': Icons.crop_16_9
    },
  ];

  Map<String, dynamic>? _selectedFormat;
  int _numberOfCuts = 1;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Image Crop & Split',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.amber),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.grey.shade900,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step 1: Image Upload Section
              _buildStepCard(
                stepNumber: 1,
                title: 'Upload Image',
                icon: Icons.cloud_upload_outlined,
                child: _buildImageUploadSection(),
              ),

              // Step 2: Format Selection
              if (_imageBytes != null) ...[
                const SizedBox(height: 20),
                _buildStepCard(
                  stepNumber: 2,
                  title: 'Select Crop Format',
                  icon: Icons.aspect_ratio,
                  child: _buildFormatSelectionSection(),
                ),
              ],

              // Step 3: Number of Cuts
              if (_selectedFormat != null) ...[
                const SizedBox(height: 20),
                _buildStepCard(
                  stepNumber: 3,
                  title: 'Configure Cuts (Unlimited)',
                  icon: Icons.content_cut,
                  child: _buildCutsConfigurationSection(),
                ),
              ],

              // Step 4: Process Button
              if (_selectedFormat != null) ...[
                const SizedBox(height: 30),
                _buildProcessButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required int stepNumber,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '$stepNumber',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  icon,
                  color: Colors.amber,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    if (_imageBytes == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
          borderRadius: BorderRadius.circular(12),
          color: Colors.black,
        ),
        child: InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(12),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 60,
                  color: Colors.amber,
                ),
                SizedBox(height: 12),
                Text(
                  'Tap to upload image',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Supports JPG, PNG formats',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Column(
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
              color: Colors.black,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                _imageBytes!,
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.refresh, color: Colors.black),
              label: const Text(
                'Change Image',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildFormatSelectionSection() {
    return Column(
      children: _cropFormats.map((format) {
        final bool isSelected = _selectedFormat == format;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color:
                isSelected ? Colors.amber.withOpacity(0.1) : Colors.transparent,
            border: Border.all(
              color: isSelected ? Colors.amber : Colors.grey.shade700,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(
              format['icon'],
              color: isSelected ? Colors.amber : Colors.grey.shade400,
              size: 30,
            ),
            title: Text(
              format['name'],
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              '${format['size'].width.toInt()} x ${format['size'].height.toInt()} pixels',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
            trailing: Radio<Map<String, dynamic>>(
              value: format,
              groupValue: _selectedFormat,
              onChanged: (value) {
                setState(() {
                  _selectedFormat = value;
                });
              },
              activeColor: Colors.amber,
            ),
            onTap: () {
              setState(() {
                _selectedFormat = format;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCutsConfigurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Unlimited Cuts Info',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '• Each cut will be exactly 1080px wide\n• Cuts beyond image content will have white space\n• No limits on number of cuts - split as many as you want\n• Example: 3 cuts = 1080+1080+remaining with white space',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              _buildAnalysisRow('Output Size',
                  '1080 x ${_selectedFormat!['size'].height.toInt()} pixels per cut'),
              _buildAnalysisRow('Selected Cuts', '$_numberOfCuts cuts',
                  isHighlight: true),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Manual input field for number of cuts
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.content_cut, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Number of cuts:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.amber.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _numberOfCuts > 1
                            ? () => setState(() => _numberOfCuts--)
                            : null,
                        icon: const Icon(Icons.remove),
                        color: _numberOfCuts > 1 ? Colors.amber : Colors.grey,
                      ),
                      Container(
                        width: 80,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: TextField(
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                          ),
                          controller:
                              TextEditingController(text: '$_numberOfCuts'),
                          onChanged: (value) {
                            final int? newValue = int.tryParse(value);
                            if (newValue != null &&
                                newValue >= 1 &&
                                newValue <= 100) {
                              // reasonable upper limit for performance
                              setState(() {
                                _numberOfCuts = newValue;
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() {
                          if (_numberOfCuts < 100)
                            _numberOfCuts++; // reasonable upper limit
                        }),
                        icon: const Icon(Icons.add),
                        color: Colors.amber,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Quick selection buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickCutButton('2', 2),
                _buildQuickCutButton('3', 3),
                _buildQuickCutButton('5', 5),
                _buildQuickCutButton('10', 10),
                _buildQuickCutButton('20', 20),
                _buildQuickCutButton('50', 50),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            border: Border.all(
              color: Colors.green.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ready to create $_numberOfCuts images of 1080 x ${_selectedFormat!['size'].height.toInt()} pixels each. Empty areas will be filled with white space.',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickCutButton(String label, int cuts) {
    final bool isSelected = _numberOfCuts == cuts;
    return GestureDetector(
      onTap: () => setState(() => _numberOfCuts = cuts),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.grey.shade600,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value,
      {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? Colors.amber : Colors.grey.shade300,
              fontSize: 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isProcessing
              ? [Colors.grey.shade700, Colors.grey.shade800]
              : [Colors.amber, Colors.orange],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processAndDownloadImages,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isProcessing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Processing...',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.download_rounded,
                    color: Colors.black,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Crop & Download $_numberOfCuts Images',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo frameInfo = await codec.getNextFrame();

        setState(() {
          if (!kIsWeb) {
            _selectedImage = File(image.path);
          }
          _imageBytes = bytes;
          _uiImage = frameInfo.image;
          _selectedFormat = null;
          _numberOfCuts = 1;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<void> _processAndDownloadImages() async {
    if (_imageBytes == null || _selectedFormat == null || _uiImage == null)
      return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Show processing dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey.shade900,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.amber),
              const SizedBox(height: 20),
              Text(
                'Processing $_numberOfCuts images...',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );

      final Size targetSize = _selectedFormat!['size'];
      final double cropWidth = 1080.0;
      final double cropHeight = targetSize.height;

      // Process all requested cuts without any limits
      for (int i = 0; i < _numberOfCuts; i++) {
        final croppedImage = await _createCutImage(
          _uiImage!,
          Size(cropWidth, cropHeight),
          i,
          cropWidth,
        );

        final byteData =
            await croppedImage.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();
          await _downloadImage(pngBytes, i + 1);
        }

        croppedImage.dispose();
      }

      // Hide processing dialog
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      _showSuccessSnackBar(
          'Successfully created and downloaded $_numberOfCuts images!');
    } catch (e) {
      // Hide processing dialog
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      _showErrorSnackBar('Error processing images: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<ui.Image> _createCutImage(ui.Image sourceImage, Size targetSize,
      int cutIndex, double cropWidth) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Always fill with white background first
    canvas.drawRect(
      Rect.fromLTWH(0, 0, cropWidth, targetSize.height),
      Paint()..color = Colors.white,
    );

    // Scale image to fit target height
    final double scaleY = targetSize.height / sourceImage.height;
    final double scaledImageWidth = sourceImage.width * scaleY;

    // Calculate what portion of the scaled image this cut should show
    final double cutStartX = cutIndex * cropWidth;

    // If the cut starts beyond the scaled image width, return blank (white) image
    if (cutStartX >= scaledImageWidth) {
      final picture = recorder.endRecording();
      final image =
          await picture.toImage(cropWidth.toInt(), targetSize.height.toInt());
      picture.dispose();
      return image;
    }

    // Calculate how much of this cut can be filled with actual image content
    final double availableWidth =
        (scaledImageWidth - cutStartX).clamp(0.0, cropWidth);

    if (availableWidth > 0) {
      // Calculate source rectangle in original image coordinates
      final double sourceStartX = cutStartX / scaleY;
      final double sourceWidth = availableWidth / scaleY;

      final srcRect = Rect.fromLTWH(
        sourceStartX.clamp(0.0, sourceImage.width.toDouble()),
        0,
        sourceWidth.clamp(
            0.0,
            sourceImage.width.toDouble() -
                sourceStartX.clamp(0.0, sourceImage.width.toDouble())),
        sourceImage.height.toDouble(),
      );

      final dstRect = Rect.fromLTWH(0, 0, availableWidth, targetSize.height);

      canvas.drawImageRect(sourceImage, srcRect, dstRect, Paint());
    }

    // The remaining area (if any) will stay white as we filled it at the beginning

    final picture = recorder.endRecording();
    final image =
        await picture.toImage(cropWidth.toInt(), targetSize.height.toInt());
    picture.dispose();

    return image;
  }

  Future<void> _downloadImage(Uint8List pngBytes, int index) async {
    final String fileName =
        '${_selectedFormat!['name'].toLowerCase().replaceAll(' ', '_')}_part_${index.toString().padLeft(3, '0')}_${DateTime.now().millisecondsSinceEpoch}';

    if (kIsWeb) {
      // Web download
      final blob = html.Blob([pngBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = '$fileName.png';
      html.document.body!.children.add(anchor);
      anchor.click();
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } else {
      // Mobile save to gallery
      await Gal.putImageBytes(
        pngBytes,
        name: fileName,
        album: "Cropped Images",
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(message,
                      style: const TextStyle(color: Colors.white))),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
