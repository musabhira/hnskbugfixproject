// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
import 'dart:io';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart' show kIsWeb;

class AiPromptGenerator extends StatelessWidget {
  const AiPromptGenerator({
    super.key,
    this.width,
    this.height,
  });
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 30),
              _buildQuickStats(),
              SizedBox(height: 30),
              Text(
                'AI Features',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildFeatureCard(
                      context,
                      'AI Studio',
                      'Complete AI Generator',
                      Icons.auto_awesome,
                      Colors.purple,
                      EnhancedAIGenerator(),
                    ),
                    _buildFeatureCard(
                      context,
                      'Quick Text',
                      'Simple Text Generation',
                      Icons.text_fields,
                      Colors.blue,
                      SimpleTextGenerator(),
                    ),
                    _buildFeatureCard(
                      context,
                      'Image Gen',
                      'Quick Image Creation',
                      Icons.image,
                      Colors.green,
                      QuickImageGenerator(),
                    ),
                    _buildFeatureCard(
                      context,
                      'Vision AI',
                      'Image Analysis',
                      Icons.visibility,
                      Colors.orange,
                      VisionAIExample(),
                    ),
                    _buildFeatureCard(
                      context,
                      'AI Chat',
                      'Conversation AI',
                      Icons.chat,
                      Colors.pink,
                      ChatWithAI(),
                    ),
                    _buildFeatureCard(
                      context,
                      'Batch Gen',
                      'Multiple Images',
                      Icons.burst_mode,
                      Colors.teal,
                      null,
                      onTap: () => _showBatchGenerationDialog(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.yellow.withValues(alpha: 0.8),
            Colors.orange.withValues(alpha: 0.6)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.smart_toy, color: Colors.black, size: 32),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Studio',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Multi-Modal AI Platform',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final analytics = AIAnalytics.getAnalytics();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
              'Total\nGenerations', analytics['totalGenerations'].toString()),
          _buildStatItem('Success\nRate', '${analytics['successRate']}%'),
          _buildStatItem(
              'Text\nGenerations', analytics['textGenerations'].toString()),
          _buildStatItem(
              'Image\nGenerations', analytics['imageGenerations'].toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.yellow,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    final Widget? route, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ??
          (route != null
              ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => route!, // here route is a Widget
                    ),
                  )
              : null),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBatchGenerationDialog(BuildContext context) {
    final TextEditingController promptController = TextEditingController();
    int imageCount = 4;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Batch Image Generation',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: promptController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your prompt...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Images: ', style: TextStyle(color: Colors.white)),
                  Expanded(
                    child: Slider(
                      value: imageCount.toDouble(),
                      min: 1,
                      max: AdminConfig.maxImageGeneration.toDouble(),
                      divisions: AdminConfig.maxImageGeneration - 1,
                      activeColor: Colors.yellow,
                      onChanged: (value) {
                        setState(() {
                          imageCount = value.toInt();
                        });
                      },
                    ),
                  ),
                  Text('$imageCount', style: TextStyle(color: Colors.white)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (promptController.text.trim().isNotEmpty) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BatchImageGenerator(
                        prompt: promptController.text.trim(),
                        imageCount: imageCount,
                      ),
                    ),
                  );
                }
              },
              child: Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom AI Service wrapper for easy app-wide usage
class AppAIService {
  static final AIService _service = AIService();
  static final AIServiceWithRetry _serviceWithRetry =
      AIServiceWithRetry(maxRetries: 3);

  // Quick access methods
  static Future<String?> quickText(String prompt) async {
    final response = await _service.generateText(prompt: prompt);
    return response.isSuccess ? response.data : null;
  }

  static Future<String?> quickImage(String prompt) async {
    final response = await _service.generateImage(prompt: prompt);
    return response.isSuccess ? response.data : null;
  }

  static Future<List<String>> quickBatchImages(String prompt, int count) async {
    final responses =
        await _service.generateMultipleImages(prompt: prompt, count: count);
    return responses.where((r) => r.isSuccess).map((r) => r.data!).toList();
  }

  static Future<String?> analyzeImageSafe(XFile imageFile,
      {String? question}) async {
    try {
      final response = await _service.imageToText(
        imageFile: imageFile,
        additionalPrompt: question ?? "Describe this image in detail.",
      );
      return response.isSuccess ? response.data : response.error;
    } catch (e) {
      print('Error analyzing image: $e');
      return null;
    }
  }

  // Retry versions for critical operations
  static Future<String?> reliableText(String prompt) async {
    final response =
        await _serviceWithRetry.generateTextWithRetry(prompt: prompt);
    return response.isSuccess ? response.data : null;
  }

  static Future<List<String>> reliableBatchImages(
      String prompt, int count) async {
    final responses = await _serviceWithRetry.generateImagesWithFallback(
        prompt: prompt, count: count);
    return responses.where((r) => r.isSuccess).map((r) => r.data!).toList();
  }
}

// Global configuration
class AppConfig {
  static const String appName = 'AI Studio';
  static const String version = '1.0.0';
  static const bool debugMode = true;

  // AI Configuration
  static const int defaultMaxTokens = 1000;
  static const double defaultTemperature = 0.7;
  static const String defaultImageSize = '1024x1024';
  static const int maxRetries = 3;
  static const Duration requestTimeout = Duration(seconds: 30);

  // UI Configuration
  static const Color primaryColor = Colors.yellow;
  static const Color backgroundColor = Colors.black;
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color textColor = Colors.white;
  static const Color hintColor = Color(0xFF9E9E9E);
}

class SimpleTextGenerator extends StatefulWidget {
  @override
  _SimpleTextGeneratorState createState() => _SimpleTextGeneratorState();
}

class _SimpleTextGeneratorState extends State<SimpleTextGenerator> {
  final AIService _aiService = AIService();
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  bool _loading = false;

