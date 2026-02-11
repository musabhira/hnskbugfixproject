// Automatic FlutterFlow imports
import 'package:pocket_mates_app/custom_code/widgets/choice_chip_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/choice_chip_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/custom_text_field.dart';
import 'package:pocket_mates_app/custom_code/widgets/custom_text_field.dart';
import 'package:pocket_mates_app/flutter_flow/flutter_flow_widgets.dart';
import 'package:pocket_mates_app/flutter_flow/flutter_flow_widgets.dart';

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


class CreateServiceWidget extends StatefulWidget {
  final double width;
  final double height;
  const CreateServiceWidget(
      {super.key, required this.width, required this.height});

  @override
  State<CreateServiceWidget> createState() => _CreateServiceWidgetState();
}

class _CreateServiceWidgetState extends State<CreateServiceWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  String? _currentUserId;
  final _supabase = SupaFlow.client;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _titleController.addListener(_updateState);
    _descriptionController.addListener(_updateState);
    _priceController.addListener(_updateState);
  }

  void _updateState() {
    safeSetState(() {});
  }

  Future<void> _getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      safeSetState(() {
        _currentUserId = user.id;
      });
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateState);
    _descriptionController.removeListener(_updateState);
    _priceController.removeListener(_updateState);
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    if (_titleController.text.trim().isEmpty) return false;
    if (_descriptionController.text.trim().isEmpty) return false;
    if (_priceController.text.trim().isEmpty) return false;
    if (selectedCategory == null || selectedCategory!.isEmpty) return false;
    return true;
  }

  Future<void> _saveProfile() async {
    if (!_isFormValid()) return;

    try {
      safeSetState(() => _isLoading = true);

      // Ensure the user is authenticated
      _currentUserId = _supabase.auth.currentUser!.id;

      if (_currentUserId == null) {
        throw Exception("User not authenticated");
      }
      if (_containsObjectionableContent(_titleController.text.trim())) {
        _showContentFilterSnackbar('title');
        return; // Exit early if objectionable content found
      }

      // Content filtering for description
      if (_containsObjectionableContent(_descriptionController.text.trim())) {
        _showContentFilterSnackbar('description');
        return; // Exit early if objectionable content found
      }

      // Insert the service record
      await _supabase.from('service').insert({
        'user_id': _currentUserId,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'category': selectedCategory,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }

      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $error')),
        );
      }
      print('Error updating profile: $error');
    } finally {
      safeSetState(() => _isLoading = false);
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
    for (String word in objectionableWords) {
      if (lowerText.contains(word)) {
        return true;
      }
    }

    return false;
  }

  String? selectedCategory;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

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
                      FlutterFlowTheme.of(context).primary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    'Add Your Service',
                    style: FlutterFlowTheme.of(context).headlineMedium.override(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.0,
                      ),
                    ),
                    child: FlutterFlowIconButton(
                      borderColor: Colors.transparent,
                      borderRadius: 12.0,
                      borderWidth: 0.0,
                      buttonSize: 40.0,
                      fillColor: Colors.transparent,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      onPressed: () async {
                        context.safePop();
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Main Content
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Details Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20.0,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(
                            color: FlutterFlowTheme.of(context)
                                .alternate
                                .withValues(alpha: 0.5),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Icon(
                                    Icons.work_outline,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 18.0,
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  'Service Details',
                                  style: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .override(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.0,
                                        fontSize: 16,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                  // ignore: deprecated_member_use
                                  color: Colors.yellow
                                      .withValues(alpha: 0.2), // less opacity
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Please avoid using inappropriate words in your title , description.',
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

                            // Title Field
                            CustomTextField(
                              width: double.infinity,
                              height: double.infinity,
                              controller: _titleController,
                              hintText: 'Title',
                              labelText: 'Title',
                            ),
                            const SizedBox(height: 8.0),

                            // Description Field
                            CustomTextField(
                              width: double.infinity,
                              height: double.infinity,
                              controller: _descriptionController,
                              hintText: 'Description',
                              labelText: 'Description',
                              maxLines: 5,
                            ),
                            const SizedBox(height: 8.0),

                            // Price Field
                            CustomTextField(
                              width: double.infinity,
                              height: double.infinity,
                              controller: _priceController,
                              hintText: 'Price',
                              labelText: 'Price',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8.0),

                      // Category Selection Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20.0,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(
                            color: FlutterFlowTheme.of(context)
                                .alternate
                                .withValues(alpha: 0.5),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Icon(
                                    Icons.category_outlined,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 24.0,
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  'Category',
                                  style: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .override(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.0,
                                        fontSize: 16,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            CustomChoiceChips(
                              width: double.infinity,
                              height: double.infinity,
                              options: const [
                                'Drawing',
                                'Painting',
                                'Designer',
                                'Digital Art',
                                'Caricature',
                                'Developer',
                                'Calligraphy',
                                'Teaching',
                                'Copy Writing',
                                'Editing',
                                'Photography',
                                'Videography',
                                'App Developer',
                                'Web Developer',
                                'Logo Design',
                                'UI/UX Design',
                                'Illustration',
                                'Animation',
                                '3D Modeling',
                                'Motion Graphics',
                                'Music Production',
                                'Voice Over',
                                'Translation',
                                'Content Writing',
                                'Proofreading',
                                'Marketing',
                                'Social Media Management',
                                'SEO Optimization',
                                'Business Consulting',
                                'Tutoring',
                                'Video Editing',
                                'Interior Design',
                                'Event Planning',
                                'Craft Making',
                                'Handmade Products',
                                'Tailoring',
                                'Makeup Artist',
                                'Hair Styling',
                                'Fitness Training',
                                'Yoga Instructor',
                                'Cooking/Baking',
                                'Language Teaching',
                                'Script Writing',
                                'Data Entry',
                                'Virtual Assistant',
                                'Technical Support',
                                'IT Consulting',
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

                      const SizedBox(height: 40.0),

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
                                        .withValues(alpha: 0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: FlutterFlowTheme.of(context)
                                        .primary
                                        // ignore: deprecated_member_use
                                        .withValues(alpha: 0.3),
                                    blurRadius: 15.0,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: FFButtonWidget(
                                onPressed: (_isLoading || !_isFormValid())
                                    ? null
                                    : _saveProfile,
                                text: _isLoading ? 'Saving...' : 'Save',
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 56.0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0),
                                  iconPadding: EdgeInsets.zero,
                                  color: Colors.transparent,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        fontFamily: 'Poppins',
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.0,
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
}