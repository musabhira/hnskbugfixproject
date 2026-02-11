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

import 'dart:io' as io;
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';

class EventCreatePage extends StatefulWidget {
  const EventCreatePage({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<EventCreatePage> createState() => _EventCreatePageState();
}

class _EventCreatePageState extends State<EventCreatePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  String? _currentUserId;
  XFile? _selectedImage;
  final _supabase = SupaFlow.client;
  Uint8List? _selectedImageBytes;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isCompressingImage = false;

  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _maxParticipantsController =
      TextEditingController(text: '100'); // Added controller with default value

  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.id;
      });
    }
  }

  Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    try {
      img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception('Unable to decode image');
      }

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

      img.Image resizedImage;
      if (newWidth != originalImage.width ||
          newHeight != originalImage.height) {
        resizedImage = img.copyResize(
          originalImage,
          width: newWidth,
          height: newHeight,
          interpolation: img.Interpolation.linear,
        );
      } else {
        resizedImage = originalImage;
      }

      List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 85);
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      print('Error compressing image: $e');
      return imageBytes;
    }
  }

  Future<void> _selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    try {
      setState(() {
        _isCompressingImage = true;
      });

      Uint8List fileBytes;
      if (kIsWeb) {
        fileBytes = await pickedFile.readAsBytes();
      } else {
        final file = io.File(pickedFile.path);
        fileBytes = await file.readAsBytes();
      }

      final compressedBytes = await _compressImage(fileBytes);

      setState(() {
        _selectedImageBytes = compressedBytes;
        _isCompressingImage = false;
      });
    } catch (e) {
      setState(() {
        _isCompressingImage = false;
      });
      print('Error selecting/compressing image: $e');
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.yellow,
              onPrimary: Colors.black,
              surface: Color(0xFF1a1a1a),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Colors.yellow,
                onPrimary: Colors.black,
                surface: Color(0xFF1a1a1a),
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _createEvent() async {
    try {
      setState(() => _isLoading = true);

      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception("User not authenticated. Please log in again.");
      }

      // Validate required fields
      if (_titleController.text.trim().isEmpty) {
        throw Exception("Please enter an event title");
      }

      if (_descriptionController.text.trim().isEmpty) {
        throw Exception("Please enter an event description");
      }

      if (_locationController.text.trim().isEmpty) {
        throw Exception("Please enter an event location");
      }

      if (_selectedDateTime == null) {
        throw Exception("Please select an event date and time");
      }

      if (_selectedDateTime!.isBefore(DateTime.now())) {
        throw Exception("Event date must be in the future");
      }

      // Validate max participants
      if (_maxParticipantsController.text.trim().isEmpty) {
        throw Exception("Please enter maximum number of participants");
      }

      int maxParticipants;
      try {
        maxParticipants = int.parse(_maxParticipantsController.text.trim());
        if (maxParticipants <= 0) {
          throw Exception("Maximum participants must be greater than 0");
        }
        if (maxParticipants > 10000) {
          throw Exception("Maximum participants cannot exceed 10,000");
        }
      } catch (e) {
        if (e.toString().contains("Maximum participants")) {
          rethrow;
        }
        throw Exception("Please enter a valid number for maximum participants");
      }

      // Handle image upload if selected
      String? imageUrl;
      if (_selectedImageBytes != null) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${currentUser.id}.jpg';
        final storagePath = 'event_images/$fileName';

        try {
          await _supabase.storage
              .from('event_images')
              .uploadBinary(storagePath, _selectedImageBytes!);

          imageUrl =
              _supabase.storage.from('event_images').getPublicUrl(storagePath);
        } catch (uploadError) {
          throw Exception("Failed to upload image: $uploadError");
        }
      }

      // Insert into database
      await _supabase.from('events').insert({
        'user_id': currentUser.id,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'event_date': _selectedDateTime!.toIso8601String(),
        'image_url': imageUrl,
        'max_participants': maxParticipants,
        'price': _priceController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text(
                  'Event created successfully!',
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );

        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error creating event: $error',
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _isFormValid() {
    return _titleController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _locationController.text.trim().isNotEmpty &&
        _maxParticipantsController.text
            .trim()
            .isNotEmpty && // Added max participants validation
        _selectedDateTime != null;
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>?
        inputFormatters, // Added input formatters parameter
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.yellow.withValues(alpha: 0.3)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters, // Added input formatters
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          labelStyle: TextStyle(color: Colors.yellow.shade600),
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(icon, color: Colors.yellow),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(20),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Create Event',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Upload Section
            Container(
              height: 200,
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a1a),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: Colors.yellow.withValues(alpha: 0.5), width: 2),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: _isCompressingImage
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.yellow),
                                SizedBox(height: 16),
                                Text(
                                  'Compressing Image...',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : _selectedImageBytes != null
                            ? Image.memory(
                                _selectedImageBytes!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.yellow.withValues(alpha: 0.1),
                                      Colors.orange.withValues(alpha: 0.1),
                                    ],
                                  ),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 50,
                                      color: Colors.yellow,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Add Event Image',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Tap to select an image',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: _selectImage,
                        child: _selectedImageBytes != null
                            ? Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.6),
                                    ],
                                  ),
                                ),
                                child: const Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.edit,
                                            color: Colors.yellow, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Change Image',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form Fields
            _buildCustomTextField(
              controller: _titleController,
              labelText: 'Event Title',
              hintText: 'Enter a catchy event title',
              icon: Icons.title,
            ),

            _buildCustomTextField(
              controller: _descriptionController,
              labelText: 'Description',
              hintText: 'Describe your event in detail',
              icon: Icons.description,
              maxLines: 4,
            ),

            _buildCustomTextField(
              controller: _locationController,
              labelText: 'Location',
              hintText: 'Where will the event take place?',
              icon: Icons.location_on,
            ),
            _buildCustomTextField(
              controller: _priceController,
              labelText: 'Event Entry Fee',
              hintText: 'Enter the entry fee for the event',
              icon: Icons.payments,
            ),

            // Max Participants Field - Added this new field
            _buildCustomTextField(
              controller: _maxParticipantsController,
              labelText: 'Maximum Participants',
              hintText: 'Enter maximum number of participants',
              icon: Icons.group,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(
                    5), // Limit to 5 digits (99999)
              ],
            ),

            // Date Time Picker
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF2a2a2a),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.yellow.withValues(alpha: 0.3)),
              ),
              child: ListTile(
                leading: const Icon(Icons.event, color: Colors.yellow),
                title: Text(
                  _selectedDateTime == null
                      ? 'Select Date & Time'
                      : DateFormat('MMM dd, yyyy - hh:mm a')
                          .format(_selectedDateTime!),
                  style: TextStyle(
                    color: _selectedDateTime == null
                        ? Colors.grey.shade500
                        : Colors.white,
                    fontSize: 16,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Colors.yellow, size: 16),
                onTap: _selectDateTime,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),

            const SizedBox(height: 30),

            // Create Button
            Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: _isFormValid() && !_isLoading
                    ? const LinearGradient(
                        colors: [Colors.yellow, Colors.orange],
                      )
                    : LinearGradient(
                        colors: [Colors.grey.shade600, Colors.grey.shade700],
                      ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: _isFormValid() && !_isLoading
                    ? [
                        BoxShadow(
                          color: Colors.yellow.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: (_isLoading || !_isFormValid()) ? null : _createEvent,
                  child: Center(
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 16),
                              Text(
                                'Creating Event...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            'Create Event',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose(); // Added dispose for new controller
    super.dispose();
  }
}