  Future<void> _generateText() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _loading = true);

    final response = await _aiService.generateText(
      prompt: _controller.text.trim(),
      maxTokens: 500,
      temperature: 0.7,
    );

    setState(() {
      _loading = false;
      _result = response.isSuccess ? response.data! : response.error!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quick AI Text')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter your prompt...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _generateText,
              child: _loading ? CircularProgressIndicator() : Text('Generate'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_result),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example 2: Image Generation with Progress
class QuickImageGenerator extends StatefulWidget {
  @override
  _QuickImageGeneratorState createState() => _QuickImageGeneratorState();
}

class _QuickImageGeneratorState extends State<QuickImageGenerator> {
  final AIService _aiService = AIService();
  final TextEditingController _controller = TextEditingController();
  String? _imageUrl;
  bool _loading = false;
  double _progress = 0.0;

  Future<void> _generateImage() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _loading = true;
      _imageUrl = null;
      _progress = 0.0;
    });

    final response = await _aiService.generateImage(
      prompt: _controller.text.trim(),
      size: '512x512',
      onProgress: (progress) {
        setState(() => _progress = progress);
      },
    );

    setState(() {
      _loading = false;
      _imageUrl = response.isSuccess ? response.data : null;
      _progress = 0.0;
    });

    if (!response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.error!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quick AI Image')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Describe the image...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _generateImage,
              child: Text(_loading ? 'Generating...' : 'Generate Image'),
            ),
            if (_loading) ...[
              SizedBox(height: 16),
              LinearProgressIndicator(value: _progress),
              Text('${(_progress * 100).toInt()}%'),
            ],
            SizedBox(height: 16),
            Expanded(
              child: _imageUrl != null
                  ? Column(
                      children: [
                        Expanded(
                          child: Image.network(_imageUrl!, fit: BoxFit.contain),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _aiService.saveImageToGallery(_imageUrl!),
                          icon: Icon(Icons.download),
                          label: Text('Save to Gallery'),
                        ),
                      ],
                    )
                  : Center(child: Text('No image generated yet')),
            ),
          ],
        ),
      ),
    );
  }
}

// Example 3: Batch Image Generation
class BatchImageGenerator extends StatefulWidget {
  final String prompt;
  final int imageCount;

  const BatchImageGenerator({
    required this.prompt,
    this.imageCount = 4,
  });

  @override
  _BatchImageGeneratorState createState() => _BatchImageGeneratorState();
}

class _BatchImageGeneratorState extends State<BatchImageGenerator> {
  final AIService _aiService = AIService();
  List<String> _images = [];
  bool _loading = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _generateImages();
  }

  Future<void> _generateImages() async {
    setState(() {
      _loading = true;
      _progress = 0.0;
    });

    final results = await _aiService.generateMultipleImages(
      prompt: widget.prompt,
      count: widget.imageCount,
      onProgress: (progress) {
        setState(() => _progress = progress);
      },
    );

    setState(() {
      _loading = false;
      _images = results
          .where((result) => result.isSuccess)
          .map((result) => result.data!)
          .toList();
      _progress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Batch Generation'),
        actions: [
          IconButton(
            onPressed: _generateImages,
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating ${widget.imageCount} images...'),
                  SizedBox(height: 8),
                  LinearProgressIndicator(value: _progress),
                  Text('${(_progress * 100).toInt()}%'),
                ],
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        onPressed: () =>
                            _aiService.saveImageToGallery(_images[index]),
                        icon: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.download,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

// Example 4: Vision AI with Camera
class VisionAIExample extends StatefulWidget {
  @override
  _VisionAIExampleState createState() => _VisionAIExampleState();
}

class _VisionAIExampleState extends State<VisionAIExample> {
  final AIService _aiService = AIService();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String _analysis = '';
  bool _loading = false;
  double _progress = 0.0;

  Future<void> _pickAndAnalyzeImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageFile = image;
          _loading = true;
          _analysis = '';
          _progress = 0.0;
        });

        final response = await _aiService.imageToText(
          imageFile: image,
          additionalPrompt:
              "Analyze this image and describe what you see in detail. Include objects, people, colors, setting, and any notable features.",
          onProgress: (progress) {
            setState(() {
              _progress = progress;
            });
          },
        );

        setState(() {
          _loading = false;
          _analysis = response.isSuccess ? response.data! : response.error!;
          _progress = 0.0;
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _analysis = 'Error picking image: $e';
        _progress = 0.0;
      });
    }
  }

  Widget _buildImageWidget() {
    if (_imageFile == null) return SizedBox.shrink();

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: kIsWeb
            ? Image.network(
                _imageFile!.path,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 48),
                          SizedBox(height: 8),
                          Text('Failed to load image'),
                        ],
                      ),
                    ),
                  );
                },
              )
            : Image.file(
                File(_imageFile!.path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 48),
                          SizedBox(height: 8),
                          Text('Failed to load image'),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _loading
                ? null
                : () => _pickAndAnalyzeImage(ImageSource.camera),
            icon: Icon(Icons.camera_alt),
            label: Text('Camera'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _loading
                ? null
                : () => _pickAndAnalyzeImage(ImageSource.gallery),
            icon: Icon(Icons.photo_library),
            label: Text('Gallery'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Column(
      children: [
        CircularProgressIndicator(
          value: _progress > 0 ? _progress : null,
          strokeWidth: 3,
        ),
        SizedBox(height: 16),
        Text(
          'Analyzing image...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        if (_progress > 0) ...[
          SizedBox(height: 8),
          Text(
            '${(_progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAnalysisWidget() {
    if (_analysis.isEmpty) return SizedBox.shrink();

    final isError = _analysis.startsWith('Error') ||
        _analysis.startsWith('Failed') ||
        _analysis.contains('failed');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isError
              ? Colors.red.withValues(alpha: 0.05)
              : Colors.blue.withValues(alpha: 0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isError ? Icons.error_outline : Icons.visibility,
                  color: isError ? Colors.red : Colors.blue,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  isError ? 'Analysis Error' : 'Image Analysis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isError ? Colors.red : Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            SelectableText(
              _analysis,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Vision AI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instructions
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Take a photo or select an image from gallery to get AI-powered analysis.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(),
              SizedBox(height: 24),

              // Image Display
              _buildImageWidget(),
              if (_imageFile != null) SizedBox(height: 24),

              // Loading or Analysis
              if (_loading) ...[
                Center(child: _buildLoadingWidget()),
              ] else ...[
                _buildAnalysisWidget(),
              ],

              // API Key Warning
              if (AIService.OPENROUTER_API_KEY == 'YOUR_API_KEY_HERE') ...[
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Please replace YOUR_API_KEY_HERE with your actual OpenRouter API key.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Example 5: AI Service as a Mixin for easy integration
mixin AIServiceMixin<T extends StatefulWidget> on State<T> {
  final AIService aiService = AIService();
  bool isAILoading = false;
  double aiProgress = 0.0;

  Future<String?> quickTextGeneration(String prompt) async {
    setState(() => isAILoading = true);

    final response = await aiService.generateText(
      prompt: prompt,
      onProgress: (progress) {
        setState(() => aiProgress = progress);
      },
    );

    setState(() => isAILoading = false);

    if (response.isSuccess) {
      return response.data;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.error!)),
      );
      return null;
    }
  }

  Future<String?> quickImageGeneration(String prompt) async {
    setState(() => isAILoading = true);

    final response = await aiService.generateImage(
      prompt: prompt,
      onProgress: (progress) {
        setState(() => aiProgress = progress);
      },
    );

    setState(() => isAILoading = false);

    if (response.isSuccess) {
      return response.data;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.error!)),
      );
      return null;
    }
  }

  Widget buildAILoadingIndicator() {
    if (!isAILoading) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 8),
          LinearProgressIndicator(value: aiProgress),
          SizedBox(height: 4),
          Text('${(aiProgress * 100).toInt()}%'),
        ],
      ),
    );
  }
}

