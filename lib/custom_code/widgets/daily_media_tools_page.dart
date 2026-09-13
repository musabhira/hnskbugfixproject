import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new_video/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_video/return_code.dart';

class DailyMediaToolsPage extends StatefulWidget {
  const DailyMediaToolsPage({super.key});

  @override
  State<DailyMediaToolsPage> createState() => _DailyMediaToolsPageState();
}

class _DailyMediaToolsPageState extends State<DailyMediaToolsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- TAB 1: VIDEO COMPRESSOR ---
  File? _pickedVideo;
  int? _originalSizeBytes;
  MediaInfo? _compressedInfo;
  bool _isCompressing = false;
  double _compressProgress = 0.0;
  Subscription? _compressSubscription;
  VideoQuality _selectedQuality = VideoQuality.MediumQuality;

  // --- TAB 2: AUDIO EXTRACTOR ---
  File? _audioSourceVideo;
  File? _extractedAudioFile;
  bool _isExtractingAudio = false;

  // --- TAB 3: IMAGE TO PDF ---
  final List<XFile> _selectedPdfImages = [];
  bool _isGeneratingPdf = false;
  File? _generatedPdfFile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _compressSubscription?.unsubscribe();
    _tabController.dispose();
    super.dispose();
  }

  // --- VIDEO COMPRESSOR METHODS ---
  Future<void> _pickVideoForCompression() async {
    HapticFeedback.selectionClick();
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      final size = await file.length();
      setState(() {
        _pickedVideo = file;
        _originalSizeBytes = size;
        _compressedInfo = null;
        _compressProgress = 0.0;
      });
    }
  }

  Future<void> _compressVideo() async {
    if (_pickedVideo == null) return;
    setState(() {
      _isCompressing = true;
      _compressProgress = 0.0;
    });

    _compressSubscription?.unsubscribe();
    _compressSubscription = VideoCompress.compressProgress$.subscribe((progress) {
      if (mounted) {
        setState(() => _compressProgress = progress / 100.0);
      }
    });

    try {
      final info = await VideoCompress.compressVideo(
        _pickedVideo!.path,
        quality: _selectedQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      setState(() {
        _compressedInfo = info;
        _isCompressing = false;
      });
      HapticFeedback.heavyImpact();
    } catch (e) {
      setState(() => _isCompressing = false);
      _showToast('Compression failed. Please try another quality preset.');
    }
  }

  // --- AUDIO EXTRACTOR METHODS ---
  Future<void> _pickVideoForAudio() async {
    HapticFeedback.selectionClick();
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _audioSourceVideo = File(picked.path);
        _extractedAudioFile = null;
      });
      _extractAudio();
    }
  }

  Future<void> _extractAudio() async {
    if (_audioSourceVideo == null) return;
    setState(() => _isExtractingAudio = true);

    try {
      final tempDir = await getTemporaryDirectory();
      final outPath =
          '${tempDir.path}/extracted_audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final ffmpegCmd =
          '-y -i "${_audioSourceVideo!.path}" -vn -c:a libmp3lame -b:a 192k "$outPath"';
      final session = await FFmpegKit.execute(ffmpegCmd);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode) && await File(outPath).exists()) {
        setState(() {
          _extractedAudioFile = File(outPath);
          _isExtractingAudio = false;
        });
        HapticFeedback.heavyImpact();
      } else {
        // Fallback: copy audio stream directly
        final fallbackPath =
            '${tempDir.path}/extracted_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        final fallbackCmd =
            '-y -i "${_audioSourceVideo!.path}" -vn -c:a copy "$fallbackPath"';
        final fbSession = await FFmpegKit.execute(fallbackCmd);
        final fbCode = await fbSession.getReturnCode();
        if (ReturnCode.isSuccess(fbCode) && await File(fallbackPath).exists()) {
          setState(() {
            _extractedAudioFile = File(fallbackPath);
            _isExtractingAudio = false;
          });
          HapticFeedback.heavyImpact();
        } else {
          throw Exception('Audio extraction failed');
        }
      }
    } catch (e) {
      setState(() => _isExtractingAudio = false);
      _showToast('Failed to extract audio track.');
    }
  }

  // --- IMAGE TO PDF METHODS ---
  Future<void> _pickImagesForPdf() async {
    HapticFeedback.selectionClick();
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _selectedPdfImages.addAll(picked);
        _generatedPdfFile = null;
      });
    }
  }

  Future<void> _generatePdfDocument() async {
    if (_selectedPdfImages.isEmpty || _isGeneratingPdf) return;

    setState(() => _isGeneratingPdf = true);

    try {
      final tempDir = await getTemporaryDirectory();
      final pdfPath =
          '${tempDir.path}/Document_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Assemble a compliant standard PDF file from image bytes
      final pdfBytes = await _createSimplePdfBytes(_selectedPdfImages);
      final pdfFile = File(pdfPath);
      await pdfFile.writeAsBytes(pdfBytes);

      setState(() {
        _generatedPdfFile = pdfFile;
        _isGeneratingPdf = false;
      });

      HapticFeedback.heavyImpact();
    } catch (e) {
      setState(() => _isGeneratingPdf = false);
      _showToast('PDF generation failed: $e');
    }
  }

  // Standard pure-Dart lightweight PDF generator for images
  Future<List<int>> _createSimplePdfBytes(List<XFile> images) async {
    final buffer = StringBuffer();
    // PDF header
    buffer.write('%PDF-1.4\n');

    List<int> fullBytes = utf8.encode(buffer.toString());
    List<int> offsets = [];

    // Catalog & Pages root
    offsets.add(fullBytes.length);
    fullBytes.addAll(utf8.encode(
        '1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n'));

    // We will build page objects
    int pageCount = images.length;
    List<String> pageRefs = [];
    for (int i = 0; i < pageCount; i++) {
      pageRefs.add('${3 + i * 3} 0 R');
    }

    offsets.add(fullBytes.length);
    fullBytes.addAll(utf8.encode(
        '2 0 obj\n<< /Type /Pages /Kids [${pageRefs.join(" ")}] /Count $pageCount >>\nendobj\n'));

    for (int i = 0; i < pageCount; i++) {
      final imgFile = File(images[i].path);
      final imgRaw = await imgFile.readAsBytes();

      final pageObjIndex = 3 + i * 3;
      final contentObjIndex = pageObjIndex + 1;
      final imageObjIndex = pageObjIndex + 2;

      // Page Object (A4 size: 595 x 842 points)
      offsets.add(fullBytes.length);
      fullBytes.addAll(utf8.encode(
          '$pageObjIndex 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents $contentObjIndex 0 R /Resources << /XObject << /Im$i $imageObjIndex 0 R >> >> >>\nendobj\n'));

      // Content stream to draw image fit on A4
      final contentStream =
          'q\n595 0 0 842 0 0 cm\n/Im$i Do\nQ\n';
      offsets.add(fullBytes.length);
      fullBytes.addAll(utf8.encode(
          '$contentObjIndex 0 obj\n<< /Length ${contentStream.length} >>\nstream\n$contentStream\nendstream\nendobj\n'));

      // Image XObject (JPEG stream)
      offsets.add(fullBytes.length);
      final imgHeader =
          '$imageObjIndex 0 obj\n<< /Type /XObject /Subtype /Image /Width 595 /Height 842 /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /DCTDecode /Length ${imgRaw.length} >>\nstream\n';
      fullBytes.addAll(utf8.encode(imgHeader));
      fullBytes.addAll(imgRaw);
      fullBytes.addAll(utf8.encode('\nendstream\nendobj\n'));
    }

    // xref table
    final xrefOffset = fullBytes.length;
    final totalObjects = 2 + pageCount * 3 + 1;
    fullBytes.addAll(utf8.encode('xref\n0 $totalObjects\n0000000000 65535 f \n'));
    for (final offset in offsets) {
      final formattedOffset = offset.toString().padLeft(10, '0');
      fullBytes.addAll(utf8.encode('$formattedOffset 00000 n \n'));
    }

    // Trailer
    fullBytes.addAll(utf8.encode(
        'trailer\n<< /Size $totalObjects /Root 1 0 R >>\nstartxref\n$xrefOffset\n%%EOF\n'));

    return fullBytes;
  }

  void _showToast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.outfit()),
        backgroundColor: const Color(0xFF334155),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Media Suite',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Compress • Audio Extract • PDF Maker',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white60,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF10B981),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle:
              GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(
                icon: Icon(Icons.video_file_rounded, size: 18),
                text: 'Video Compress'),
            Tab(
                icon: Icon(Icons.audiotrack_rounded, size: 18),
                text: 'Extract Audio'),
            Tab(
                icon: Icon(Icons.picture_as_pdf_rounded, size: 18),
                text: 'Image to PDF'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCompressorTab(),
          _buildAudioExtractorTab(),
          _buildPdfMakerTab(),
        ],
      ),
    );
  }

  // TAB 1: VIDEO COMPRESSOR
  Widget _buildCompressorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF064E3B), Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.compress_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WhatsApp & Social Video Shrinker',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Compress 50MB-100MB videos to <16MB for instant WhatsApp sharing without losing visual quality.',
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Pick Video Button
          GestureDetector(
            onTap: _pickVideoForCompression,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF131D2D),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _pickedVideo != null
                      ? const Color(0xFF10B981)
                      : Colors.white12,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _pickedVideo != null
                        ? Icons.check_circle_rounded
                        : Icons.cloud_upload_rounded,
                    color: _pickedVideo != null
                        ? const Color(0xFF10B981)
                        : Colors.white70,
                    size: 42,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _pickedVideo != null
                        ? 'Video Selected: ${_formatBytes(_originalSizeBytes ?? 0)}'
                        : 'Tap to Choose Video from Gallery',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _pickedVideo != null
                        ? _pickedVideo!.path.split('/').last
                        : 'Supports MP4, MOV, MKV',
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_pickedVideo != null) ...[
            const SizedBox(height: 20),

            // Quality Selection
            Text(
              'CHOOSE TARGET QUALITY',
              style: GoogleFonts.inter(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                _buildQualityChip('WhatsApp (<16MB)', VideoQuality.LowQuality),
                const SizedBox(width: 8),
                _buildQualityChip('Balanced 720p', VideoQuality.MediumQuality),
                const SizedBox(width: 8),
                _buildQualityChip('High 1080p', VideoQuality.DefaultQuality),
              ],
            ),

            const SizedBox(height: 20),

            // Compress Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isCompressing ? null : _compressVideo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.auto_fix_high_rounded, size: 20),
                label: Text(
                  _isCompressing
                      ? 'Compressing (${(_compressProgress * 100).toInt()}%)...'
                      : 'Compress Video Now',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            if (_isCompressing) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: _compressProgress > 0 ? _compressProgress : null,
                  minHeight: 8,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF10B981)),
                ),
              ),
            ],
          ],

          // Compressed Result Card
          if (_compressedInfo != null && _compressedInfo!.file != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF131D2D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.task_alt_rounded,
                            color: Color(0xFF10B981), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Compression Complete!',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatBox(
                        'Original Size',
                        _formatBytes(_originalSizeBytes ?? 0),
                        Colors.white60,
                      ),
                      const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white38),
                      _buildStatBox(
                        'Compressed Size',
                        _formatBytes(_compressedInfo!.filesize ?? 0),
                        const Color(0xFF10B981),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Actions: Save to Gallery & Share to WhatsApp
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Gal.putVideo(_compressedInfo!.file!.path);
                            _showToast('Saved to Camera Roll Gallery!');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.save_alt_rounded, size: 18),
                          label: Text('Save Gallery',
                              style: GoogleFonts.outfit(fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            SharePlus.instance.share(ShareParams(
                              files: [XFile(_compressedInfo!.file!.path)],
                              text: 'Here is the compressed video!',
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.share_rounded, size: 18),
                          label: Text('Share Now',
                              style: GoogleFonts.outfit(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQualityChip(String label, VideoQuality quality) {
    final isSelected = _selectedQuality == quality;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedQuality = quality);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF10B981).withValues(alpha: 0.2)
                : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF10B981)
                  : Colors.transparent,
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 2),
          Text(val,
              style: GoogleFonts.outfit(
                  color: color, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // TAB 2: AUDIO EXTRACTOR
  Widget _buildAudioExtractorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF581C87), Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFA855F7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.music_note_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Video to MP3 / Audio Extractor',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Extract clear audio songs, voiceovers, or podcasts directly from your phone videos.',
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Pick Video
          GestureDetector(
            onTap: _pickVideoForAudio,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF131D2D),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _audioSourceVideo != null
                      ? const Color(0xFFA855F7)
                      : Colors.white12,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.audio_file_rounded,
                      color: Color(0xFFA855F7), size: 44),
                  const SizedBox(height: 10),
                  Text(
                    _audioSourceVideo != null
                        ? 'Selected: ${_audioSourceVideo!.path.split("/").last}'
                        : 'Choose Video to Extract Audio',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Extracts crisp audio in seconds',
                    style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          if (_isExtractingAudio) ...[
            const SizedBox(height: 20),
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFA855F7)),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text('Extracting audio track...',
                  style: GoogleFonts.inter(color: Colors.white70)),
            ),
          ],

          if (_extractedAudioFile != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF131D2D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFA855F7).withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFFA855F7)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Audio Extracted Successfully!',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _extractedAudioFile!.path.split('/').last,
                    style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        SharePlus.instance.share(ShareParams(
                          files: [XFile(_extractedAudioFile!.path)],
                          text: 'Here is the extracted audio file!',
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA855F7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.share_rounded, size: 20),
                      label: Text(
                        'Share / Save Audio File',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // TAB 3: IMAGE TO PDF MAKER
  Widget _buildPdfMakerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF991B1B), Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Image to Multi-Page PDF',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Select photos, notes, or bills and compile them into a professional PDF document.',
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Add Images Action Card
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickImagesForPdf,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Colors.white12),
                    ),
                  ),
                  icon: const Icon(Icons.add_photo_alternate_rounded,
                      color: Color(0xFFEF4444)),
                  label: Text('Add Photos / Notes',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ),
              if (_selectedPdfImages.isNotEmpty) ...[
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent),
                  onPressed: () {
                    setState(() {
                      _selectedPdfImages.clear();
                      _generatedPdfFile = null;
                    });
                  },
                ),
              ],
            ],
          ),

          if (_selectedPdfImages.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'PAGES (${_selectedPdfImages.length})',
              style: GoogleFonts.inter(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),

            // Thumbnail strip
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedPdfImages.length,
                itemBuilder: (context, i) {
                  return Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 120,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                          image: DecorationImage(
                            image: FileImage(File(_selectedPdfImages[i].path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#${i + 1}',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 14,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedPdfImages.removeAt(i));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Generate PDF Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGeneratingPdf ? null : _generatePdfDocument,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
                label: Text(
                  _isGeneratingPdf
                      ? 'Generating PDF Document...'
                      : 'Create & Export PDF (${_selectedPdfImages.length} Pages)',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],

          if (_generatedPdfFile != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF131D2D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFFEF4444)),
                      const SizedBox(width: 10),
                      Text(
                        'PDF Created Successfully!',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'File: ${_generatedPdfFile!.path.split("/").last}',
                    style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        SharePlus.instance.share(ShareParams(
                          files: [XFile(_generatedPdfFile!.path)],
                          text: 'Here is your PDF document!',
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: Text('Share / Save PDF',
                          style: GoogleFonts.outfit(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
