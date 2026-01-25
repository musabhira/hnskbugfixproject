// Automatic FlutterFlow imports
import 'package:pocket_mates_app/custom_code/widgets/custom_text_field.dart';
import 'package:pocket_mates_app/custom_code/widgets/choice_chip_widget.dart';
import 'package:pocket_mates_app/flutter_flow/flutter_flow_widgets.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:io' as io;

class CreateGalleryWidget extends StatefulWidget {
  final double width;
  final double height;
  const CreateGalleryWidget(
      {super.key, required this.width, required this.height});

  @override
  State<CreateGalleryWidget> createState() => _CreateGalleryWidgetState();
}

class _CreateGalleryWidgetState extends State<CreateGalleryWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  String? _currentUserId;
  final _supabase = SupaFlow.client;
  Uint8List? _selectedImageBytesBanner;
  String? _imageUrlBanner;
  final ImagePicker _picker = ImagePicker();
  bool _isCompressingImage = false;

  String? selectedCategory;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  // Helper method to safely get TextStyle
  TextStyle safeTextStyle(TextStyle? baseStyle) {
    return baseStyle ?? const TextStyle();
  }

  Future<void> _getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      safeSetState(() {
        _currentUserId = user.id;
      });
    }
  }

  Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    try {
      // Decode the image
      img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception('Unable to decode image');
      }

      // Calculate new dimensions while maintaining aspect ratio
      int maxWidth = 1200;
      int maxHeight = 1200;

      int newWidth = originalImage.width;
      int newHeight = originalImage.height;

      if (originalImage.width > maxWidth || originalImage.height > maxHeight) {
        double aspectRatio = originalImage.width / originalImage.height;

        if (originalImage.width > originalImage.height) {
          newWidth = maxWidth;
          newHeight = (maxWidth / aspectRatio).round();
        } else {
          newHeight = maxHeight;
          newWidth = (maxHeight * aspectRatio).round();
        }
      }

      // Resize image if needed
      img.Image resizedImage;
      if (newWidth != originalImage.width ||
          newHeight != originalImage.height) {
        resizedImage = img.copyResize(
          originalImage,
          width: newWidth,
          height: newHeight,
          interpolation: img.Interpolation.linear, // Good quality interpolation
        );
      } else {
        resizedImage = originalImage;
      }

      // Encode with high quality JPEG (85-90 maintains good clarity)
      List<int> compressedBytes = img.encodeJpg(
        resizedImage,
        quality: 85, // Adjust between 80-95 for quality vs size balance
      );

      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      print('Error compressing image: $e');
      // Return original bytes if compression fails
      return imageBytes;
    }
  }

  Future<void> _selectImageBanner() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    try {
      // Show loading state
      safeSetState(() {
        _isCompressingImage = true;
      });

      Uint8List fileBytes;
      if (kIsWeb) {
        fileBytes = await pickedFile.readAsBytes();
      } else {
        final file = io.File(pickedFile.path);
        fileBytes = await file.readAsBytes();
      }

      // Compress the image before storing
      final compressedBytes = await _compressImage(fileBytes);

      safeSetState(() {
        _selectedImageBytesBanner = compressedBytes;
        _isCompressingImage = false;
      });
    } catch (e) {
      safeSetState(() {
        _isCompressingImage = false;
      });
      // Handle error if needed
      print('Error selecting/compressing image: $e');
    }
  }

  Future<void> _saveProfile() async {
    try {
      safeSetState(() => _isLoading = true);

      // Safe null check for current user
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception("User not authenticated. Please log in again.");
      }

      _currentUserId = currentUser.id;

      // Validate required fields
      if (_titleController.text.trim().isEmpty) {
        throw Exception("Please enter a title for your showcase");
      }

      if (_descriptionController.text.trim().isEmpty) {
        throw Exception("Please enter a description for your showcase");
      }

      if (selectedCategory == null || selectedCategory!.isEmpty) {
        throw Exception("Please select a category for your showcase");
      }

      // Content filtering for title
      if (_containsObjectionableContent(_titleController.text.trim())) {
        _showContentFilterSnackbar('title');
        return; // Exit early if objectionable content found
      }

      // Content filtering for description
      if (_containsObjectionableContent(_descriptionController.text.trim())) {
        _showContentFilterSnackbar('description');
        return; // Exit early if objectionable content found
      }

      // Handle image upload if selected
      if (_selectedImageBytesBanner != null) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_$_currentUserId.jpg';
        final storagePath = 'gallery_photos/$fileName';

        try {
          await _supabase.storage
              .from('gallery_photos')
              .uploadBinary(storagePath, _selectedImageBytesBanner!);

          final response = _supabase.storage
              .from('gallery_photos')
              .getPublicUrl(storagePath);
          _imageUrlBanner = response;

          _selectedImageBytesBanner = null;
        } catch (uploadError) {
          throw Exception("Failed to upload image: $uploadError");
        }
      }

      // Parse price safely
      double? price;
      if (_priceController.text.trim().isNotEmpty) {
        price = double.tryParse(_priceController.text.trim());
        if (price == null) {
          throw Exception("Please enter a valid price");
        }
      }

      // Insert into database
      await _supabase.from('gallery').insert({
        'user_id': _currentUserId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': price,
        'category': selectedCategory,
        'image_url': _imageUrlBanner,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'Showcase created successfully!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error creating showcase: $error',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        safeSetState(() => _isLoading = false);
      }
    }
  }

  void _showContentFilterSnackbar(String fieldName) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Content not allowed in $fieldName. Please use appropriate language.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