// Example 6: Using AI Service Mixin in a custom widget
class ChatWithAI extends StatefulWidget {
  @override
  _ChatWithAIState createState() => _ChatWithAIState();
}

class _ChatWithAIState extends State<ChatWithAI> with AIServiceMixin {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();
    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
    });
    _controller.clear();

    // Generate AI response
    final aiResponse = await quickTextGeneration(userMessage);
    if (aiResponse != null) {
      setState(() {
        _messages.add(ChatMessage(text: aiResponse, isUser: false));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(message: message);
              },
            ),
          ),
          buildAILoadingIndicator(),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: isAILoading ? null : _sendMessage,
                  child: Icon(Icons.send),
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.smart_toy, color: Colors.white),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}

// Example 7: Pubspec.yaml dependencies needed
/*
dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.5
  image_picker: ^0.8.6
  image_gallery_saver: ^1.7.1
  permission_handler: ^10.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
*/

// Example 8: How to initialize and configure the AI Service
class AIAppInitializer {
  static Future<void> initialize() async {
    // Configure admin settings
    AdminConfig.maxImageGeneration = 4;
    AdminConfig.adminPassword = "your_secure_password";

    // Enable/disable features as needed
    AdminConfig.enabledFeatures['textGeneration'] = true;
    AdminConfig.enabledFeatures['imageGeneration'] = true;
    AdminConfig.enabledFeatures['multipleImages'] = true;
    AdminConfig.enabledFeatures['visionAI'] = true;
    AdminConfig.enabledFeatures['imageToImage'] = true;
    AdminConfig.enabledFeatures['downloadImages'] = true;

    // Add custom prompts for quick access
    AdminConfig.customPrompts.addAll([
      "Create a professional logo design",
      "Write a creative story about",
      "Generate a social media post for",
      "Design a user interface mockup",
    ]);
  }
}

// Example 9: Error handling and retry mechanism
class AIServiceWithRetry {
  final AIService _aiService = AIService();
  final int maxRetries;

  AIServiceWithRetry({this.maxRetries = 3});

  Future<AIResponse> generateTextWithRetry({
    required String prompt,
    int maxTokens = 1000,
    double temperature = 0.7,
  }) async {
    AIResponse? lastResponse;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        lastResponse = await _aiService.generateText(
          prompt: prompt,
          maxTokens: maxTokens,
          temperature: temperature,
        );

        if (lastResponse.isSuccess) {
          return lastResponse;
        }

        // Wait before retry
        await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
      } catch (e) {
        print('Attempt ${attempt + 1} failed: $e');
        if (attempt == maxRetries - 1) {
          return AIResponse.error('All retry attempts failed: $e');
        }
      }
    }

    return lastResponse ?? AIResponse.error('No response received');
  }

  Future<List<AIResponse>> generateImagesWithFallback({
    required String prompt,
    int count = 1,
    String size = '1024x1024',
  }) async {
    List<AIResponse> results = [];

    for (int i = 0; i < count; i++) {
      for (int attempt = 0; attempt < maxRetries; attempt++) {
        try {
          final response = await _aiService.generateImage(
            prompt: "$prompt, variation ${i + 1}",
            size: size,
          );

          if (response.isSuccess) {
            results.add(response);
            break;
          }

          if (attempt == maxRetries - 1) {
            results.add(AIResponse.error('Failed after $maxRetries attempts'));
          }

          await Future.delayed(Duration(seconds: 1));
        } catch (e) {
          if (attempt == maxRetries - 1) {
            results.add(AIResponse.error('Exception: $e'));
          }
        }
      }
    }

    return results;
  }
}

// Example 10: Performance monitoring and analytics
class AIAnalytics {
  static int textGenerationCount = 0;
  static int imageGenerationCount = 0;
  static int successfulGenerations = 0;
  static int failedGenerations = 0;
  static Map<String, int> modelUsageCount = {};
  static Map<String, double> averageResponseTime = {};

  static void logTextGeneration(
      bool success, String model, Duration responseTime) {
    textGenerationCount++;
    if (success)
      successfulGenerations++;
    else
      failedGenerations++;
    modelUsageCount[model] = (modelUsageCount[model] ?? 0) + 1;

    final currentAvg = averageResponseTime[model] ?? 0.0;
    averageResponseTime[model] = (currentAvg + responseTime.inMilliseconds) / 2;
  }

  static void logImageGeneration(
      bool success, String model, Duration responseTime) {
    imageGenerationCount++;
    if (success)
      successfulGenerations++;
    else
      failedGenerations++;
    modelUsageCount[model] = (modelUsageCount[model] ?? 0) + 1;

    final currentAvg = averageResponseTime[model] ?? 0.0;
    averageResponseTime[model] = (currentAvg + responseTime.inMilliseconds) / 2;
  }

  static Map<String, dynamic> getAnalytics() {
    return {
      'totalGenerations': textGenerationCount + imageGenerationCount,
      'textGenerations': textGenerationCount,
      'imageGenerations': imageGenerationCount,
      'successRate': (successfulGenerations /
              (successfulGenerations + failedGenerations) *
              100)
          .toStringAsFixed(2),
      'modelUsage': modelUsageCount,
      'averageResponseTimes': averageResponseTime,
    };
  }
}

typedef AICallback = void Function(String result);
typedef AIErrorCallback = void Function(String error);
typedef AIProgressCallback = void Function(double progress);

class AIService {
  // OpenRouter API Configuration
  static const String OPENROUTER_API_KEY =
      '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';

  static const String OPENROUTER_BASE_URL = 'https://openrouter.ai/api/v1';

  // Free Text Models (Priority Order)
  static const List<String> FREE_TEXT_MODELS = [
    'google/gemini-2.0-flash-exp:free',
    'google/gemini-flash-1.5:free',
    'meta-llama/llama-3.2-3b-instruct:free',
    'meta-llama/llama-3.2-1b-instruct:free',
    'microsoft/phi-3-mini-128k-instruct:free',
    'huggingfaceh4/zephyr-7b-beta:free',
    'openchat/openchat-7b:free',
    'deepseek/deepseek-v3:free',
    'mistralai/devstral-small:free',
    'google/gemini-2.5-flash:free',
    'google/gemma-3n-e2b-it:free',
    'mistralai/mistral-7b-instruct:free',
    'meta-llama/llama-3-8b-instruct:free',
  ];

  // Free Image Models (Priority Order)
  static const List<String> FREE_IMAGE_MODELS = [
    'black-forest-labs/flux-1-schnell:free',
    'google/gemini-2.5-flash-image-preview:free',
    'stabilityai/stable-diffusion-3-5-large:free',
    'black-forest-labs/flux-1.1-pro:free',
  ];

  // Alternative Free APIs
  static const List<String> FREE_IMAGE_APIS = [
    'pollinations', // Completely free
    'picsum', // Random images (fallback)
    'unsplash', // High quality photos (fallback)
  ];

  // Singleton pattern
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // Callback types

  // Generate Text with multiple fallbacks
  Future<AIResponse> generateText({
    required String prompt,
    int maxTokens = 1000,
    double temperature = 0.7,
    AIProgressCallback? onProgress,
  }) async {
    onProgress?.call(0.1);

    for (int i = 0; i < FREE_TEXT_MODELS.length; i++) {
      try {
        final model = FREE_TEXT_MODELS[i];
        print('Trying text model: $model');
        onProgress?.call(0.1 + (i * 0.8 / FREE_TEXT_MODELS.length));

        final result = await _generateTextWithModel(
          model: model,
          prompt: prompt,
          maxTokens: maxTokens,
          temperature: temperature,
        );

        if (result.isSuccess) {
          onProgress?.call(1.0);
          return result;
        }
      } catch (e) {
        print('Model ${FREE_TEXT_MODELS[i]} failed: $e');
        continue;
      }
    }

    onProgress?.call(1.0);
    return AIResponse.error('All text generation models failed');
  }

  // Generate Image with multiple fallbacks
  Future<AIResponse> generateImage({
    required String prompt,
    String size = '1024x1024',
    AIProgressCallback? onProgress,
  }) async {
    onProgress?.call(0.1);

    // Try OpenRouter models first
    for (int i = 0; i < FREE_IMAGE_MODELS.length; i++) {
      try {
        final model = FREE_IMAGE_MODELS[i];
        print('Trying image model: $model');
        onProgress?.call(0.1 + (i * 0.4 / FREE_IMAGE_MODELS.length));

        final result = await _generateImageWithModel(
          model: model,
          prompt: prompt,
          size: size,
        );

        if (result.isSuccess) {
          onProgress?.call(1.0);
          return result;
        }
      } catch (e) {
        print('Model ${FREE_IMAGE_MODELS[i]} failed: $e');
        continue;
      }
    }

    // Try alternative free APIs
    onProgress?.call(0.5);
    for (int i = 0; i < FREE_IMAGE_APIS.length; i++) {
      try {
        final api = FREE_IMAGE_APIS[i];
        print('Trying alternative API: $api');
        onProgress?.call(0.5 + (i * 0.4 / FREE_IMAGE_APIS.length));

        final result = await _generateImageWithAlternativeAPI(api, prompt);
        if (result.isSuccess) {
          onProgress?.call(1.0);
          return result;
        }
      } catch (e) {
        print('Alternative API  failed: $e');
        continue;
      }
    }

    onProgress?.call(1.0);
    return AIResponse.error('All image generation services failed');
  }

  // Generate Multiple Images (Batch)
  Future<List<AIResponse>> generateMultipleImages({
    required String prompt,
    int count = 4,
    String size = '1024x1024',
    AIProgressCallback? onProgress,
  }) async {
    List<AIResponse> results = [];

    for (int i = 0; i < count; i++) {
      onProgress?.call(i / count);

      // Add some variation to prompts
      String variedPrompt = prompt;
      if (i > 0) {
        variedPrompt += ', variation ${i + 1}';
      }

      final result = await generateImage(
        prompt: variedPrompt,
        size: size,
      );

      results.add(result);

      // Small delay to avoid rate limits
      if (i < count - 1) {
        await Future.delayed(Duration(milliseconds: 500));
      }
    }

    onProgress?.call(1.0);
    return results;
  }