// Optional: Real-time content filtering as user types
// Add these methods if you want to show warnings while typing

  void _onTitleChanged(String value) {
    if (_containsObjectionableContent(value)) {
      // You can add visual feedback here if needed
      // For example, change border color or show a warning icon
    }
  }

  void _onDescriptionChanged(String value) {
    if (_containsObjectionableContent(value)) {
      // You can add visual feedback here if needed
      // For example, change border color or show a warning icon
    }
  }

  // Validation helper
  bool _isFormValid() {
    return _titleController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        selectedCategory != null &&
        selectedCategory!.isNotEmpty;
  }

  bool _containsObjectionableContent(String text) {
    // Convert to lowercase for case-insensitive checking
    String lowerText = text.toLowerCase();

    // List of objectionable words/phrases to filter
    List<String> objectionableWords = [
      // Profanity
      'fuck', 'shit', 'bitch', 'dick',
      'motherfucker', 'cock',

      // Hate speech / Discrimination
      'racist', 'terrorist', 'sexist',
      'violence',
      'murder',

      // Sexual content
      'nude', 'naked', 'porn', 'sex', 'xxx', 'boobs', 'penis',
      'orgasm', 'milf', 'blowjob',

      // Drugs & illegal content
      'drug',
      'weed',
      'cocaine',
      'scam',
      'fraud',

      // Add more words as needed
    ];

    // Check for objectionable words
    for (String word in objectionableWords) {
      if (lowerText.contains(word)) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: CustomScrollView(
          slivers: [
            // Modern App Bar with gradient
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      FlutterFlowTheme.of(context).primary,
                      FlutterFlowTheme.of(context).primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    'Add Your Gallery',
                    style: safeTextStyle(
                            FlutterFlowTheme.of(context).headlineMedium)
                        .copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.0,
                            fontSize: 16),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.0,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 16.0,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),

            // Main Content
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Upload Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(24.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20.0,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: FlutterFlowTheme.of(context)
                                    .alternate
                                    .withOpacity(0.3) ??
                                Colors.grey.withOpacity(0.3),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primary
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Icon(
                                      Icons.photo_library_outlined,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      size: 16.0,
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Showcase Image',
                                          style: safeTextStyle(
                                                  FlutterFlowTheme.of(context)
                                                      .headlineSmall)
                                              .copyWith(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.0,
                                                  fontSize: 16),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          'Add a beautiful image to showcase your work',
                                          style: safeTextStyle(
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium)
                                              .copyWith(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  letterSpacing: 0.0,
                                                  fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Image Display Area
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context)
                                          .alternate
                                          .withOpacity(0.5) ??
                                      Colors.grey.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 280.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18.0),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                    ),
                                    child: _isCompressingImage
                                        ? // Show loading during compression
                                        ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .alternate
                                                        .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  CircularProgressIndicator(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'Compressing Image...',
                                                    style: safeTextStyle(
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyLarge)
                                                        .copyWith(
                                                      color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText
                                                              .withOpacity(
                                                                  0.7) ??
                                                          Colors.grey
                                                              .withOpacity(0.7),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Please wait...',
                                                    style: safeTextStyle(
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall)
                                                        .copyWith(
                                                      color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText
                                                              .withOpacity(
                                                                  0.5) ??
                                                          Colors.grey
                                                              .withOpacity(0.5),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : _selectedImageBytesBanner != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                                child: Image.memory(
                                                  _selectedImageBytesBanner!,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                                child: Image.network(
                                                  _imageUrlBanner ??
                                                      'https://static.vecteezy.com/system/resources/previews/022/143/984/non_2x/1960s-hippie-vivid-colors-background-design-colorful-frizzy-template-for-psychedelic-60s-70s-parties-illustration-with-psychedelic-trippy-vibe-vector.jpg',
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                                    .of(context)
                                                                .alternate
                                                                .withOpacity(
                                                                    0.1) ??
                                                            Colors.grey
                                                                .withOpacity(
                                                                    0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(18.0),
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .image_outlined,
                                                            size: 64,
                                                            color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText
                                                                    .withOpacity(
                                                                        0.4) ??
                                                                Colors.grey
                                                                    .withOpacity(
                                                                        0.4),
                                                          ),
                                                          const SizedBox(
                                                              height: 16),
                                                          Text(
                                                            'No Image Selected',
                                                            style: safeTextStyle(
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyLarge)
                                                                .copyWith(
                                                              color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText
                                                                      .withOpacity(
                                                                          0.6) ??
                                                                  Colors.grey
                                                                      .withOpacity(
                                                                          0.6),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            'Tap to choose an image',
                                                            style: safeTextStyle(
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmall)
                                                                .copyWith(
                                                              color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText
                                                                      .withOpacity(
                                                                          0.5) ??
                                                                  Colors.grey
                                                                      .withOpacity(
                                                                          0.5),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                  )
                                  // Interactive Overlay
                                  ,
                                  Positioned.fill(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        onTap: _selectImageBanner,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                            color: Colors.black.withOpacity(
                                                _selectedImageBytesBanner !=
                                                        null
                                                    ? 0.0
                                                    : 0.02),
                                          ),
                                          child: _selectedImageBytesBanner !=
                                                  null
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18.0),
                                                    gradient: LinearGradient(
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                      colors: [
                                                        Colors.transparent,
                                                        Colors.black
                                                            .withOpacity(0.4),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20.0),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 20,
                                                                vertical: 12),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white
                                                              .withOpacity(0.9),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(25),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.1),
                                                              blurRadius: 10,
                                                              offset:
                                                                  const Offset(
                                                                      0, 2),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .edit_outlined,
                                                              size: 18,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primary,
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            Text(
                                                              'Change Image',
                                                              style: safeTextStyle(
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium)
                                                                  .copyWith(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20.0),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7.0, vertical: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color:
                                Colors.yellow.withOpacity(0.2), // less opacity
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Please avoid using inappropriate words in your title , Image , or description.',
                                  style: TextStyle(
                                    color: Colors.yellow[
                                        800], // slightly darker text for contrast
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8.0),

                      // Details Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20.0,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(
                            color: FlutterFlowTheme.of(context)
                                .alternate
                                .withOpacity(0.5),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Icon(
                                    Icons.info_outline,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 16.0,
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Text(
                                  'Showcase Details',
                                  style: safeTextStyle(
                                          FlutterFlowTheme.of(context)
                                              .headlineSmall)
                                      .copyWith(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.0,
                                          fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),

                            // Title Field
                            CustomTextField(
                              width: double.infinity,
                              height: double.infinity,
                              controller: _titleController,
                              hintText: 'Enter a catchy title',
                              labelText: 'Title',
                            ),
                            const SizedBox(height: 8.0),

                            // Description Field
                            CustomTextField(
                              width: double.infinity,
                              height: double.infinity,
                              controller: _descriptionController,
                              hintText: 'Describe your showcase',
                              labelText: 'Description',
                              maxLines: 6,
                            ),
                            const SizedBox(height: 8.0),

                            // Price Field (Optional)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Price',
                                      style: safeTextStyle(
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium)
                                          .copyWith(
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 2.0),
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                                .secondaryText
                                                // ignore: deprecated_member_use
                                                .withOpacity(0.1) ??
                                            Colors.grey.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: Text(
                                        'Optional',
                                        style: safeTextStyle(
                                                FlutterFlowTheme.of(context)
                                                    .bodySmall)
                                            .copyWith(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          fontSize: 11.0,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                CustomTextField(
                                  width: double.infinity,
                                  height: double.infinity,
                                  controller: _priceController,
                                  hintText: 'Set a price (e.g., 50)',
                                  labelText: 'Price',
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24.0),

                      // Category Selection Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20.0,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(
                            color: FlutterFlowTheme.of(context)
                                    .alternate
                                    .withOpacity(0.5) ??
                                Colors.grey.withOpacity(0.5),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Icon(
                                    Icons.category_outlined,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 16.0,
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Text(
                                  'Category',
                                  style: safeTextStyle(
                                          FlutterFlowTheme.of(context)
                                              .headlineSmall)
                                      .copyWith(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.0,
                                          fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            CustomChoiceChips(
                              width: double.infinity,
                              height: double.infinity,
                              options: const [
                                'All',
                                'team',
                                'Hand Skill',
                                'Art',
                                'writers',
                                'Models',
                                'photos',
                                'Artists',
                                'Drawing',
                                'Painting',
                                'Design',
                                'Digital Art',
                                'Mural Painting',
                                'Pen Art',
                                'Ink Art',
                                'Illustration',
                                'color pencil',
                                'Pencil Sketching',
                                'Charcoal Drawing',
                                'Animation',
                                'Acrylic Painting',
                                'Watercolor Art',
                                'Oil Painting',
                                'Wall Art',
                                'Canvas Art',
                                'Miniature Painting',
                                'Sculpture',
                                'Craft',
                                'Face Wash',
                                'Moisturizer',
                                'Serum',
                                'Face Cream	',
                                'Lip Balm',
                                'Primer',
                                'Sheet Mask',
                                'Eye Cream',
                                'Body Lotion',
                                'Night Cream',
                                'Toner',
                                'Calligraphy',
                                'Embroidery',
                                'Programming',
                                'Pottery',
                                'Resin Art',
                                'Glass Painting',
                                'Concept Art',
                                'Game Art',
                                'NFT Art',
                                '3D Modeling',
                                'Logo Design',
                                'Tattoo',
                                'mailanji design',
                                'Other',
                              ],
                              initialValue: selectedCategory,
                              onChanged: (value) {
                                safeSetState(() {
                                  selectedCategory = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24.0),

                      // Save Button
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(maxWidth: 300),
                              height: 56.0,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    FlutterFlowTheme.of(context).primary,
                                    FlutterFlowTheme.of(context)
                                        .primary
                                        // ignore: deprecated_member_use
                                        .withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: FlutterFlowTheme.of(context)
                                        .primary
                                        // ignore: deprecated_member_use
                                        .withOpacity(0.3),
                                    blurRadius: 15.0,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: FFButtonWidget(
                                onPressed: (_isLoading || !_isFormValid())
                                    ? null
                                    : _saveProfile,
                                text: _isLoading ? 'Creating...' : 'Save',
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 56.0,
                                  color: Colors.transparent,
                                  textStyle: safeTextStyle(
                                          FlutterFlowTheme.of(context)
                                              .titleMedium)
                                      .copyWith(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  elevation: 0.0,
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