  // Vision: Image to Text
  Future<AIResponse> imageToText({
    required XFile imageFile, // Change from String path to XFile
    String? additionalPrompt,
    AIProgressCallback? onProgress,
  }) async {
    onProgress?.call(0.1);

    try {
      // Get image bytes in a platform-compatible way
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      onProgress?.call(0.3);

      // Rest of your code remains the same...
      final visionModels = [
        'google/gemini-2.0-flash-exp:free',
        'google/gemini-flash-1.5:free',
      ];

      for (final model in visionModels) {
        try {
          onProgress?.call(0.5);

          final response = await http.post(
            Uri.parse('$OPENROUTER_BASE_URL/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $OPENROUTER_API_KEY',
              'HTTP-Referer': 'https://flutter-ai-app.com',
              'X-Title': 'AI Vision App',
            },
            body: jsonEncode({
              'model': model,
              'messages': [
                {
                  'role': 'user',
                  'content': [
                    {
                      'type': 'text',
                      'text':
                          additionalPrompt ?? 'Describe this image in detail.'
                    },
                    {
                      'type': 'image_url',
                      'image_url': {
                        'url': 'data:image/jpeg;base64,$base64Image'
                      }
                    }
                  ]
                }
              ],
              'max_tokens': 1000,
            }),
          );

          onProgress?.call(0.8);

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['choices'] != null && data['choices'].isNotEmpty) {
              onProgress?.call(1.0);
              return AIResponse.success(
                  data['choices'][0]['message']['content']);
            }
          }
        } catch (e) {
          print('Vision model $model failed: $e');
          continue;
        }
      }

      onProgress?.call(1.0);
      return AIResponse.error('All vision models failed');
    } catch (e) {
      onProgress?.call(1.0);
      return AIResponse.error('Failed to process image: $e');
    }
  }

  // Image + Text to Image (Style Transfer/Modification)
  Future<AIResponse> imageToImage({
    required XFile imageFile,
    required String prompt,
    String size = '1024x1024',
    AIProgressCallback? onProgress,
  }) async {
    onProgress?.call(0.1);

    try {
      // Get image bytes in a platform-compatible way
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      onProgress?.call(0.3);

      // Try image-to-image models
      final response = await http.post(
        Uri.parse('$OPENROUTER_BASE_URL/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $OPENROUTER_API_KEY',
          'HTTP-Referer': 'https://flutter-ai-app.com',
          'X-Title': 'AI Image App',
        },
        body: jsonEncode({
          'model': 'black-forest-labs/flux-1-schnell:free',
          'prompt': prompt,
          'image': 'data:image/jpeg;base64,$base64Image',
          'n': 1,
          'size': size,
        }),
      );

      onProgress?.call(0.8);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          onProgress?.call(1.0);
          return AIResponse.success(data['data'][0]['url']);
        }
      }

      // Fallback: Generate new image based on description + prompt
      final descriptionResult = await imageToText(imageFile: imageFile);
      if (descriptionResult.isSuccess) {
        final combinedPrompt = '${descriptionResult.data}, $prompt';
        return await generateImage(
            prompt: combinedPrompt, size: size, onProgress: onProgress);
      }

      onProgress?.call(1.0);
      return AIResponse.error('Image-to-image generation failed');
    } catch (e) {
      onProgress?.call(1.0);
      return AIResponse.error('Failed to process image-to-image: $e');
    }
  }

  // Save Image to Gallery

  // Private helper methods
  Future<AIResponse> _generateTextWithModel({
    required String model,
    required String prompt,
    int maxTokens = 1000,
    double temperature = 0.7,
  }) async {
    final response = await http.post(
      Uri.parse('$OPENROUTER_BASE_URL/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $OPENROUTER_API_KEY',
        'HTTP-Referer': 'https://flutter-ai-app.com',
        'X-Title': 'AI Text Generator',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': maxTokens,
        'temperature': temperature,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['choices'] != null && data['choices'].isNotEmpty) {
        return AIResponse.success(data['choices'][0]['message']['content']);
      }
    }

    return AIResponse.error('Model $model failed: ${response.statusCode}');
  }

  Future<AIResponse> _generateImageWithModel({
    required String model,
    required String prompt,
    String size = '1024x1024',
  }) async {
    final response = await http.post(
      Uri.parse('$OPENROUTER_BASE_URL/images/generations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $OPENROUTER_API_KEY',
        'HTTP-Referer': 'https://flutter-ai-app.com',
        'X-Title': 'AI Image Generator',
      },
      body: jsonEncode({
        'model': model,
        'prompt': prompt,
        'n': 1,
        'size': size,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['data'] != null && data['data'].isNotEmpty) {
        return AIResponse.success(data['data'][0]['url']);
      }
    }

    return AIResponse.error('Model $model failed: ${response.statusCode}');
  }

  Future<AIResponse> _generateImageWithAlternativeAPI(
      String api, String prompt) async {
    switch (api) {
      case 'pollinations':
        return await _generateWithPollinations(prompt);
      case 'picsum':
        return await _generateWithPicsum();
      case 'unsplash':
        return await _generateWithUnsplash(prompt);
      default:
        return AIResponse.error('Unknown API: $api');
    }
  }

  Future<AIResponse> _generateWithPollinations(String prompt) async {
    try {
      final encodedPrompt = Uri.encodeComponent(prompt);
      final imageUrl =
          'https://image.pollinations.ai/prompt/$encodedPrompt?width=1024&height=1024&nologo=true&enhance=true';

      // Test the URL
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200 &&
          response.headers['content-type']?.contains('image') == true) {
        final base64Image = base64Encode(response.bodyBytes);
        return AIResponse.success('data:image/jpeg;base64,$base64Image');
      }
      return AIResponse.error('Pollinations API failed');
    } catch (e) {
      return AIResponse.error('Pollinations error: $e');
    }
  }

  Future<AIResponse> _generateWithPicsum() async {
    try {
      final seed = DateTime.now().millisecondsSinceEpoch;
      final imageUrl = 'https://picsum.photos/seed/$seed/1024/1024';
      return AIResponse.success(imageUrl);
    } catch (e) {
      return AIResponse.error('Picsum error: $e');
    }
  }

  Future<AIResponse> _generateWithUnsplash(String prompt) async {
    try {
      final query = Uri.encodeComponent(prompt);
      final imageUrl = 'https://source.unsplash.com/1024x1024/?$query';
      return AIResponse.success(imageUrl);
    } catch (e) {
      return AIResponse.error('Unsplash error: $e');
    }
  }

  Future<bool> saveImageToGallery(String imageUrl, {String? fileName}) async {
    try {
      // Request storage permission
      // final permission = await Permission.storage.request();
      // if (!permission.isGranted) {
      //   return false;
      // }

      // // Download image
      // final response = await http.get(Uri.parse(imageUrl));
      // if (response.statusCode == 200) {
      //   final result = await ImageGallerySaver.saveImage(
      //     Uint8List.fromList(response.bodyBytes),
      //     quality: 100,
      //     name: fileName ?? "ai_generated_${DateTime.now().millisecondsSinceEpoch}",
      //   );
      //   return result['isSuccess'] ?? false;
      // }
      return false;
    } catch (e) {
      print('Failed to save image: $e');
      return false;
    }
  }
}

// Response wrapper class
class AIResponse {
  final bool isSuccess;
  final String? data;
  final String? error;

  AIResponse._({required this.isSuccess, this.data, this.error});

  factory AIResponse.success(String data) =>
      AIResponse._(isSuccess: true, data: data);
  factory AIResponse.error(String error) =>
      AIResponse._(isSuccess: false, error: error);
}

// Admin Panel Model
class AdminConfig {
  static bool showAdminPanel = false;
  static String adminPassword = "admin123";
  static int maxImageGeneration = 4;
  static List<String> customPrompts = [
    "A beautiful landscape",
    "Abstract art",
    "Futuristic city",
    "Fantasy creature",
  ];

  static Map<String, bool> enabledFeatures = {
    'textGeneration': true,
    'imageGeneration': true,
    'multipleImages': true,
    'visionAI': true,
    'imageToImage': true,
    'downloadImages': true,
  };
}

class EnhancedAIGenerator extends StatefulWidget {
  @override
  _EnhancedAIGeneratorState createState() => _EnhancedAIGeneratorState();
}

class _EnhancedAIGeneratorState extends State<EnhancedAIGenerator>
    with TickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _adminPasswordController =
      TextEditingController();
  final AIService _aiService = AIService();
  final ImagePicker _imagePicker = ImagePicker();

  // State variables
  String _generatedText = '';
  List<String> _generatedImages = [];
  bool _isLoadingText = false;
  bool _isLoadingImages = false;
  double _progress = 0.0;

  // Mode selection
  int _selectedMode =
      0; // 0: Text, 1: Image, 2: Multiple Images, 3: Vision, 4: Image-to-Image
  XFile? _selectedImage;

  // Admin panel
  bool _showAdminPanel = false;
  bool _isAdminAuthenticated = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    _scaleController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _scaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_scaleController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildMainUI(),
          if (_showAdminPanel) _buildAdminPanel(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleAdminPanel,
        backgroundColor: Colors.yellow,
        child: Icon(Icons.admin_panel_settings, color: Colors.black),
      ),
    );
  }

  Widget _buildMainUI() {
    return Column(
      children: [
        _buildHeader(),
        _buildModeSelector(),
        _buildInputSection(),
        Expanded(child: _buildOutputSection()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.yellow, Colors.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.auto_awesome, color: Colors.black, size: 28),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Studio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Multi-Modal AI Generator',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    final modes = [
      {'title': 'Text', 'icon': Icons.text_fields, 'color': Colors.blue},
      {'title': 'Image', 'icon': Icons.image, 'color': Colors.green},
      {
        'title': 'Multi-Image',
        'icon': Icons.burst_mode,
        'color': Colors.purple
      },
      {'title': 'Vision', 'icon': Icons.visibility, 'color': Colors.orange},
      {
        'title': 'Style Transfer',
        'icon': Icons.transform,
        'color': Colors.pink
      },
    ];

    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: modes.length,
        itemBuilder: (context, index) {
          final mode = modes[index];
          final isSelected = _selectedMode == index;

          return GestureDetector(
            onTap: () => setState(() => _selectedMode = index),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.all(16),
              width: 100,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          mode['color'] as Color,
                          (mode['color'] as Color).withValues(alpha: 0.7)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey[800]!,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    mode['icon'] as IconData,
                    color: isSelected ? Colors.white : Colors.grey[400],
                    size: 28,
                  ),
                  SizedBox(height: 8),
                  Text(
                    mode['title'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[400],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        children: [
          if (_selectedMode >= 3) _buildImageSelector(),
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _promptController,
              style: TextStyle(color: Colors.white, fontSize: 16),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: _getHintText(),
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: InputBorder.none,
                prefixIcon: Icon(
                  _getModeIcon(),
                  color: Colors.yellow,
                ),
              ),
            ),
          ),
          if (_progress > 0 && (_isLoadingText || _isLoadingImages))
            Container(
              margin: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
              ),
            ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ElevatedButton.icon(
              onPressed: (_isLoadingText || _isLoadingImages)
                  ? null
                  : _generateContent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: (_isLoadingText || _isLoadingImages)
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Icon(_getModeIcon()),
              label: Text(
                (_isLoadingText || _isLoadingImages)
                    ? 'Generating...'
                    : 'Generate ${_getModeTitle()}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _pickImage(ImageSource.gallery);
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb
                          ? Image.network(_selectedImage!.path,
                              fit: BoxFit.cover) // For web
                          : Image.file(File(_selectedImage!.path),
                              fit: BoxFit.cover), // For mobile
                    )
                  : Icon(Icons.add_photo_alternate,
                      color: Colors.grey[500], size: 32),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedImage != null ? 'Image Selected' : 'Select Image',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
                Text(
                  _selectedImage != null
                      ? 'Tap to change image'
                      : 'Required for Vision & Style Transfer',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(_getModeIcon(), color: Colors.yellow),
                SizedBox(width: 8),
                Text(
                  'Generated ${_getModeTitle()}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                if (_hasOutput())
                  IconButton(
                    onPressed: _clearOutput,
                    icon: Icon(Icons.clear, color: Colors.grey[400]),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _buildOutputContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputContent() {
    if (_selectedMode == 0) {
      // Text output
      if (_isLoadingText) {
        return _buildLoadingWidget('Generating text...');
      } else if (_generatedText.isEmpty) {
        return _buildEmptyWidget(
            Icons.text_fields, 'Generated text will appear here');
      } else {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: SelectableText(
            _generatedText,
            style: TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
          ),
        );
      }
    } else {
      // Image output
      if (_isLoadingImages) {
        return _buildLoadingWidget('Generating images...');
      } else if (_generatedImages.isEmpty) {
        return _buildEmptyWidget(
            Icons.image, 'Generated images will appear here');
      } else {
        return _buildImageGrid();
      }
    }
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _generatedImages.length == 1 ? 1 : 2,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _generatedImages.length,
      itemBuilder: (context, index) {
        return _buildImageCard(_generatedImages[index], index);
      },
    );
  }

  Widget _buildImageCard(String imageUrl, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            _buildImageWidget(imageUrl),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _downloadImage(imageUrl, index),
                      icon: Icon(Icons.download, color: Colors.white, size: 20),
                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    IconButton(
                      onPressed: () => _shareImage(imageUrl),
                      icon: Icon(Icons.share, color: Colors.white, size: 20),
                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      // Base64 encoded image
      final base64Data = imageUrl.split(',')[1];
      final bytes = base64.decode(base64Data);
      return Image.memory(bytes,
          fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    } else {
      // Network image
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: Colors.yellow,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[800],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 32),
                  SizedBox(height: 8),
                  Text('Failed to load',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildLoadingWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.yellow),
          SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[400])),
          if (_progress > 0) ...[
            SizedBox(height: 16),
            Container(
              width: 200,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
              ),
            ),
            SizedBox(height: 8),
            Text('${(_progress * 100).toInt()}%',
                style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey[600], size: 48),
          SizedBox(height: 16),
          Text(message,
              style: TextStyle(color: Colors.grey[400], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildAdminPanel() {
    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      child: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.yellow.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.yellow),
                  SizedBox(width: 8),
                  Text('Admin Panel',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Spacer(),
                  IconButton(
                    onPressed: () => setState(() => _showAdminPanel = false),
                    icon: Icon(Icons.close, color: Colors.grey[400]),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (!_isAdminAuthenticated) ...[
                TextField(
                  controller: _adminPasswordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter admin password',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[700]!)),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _authenticateAdmin,
                  child: Text('Login'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black),
                ),
              ] else ...[
                _buildAdminControls(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminControls() {
    return Column(
      children: [
        Text('Max Images per Generation',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Slider(
          value: AdminConfig.maxImageGeneration.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: Colors.yellow,
          onChanged: (value) {
            setState(() {
              AdminConfig.maxImageGeneration = value.toInt();
            });
          },
        ),
        Text('${AdminConfig.maxImageGeneration} images',
            style: TextStyle(color: Colors.grey[400])),
        SizedBox(height: 20),
        Text('Features',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ...AdminConfig.enabledFeatures.entries.map((entry) {
          return CheckboxListTile(
            title: Text(entry.key, style: TextStyle(color: Colors.white)),
            value: entry.value,
            activeColor: Colors.yellow,
            onChanged: (value) {
              setState(() {
                AdminConfig.enabledFeatures[entry.key] = value!;
              });
            },
          );
        }).toList(),
      ],
    );
  }

  // Helper methods
  String _getHintText() {
    switch (_selectedMode) {
      case 0:
        return 'Enter your text prompt here...';
      case 1:
        return 'Describe the image you want to generate...';
      case 2:
        return 'Describe images for batch generation...';
      case 3:
        return 'Ask about the selected image...';
      case 4:
        return 'How do you want to transform the image?...';
      default:
        return 'Enter your prompt...';
    }
  }

  IconData _getModeIcon() {
    switch (_selectedMode) {
      case 0:
        return Icons.text_fields;
      case 1:
        return Icons.image;
      case 2:
        return Icons.burst_mode;
      case 3:
        return Icons.visibility;
      case 4:
        return Icons.transform;
      default:
        return Icons.auto_awesome;
    }
  }

  String _getModeTitle() {
    switch (_selectedMode) {
      case 0:
        return 'Text';
      case 1:
        return 'Image';
      case 2:
        return 'Images';
      case 3:
        return 'Analysis';
      case 4:
        return 'Style Transfer';
      default:
        return 'Content';
    }
  }

  bool _hasOutput() {
    return _generatedText.isNotEmpty || _generatedImages.isNotEmpty;
  }

  // Action methods
  void _toggleAdminPanel() {
    setState(() {
      _showAdminPanel = !_showAdminPanel;
    });
  }

  void _authenticateAdmin() {
    if (_adminPasswordController.text == AdminConfig.adminPassword) {
      setState(() {
        _isAdminAuthenticated = true;
      });
      _showSnackBar('Admin access granted');
    } else {
      _showSnackBar('Invalid password');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _imagePicker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = image; // Store XFile, not File
      });
    }
  }

  Future<void> _generateContent() async {
    if (_promptController.text.trim().isEmpty) {
      _showSnackBar('Please enter a prompt');
      return;
    }

    // Check if image is required for certain modes
    if ((_selectedMode == 3 || _selectedMode == 4) && _selectedImage == null) {
      _showSnackBar('Please select an image first');
      return;
    }

    switch (_selectedMode) {
      case 0:
        await _generateText();
        break;
      case 1:
        await _generateSingleImage();
        break;
      case 2:
        await _generateMultipleImages();
        break;
      case 3:
        await _generateVisionAnalysis();
        break;
      case 4:
        await _generateStyleTransfer();
        break;
    }
  }

  Future<void> _generateText() async {
    setState(() {
      _isLoadingText = true;
      _generatedText = '';
      _progress = 0.0;
    });

    final result = await _aiService.generateText(
      prompt: _promptController.text.trim(),
      onProgress: (progress) {
        setState(() {
          _progress = progress;
        });
      },
    );

    setState(() {
      _isLoadingText = false;
      _progress = 0.0;
      _generatedText = result.isSuccess ? result.data! : result.error!;
    });

    if (result.isSuccess) {
      _showSnackBar('Text generated successfully!');
      _fadeController.forward();
    } else {
      _showSnackBar('Generation failed');
    }
  }

  Future<void> _generateSingleImage() async {
    setState(() {
      _isLoadingImages = true;
      _generatedImages.clear();
      _progress = 0.0;
    });

    final result = await _aiService.generateImage(
      prompt: _promptController.text.trim(),
      onProgress: (progress) {
        setState(() {
          _progress = progress;
        });
      },
    );

    setState(() {
      _isLoadingImages = false;
      _progress = 0.0;
      if (result.isSuccess) {
        _generatedImages = [result.data!];
      }
    });

    if (result.isSuccess) {
      _showSnackBar('Image generated successfully!');
      _scaleController.forward();
    } else {
      _showSnackBar('Image generation failed: ${result.error}');
    }
  }

  Future<void> _generateMultipleImages() async {
    setState(() {
      _isLoadingImages = true;
      _generatedImages.clear();
      _progress = 0.0;
    });

    final results = await _aiService.generateMultipleImages(
      prompt: _promptController.text.trim(),
      count: AdminConfig.maxImageGeneration,
      onProgress: (progress) {
        setState(() {
          _progress = progress;
        });
      },
    );

    setState(() {
      _isLoadingImages = false;
      _progress = 0.0;
      _generatedImages = results
          .where((result) => result.isSuccess)
          .map((result) => result.data!)
          .toList();
    });

    if (_generatedImages.isNotEmpty) {
      _showSnackBar('Generated ${_generatedImages.length} images!');
      _scaleController.forward();
    } else {
      _showSnackBar('All image generations failed');
    }
  }

  Future<void> _generateVisionAnalysis() async {
    setState(() {
      _isLoadingText = true;
      _generatedText = '';
      _progress = 0.0;
    });

    final result = await _aiService.imageToText(
      imageFile: _selectedImage!, // Changed from imagePath to imageFile
      additionalPrompt: _promptController.text.trim(),
      onProgress: (progress) {
        setState(() {
          _progress = progress;
        });
      },
    );

    setState(() {
      _isLoadingText = false;
      _progress = 0.0;
      _generatedText = result.isSuccess ? result.data! : result.error!;
    });

    if (result.isSuccess) {
      _showSnackBar('Vision analysis complete!');
      _fadeController.forward();
    } else {
      _showSnackBar('Vision analysis failed');
    }
  }

  Future<void> _generateStyleTransfer() async {
    setState(() {
      _isLoadingImages = true;
      _generatedImages.clear();
      _progress = 0.0;
    });

    final result = await _aiService.imageToImage(
      imageFile: _selectedImage!, // Changed from imagePath to imageFile
      prompt: _promptController.text.trim(),
      onProgress: (progress) {
        setState(() {
          _progress = progress;
        });
      },
    );

    setState(() {
      _isLoadingImages = false;
      _progress = 0.0;
      if (result.isSuccess) {
        _generatedImages = [result.data!];
      }
    });

    if (result.isSuccess) {
      _showSnackBar('Style transfer complete!');
      _scaleController.forward();
    } else {
      _showSnackBar('Style transfer failed: ${result.error}');
    }
  }

// If you need to handle both XFile and File paths, here's a helper method:
  Future<void> _generateVisionAnalysisFromPath(String imagePath) async {
    setState(() {
      _isLoadingText = true;
      _generatedText = '';
      _progress = 0.0;
    });

    // Convert path to XFile
    final XFile imageFile = XFile(imagePath);

    final result = await _aiService.imageToText(
      imageFile: imageFile,
      additionalPrompt: _promptController.text.trim(),
      onProgress: (progress) {
        setState(() {
          _progress = progress;
        });
      },
    );

    setState(() {
      _isLoadingText = false;
      _progress = 0.0;
      _generatedText = result.isSuccess ? result.data! : result.error!;
    });

    if (result.isSuccess) {
      _showSnackBar('Vision analysis complete!');
      _fadeController.forward();
    } else {
      _showSnackBar('Vision analysis failed');
    }
  }

  Future<void> _generateStyleTransferFromPath(String imagePath) async {
    setState(() {
      _isLoadingImages = true;
      _generatedImages.clear();
      _progress = 0.0;
    });

    // Convert path to XFile
    final XFile imageFile = XFile(imagePath);

    final result = await _aiService.imageToImage(
      imageFile: imageFile,
      prompt: _promptController.text.trim(),
      onProgress: (progress) {
        setState(() {
          _progress = progress;
        });
      },
    );

    setState(() {
      _isLoadingImages = false;
      _progress = 0.0;
      if (result.isSuccess) {
        _generatedImages = [result.data!];
      }
    });

    if (result.isSuccess) {
      _showSnackBar('Style transfer complete!');
      _scaleController.forward();
    } else {
      _showSnackBar('Style transfer failed: ${result.error}');
    }
  }

  Future<void> _downloadImage(String imageUrl, int index) async {
    final success = await _aiService.saveImageToGallery(
      imageUrl,
      fileName: "ai_generated_${DateTime.now().millisecondsSinceEpoch}_$index",
    );

    if (success) {
      _showSnackBar('Image saved to gallery!');
    } else {
      _showSnackBar('Failed to save image');
    }
  }

  Future<void> _shareImage(String imageUrl) async {
    // Implement sharing functionality
    _showSnackBar('Share functionality would be implemented here');
  }

  void _clearOutput() {
    setState(() {
      _generatedText = '';
      _generatedImages.clear();
      _progress = 0.0;
    });
    _fadeController.reset();
    _scaleController.reset();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.yellow[700],
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    _adminPasswordController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
}