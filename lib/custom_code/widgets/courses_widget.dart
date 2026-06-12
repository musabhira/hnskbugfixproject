import 'dart:io';
import 'package:flutter/foundation.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!

import 'dart:math';
import 'dart:async';

import 'package:flutter/services.dart';
import '/flutter_flow/flutter_flow_video_layer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/services/iap_service.dart';
import '/services/coupon_service.dart';
import '/services/google_pay_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

final supabase = SupaFlow.client;

const String kDummyVideoUrl =
    'https://assets.mixkit.co/videos/preview/mixkit-set-of-paints-and-brushes-on-a-table-4833-large.mp4';

class CoursesWidget extends StatefulWidget {
  const CoursesWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<CoursesWidget> createState() => _CoursesWidgetState();
}

class _CoursesWidgetState extends State<CoursesWidget> {
  void safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  final supabase = SupaFlow.client;
  List<Map<String, dynamic>> courses = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadCourses();
    _initializeIAP();
  }

  Future<void> _initializeIAP() async {
    await IAPService().initialize();
  }

  void _navigateToCourseDetail(
      BuildContext context, Map<String, dynamic> course) async {
    try {
      final configRes = await supabase.from('app_tool_configs').select('*').eq('tool_name', 'elearning_unlocked').maybeSingle();
      final isUnlocked = configRes?['android_active'] == true;
      
      if (isUnlocked) {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailPage(courseData: course),
            ),
          );
        }
      } else {
        if (context.mounted) {
          _showComingSoonDialog(context);
        }
      }
    } catch (e) {
      // Fallback to coming soon if config check fails
      if (context.mounted) {
        _showComingSoonDialog(context);
      }
    }
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Color(0xFFFFFC00).withOpacity(0.25), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: Color(0xFFFFFC00).withOpacity(0.08),
                    blurRadius: 45,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFFFC00).withOpacity(0.15),
                          Colors.orange.shade400.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFFFFFC00).withOpacity(0.3), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Color(0xFFFFFC00),
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Coming Soon!',
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Handskill E-Learning Academy will be fully unlocked in the 2nd or 3rd build. Stay tuned for expert masterclasses, video tutorials, and interactive learning modules!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFFFC00),
                          Colors.orange.shade600,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFFFFC00).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Got It',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loadCourses() async {
    try {
      safeSetState(() {
        isLoading = true;
        error = null;
      });

      final response = await supabase.from('courses').select();

      if (mounted) {
        final allCourses = List<Map<String, dynamic>>.from(response);
        final uniqueCourses = <Map<String, dynamic>>[];

        for (final course in allCourses) {
          // Manual mapping to maintain UI compatibility with existing keys
          uniqueCourses.add({
            'course_id': course['id'],
            'course_title': course['title'],
            'course_thumbnail': course['thumbnail'],
            'course_language': course['language'],
            'course_price': course['price'],
            'course_retail_price': course['retail_price'],
            'course_description': course['description'],
          });
        }

        safeSetState(() {
          courses = uniqueCourses;
          isLoading = false;
        });

        // Extract all product IDs and fetch them
        final androidIds = allCourses
            .map((c) => c['product_id_android'] as String?)
            .where((id) => id != null && id.isNotEmpty)
            .cast<String>()
            .toList();
        final iosIds = allCourses
            .map((c) => c['product_id_ios'] as String?)
            .where((id) => id != null && id.isNotEmpty)
            .cast<String>()
            .toList();

        final productIds = Platform.isAndroid ? androidIds : iosIds;
        if (productIds.isNotEmpty) {
          await IAPService().fetchProducts(productIds);
        }
      }
    } catch (e) {
      if (!mounted) return;
      safeSetState(() {
        error = 'Error fetching courses: $e';
        isLoading = false;
      });
    }
  }

  void _showProposalDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final titleController = TextEditingController();
        final descriptionController = TextEditingController();
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Submit Course Proposal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Have a skill to share? Submit your course idea to the Handskill team. We will review and add it to our B2B platform.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Your Name / Creator Name',
                        labelStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFFFB700)), borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Course Title',
                        labelStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFFFB700)), borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Course Description / What will you teach?',
                        labelStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFFFB700)), borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB700),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isSubmitting ? null : () async {
                    if (nameController.text.trim().isEmpty || titleController.text.trim().isEmpty || descriptionController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                      return;
                    }

                    setState(() => isSubmitting = true);
                    try {
                      final userId = supabase.auth.currentUser?.id;
                      if (userId == null) throw Exception('Not authenticated');

                      await supabase.from('course_publish_requests').insert({
                        'user_id': userId,
                        'creator_name': nameController.text.trim(),
                        'course_title': titleController.text.trim(),
                        'course_description': descriptionController.text.trim(),
                      });

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proposal submitted successfully! We will review it shortly.')));
                      }
                    } catch (e) {
                      setState(() => isSubmitting = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  child: isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('Submit', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: const Text('Handskill Learn', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showProposalDialog,
        backgroundColor: const Color(0xFFFFB700),
        icon: const Icon(Icons.add_box_rounded, color: Colors.black),
        label: const Text('Teach with Us', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryBackground,
              theme.secondaryBackground,
            ],
          ),
        ),
        child: RefreshIndicator(
          color: theme.primary,
          onRefresh: loadCourses,
          child: isLoading
              ? _buildLoadingState(theme)
              : error != null
                  ? _buildErrorState(theme)
                  : _buildCoursesList(theme),
        ),
      ),
    );
  }

  Widget _buildLoadingState(FlutterFlowTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.primary,
            strokeWidth: 3,
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(
            'Curating best courses for you...',
            style: theme.labelMedium,
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildErrorState(FlutterFlowTheme theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.error),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: theme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error ?? 'Unknown error occurred',
              style: theme.labelMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: loadCourses,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Try Again',
                  style: theme.titleSmall.override(
                      fontFamily: theme.titleSmallFamily, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList(FlutterFlowTheme theme) {
    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories_outlined, size: 80, color: theme.accent1),
            const SizedBox(height: 16),
            Text('No courses available yet', style: theme.headlineSmall),
            const SizedBox(height: 8),
            Text('Check back later for new workshops!',
                style: theme.labelMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
      itemCount: courses.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildCourseCard(theme, course, index);
      },
    );
  }

  Widget _buildCourseCard(
      FlutterFlowTheme theme, Map<String, dynamic> course, int index) {
    final courseId = course['course_id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: InkWell(
        onTap: () => _navigateToCourseDetail(context, course),
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: theme.alternate.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Section: Image & Header Info
                Stack(
                  children: [
                    Hero(
                      tag: 'course-$courseId',
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: course['course_thumbnail'] ?? '',
                            width: double.infinity,
                            height: 240,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              height: 240,
                              color: theme.accent1.withValues(alpha: 0.2),
                              child: Icon(Icons.broken_image_outlined,
                                  color: theme.accent1, size: 48),
                            ),
                          ),
                          Container(
                            height: 240,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.4),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Premium Tag
                    if (course['course_price'] != null &&
                        (course['course_price'] as String) != '0')
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.primary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primary.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.workspace_premium,
                                  color: Colors.black, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'PREMIUM',
                                style: theme.bodySmall.override(
                                  fontFamily: theme.bodySmallFamily,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().shimmer(duration: 2.seconds),
                    // Glassmorphic Overlays
                    Positioned(
                      top: 16,
                      right: 16,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.3),
                            child: FavoriteButton(
                                courseId: courseId?.toString() ?? ''),
                          ),
                        ),
                      ),
                    ),
                    if (course['course_language'] != null)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              color: Colors.black.withValues(alpha: 0.4),
                              child: Row(
                                children: [
                                  Icon(Icons.language_rounded,
                                      color: theme.primary, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    course['course_language'].toString(),
                                    style: theme.bodySmall.override(
                                      fontFamily: theme.bodySmallFamily,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // Content Section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'HANDSKILL LEARN',
                                  style: theme.bodySmall.override(
                                    fontFamily: theme.bodySmallFamily,
                                    color: theme.primary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  course['course_title'] ??
                                      'Full Drawing Masterclass',
                                  style: theme.titleLarge.override(
                                    fontFamily: theme.titleLargeFamily,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star_rounded,
                                    color: theme.primary, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  '4.9',
                                  style: theme.bodyMedium.override(
                                    fontFamily: theme.bodyMediumFamily,
                                    color: theme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        course['course_description'] ??
                            'Master the art of sketching with this comprehensive guide.',
                        style: theme.labelLarge.override(
                          fontFamily: theme.labelLargeFamily,
                          color: theme.secondaryText,
                          lineHeight: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price',
                                style: theme.labelSmall,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'â‚¹${course['course_price'] ?? '0'}',
                                    style: theme.headlineSmall.override(
                                      fontFamily: theme.headlineSmallFamily,
                                      color: theme.primary,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  if (course['course_retail_price'] != null) ...[
                                    const SizedBox(width: 12),
                                    Text(
                                      'â‚¹${course['course_retail_price']}',
                                      style: theme.labelMedium.override(
                                        fontFamily: theme.labelMediumFamily,
                                        decoration: TextDecoration.lineThrough,
                                        color: theme.secondaryText
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.primary,
                                  theme.primary.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primary.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () =>
                                  _navigateToCourseDetail(context, course),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.black,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Enroll Now',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded,
                                      size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
     .fadeIn(duration: 400.ms, delay: (index * 100).ms)
     .slideY(begin: 0.1, end: 0);
  }
}

class FavoriteButton extends StatefulWidget {
  final String courseId;
  const FavoriteButton({super.key, required this.courseId});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  void safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  bool? isFavorite;
  final supabase = SupaFlow.client;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('favorite_courses')
          .select()
          .eq('user_id', userId)
          .eq('course_id', widget.courseId)
          .single();

      if (mounted) {
        safeSetState(() {
          isFavorite = response.isNotEmpty;
        });
      }
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to add favorites')),
          );
        }
        return;
      }

      safeSetState(() {
        // Optimistically update UI
        isFavorite = !(isFavorite ?? false);
      });

      if (isFavorite!) {
        await supabase
            .from('favorite_courses')
            .insert({'user_id': userId, 'course_id': widget.courseId});
      } else {
        await supabase
            .from('favorite_courses')
            .delete()
            .eq('user_id', userId)
            .eq('course_id', widget.courseId);
      }
    } catch (e) {
      // Revert state if operation failed
      safeSetState(() {
        isFavorite = !(isFavorite ?? false);
      });
      debugPrint('Error toggling favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFavorite ?? false ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ?? false ? Colors.red : Colors.white,
      ),
      onPressed: _toggleFavorite,
    );
  }
}

class CourseDetailPage extends StatefulWidget {
  final Map<String, dynamic> courseData;

  const CourseDetailPage({super.key, required this.courseData});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> with WidgetsBindingObserver {
  String? _lastTransactionId;
  bool _isCheckingPayment = false;
  void safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  List<Map<String, dynamic>> lessons = [];
  int currentLessonIndex = 0;
  String currentVideoUrl = '';
  bool isLoading = true;
  bool hasPaidAccess = false;
  Map<String, double> lessonProgress = {};
  List<Map<String, dynamic>> lessonMaterials = [];
  List<Map<String, dynamic>> lessonNotes = [];
  bool isContentLoading = false;
  String? name;
  int activeTab = 0;

  final supabase = SupaFlow.client;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCourseData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPaidAccess();
    });
  }

  Future<void> _initCourseData() async {
    await _fetchLessons();
    await _loadCourseProgress();
    if (lessons.isNotEmpty && currentVideoUrl.isEmpty) {
      _selectLesson(lessons[0], 0);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _lastTransactionId != null) {
      _verifyPaymentAutomated();
    }
  }

  Future<void> _verifyPaymentAutomated() async {
    if (_isCheckingPayment) return;
    
    setState(() {
      _isCheckingPayment = true;
    });

    // Show a sleek "Verifying your payment..." loading state
    _showVerificationOverlay();

    // In a real scenario with a gateway, this would poll for 10-20 seconds
    // Since this is direct PI, we check if the status changed (e.g. by a webhook or admin)
    // For the demo/feel, we poll for 5 seconds
    bool success = false;
    for (int i = 0; i < 5; i++) {
       await Future.delayed(const Duration(seconds: 2));
       success = await GooglePayService().checkPaymentStatus(_lastTransactionId!);
       if (success) break;
    }

    setState(() {
      _isCheckingPayment = false;
      _isCheckingPayment = false;
    });

    if (success) {
      // SUCCESS! Automated redirect to course
      _lastTransactionId = null;
      if (mounted) {
        Navigator.of(context).pop(); // Close overlay
        _checkPaidAccess(); // Refresh access status
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Confirmed! Enrollment Successful.'), backgroundColor: Colors.green),
        );
      }
    } else {
       // Still pending - allow manual verification or WhatsApp fallback
       if (mounted) {
         Navigator.of(context).pop(); // Close overlay
         _showManualVerificationOption();
       }
    }
  }

  void _showVerificationOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 24),
            const Text(
              'Verifying Payment...',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Please do not close the app.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showManualVerificationOption() {
     showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        title: const Text('Payment Pending', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Your payment is being processed. It will be activated automatically within a few minutes once confirmed by the bank.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
               Navigator.pop(context);
               _showWhatsAppPaymentSheet1(); // Re-open or offer WhatsApp
            },
            child: const Text('Enroll via WhatsApp'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadCourseProgress() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final progressData = await supabase
          .from('user_progress')
          .select('content_id, progress, last_accessed')
          .eq('user_id', userId);

      if (progressData.isNotEmpty) {
        final Map<String, double> progressMap = {};
        String? latestLessonId;
        DateTime? latestAccessTime;

        for (var item in progressData as List) {
          final String lessonId = item['content_id'].toString();
          final double progressVal = (item['progress'] as num).toDouble();
          progressMap[lessonId] = progressVal;

          if (item['last_accessed'] != null) {
            final accessed = DateTime.tryParse(item['last_accessed'].toString());
            if (accessed != null) {
              if (latestAccessTime == null || accessed.isAfter(latestAccessTime)) {
                latestAccessTime = accessed;
                latestLessonId = lessonId;
              }
            }
          }
        }
        safeSetState(() {
          lessonProgress = progressMap;
        });

        // Auto-select the last accessed lesson if available and valid in the current lessons list
        if (latestLessonId != null && lessons.isNotEmpty) {
          final index = lessons.indexWhere((l) => l['id'].toString() == latestLessonId);
          if (index != -1) {
            _selectLesson(lessons[index], index);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading progress: $e');
    }
  }

  Future<void> _updateProgress(String lessonId, double progress) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Only update if progress is significantly more than stored
    final currentStored = lessonProgress[lessonId] ?? 0.0;
    if (progress <= currentStored + 0.05 && progress < 1.0) return;

    try {
      await supabase.from('user_progress').upsert({
        'user_id': userId,
        'content_type': 'video',
        'content_id': lessonId,
        'progress': progress,
        'batch_id': null, // Explicitly null for regular courses as decided
        'last_accessed': DateTime.now().toIso8601String(),
        if (progress >= 0.95) 'completed_at': DateTime.now().toIso8601String(),
      });

      safeSetState(() {
        lessonProgress[lessonId] = progress;
      });
    } catch (e) {
      // Silently fail or log
    }
  }

  Future<void> _loadLessonResources(String lessonId) async {
    safeSetState(() {
      isContentLoading = true;
    });

    try {
      final materialsTask =
          supabase.from('materials').select().eq('lesson_id', lessonId);
      final notesTask =
          supabase.from('notes').select().eq('lesson_id', lessonId);

      final results = await Future.wait([materialsTask, notesTask]);

      safeSetState(() {
        lessonMaterials = List<Map<String, dynamic>>.from(results[0] as List);
        lessonNotes = List<Map<String, dynamic>>.from(results[1] as List);
        isContentLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading resources: $e');
      safeSetState(() {
        isContentLoading = false;
      });
    }
  }

  void _selectLesson(Map<String, dynamic> lesson, int index) {
    if (index > 0 && !hasPaidAccess) {
      _showWhatsAppPaymentSheet1();
      return;
    }

    safeSetState(() {
      currentLessonIndex = index;
      currentVideoUrl = lesson['video_url'] ?? kDummyVideoUrl;
    });

    _loadLessonResources(lesson['id'].toString());
  }

  Future<void> _checkPaidAccess() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final courseId = widget.courseData['course_id'];

      final response = await supabase
          .from('user_course_access')
          .select('has_paid')
          .eq('user_id', userId)
          .eq('course_id', courseId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          hasPaidAccess = response != null && response['has_paid'] == true;
        });
      }
      
      // Fetch profile name separately to avoid complex join issues if relation is missing
      final profileRes = await supabase
          .from('profile')
          .select('name')
          .eq('user_id', userId)
          .maybeSingle();
      
      if (profileRes != null && mounted) {
        setState(() => name = profileRes['name']?.toString());
      }
    } catch (e) {
      // debugPrint('Error checking paid access: $e');
    }
  }

  Future<void> _fetchLessons() async {
    try {
      safeSetState(() {
        isLoading = true;
      });

      final response = await supabase
          .from('lessons')
          .select()
          .eq('course_id', widget.courseData['course_id'])
          .order('created_at');

      List<Map<String, dynamic>> lessonsList = [];
      lessonsList =
          response.map((item) => Map<String, dynamic>.from(item)).toList();
    
      setState(() {
        lessons = lessonsList;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching lessons: $e');
      if (!mounted) return;
      safeSetState(() {
        isLoading = false;
      });
    }
  }

  void _showWhatsAppPaymentSheet1() {
    final userId = supabase.auth.currentUser?.id;
    final courseTitle = widget.courseData['course_title'] ?? 'Course';
    
    // Find matching IAP product if available
    final productId = Platform.isAndroid 
        ? widget.courseData['product_id_android'] 
        : widget.courseData['product_id_ios'];
    
    ProductDetails? iapProduct;
    for (var p in IAPService().products) {
      if (p.id == productId) {
        iapProduct = p;
        break;
      }
    }

    final TextEditingController couponController = TextEditingController();
    String? appliedCoupon;
    bool isApplyingCoupon = false;
    bool isCouponValid = false;
    String couponMessage = '';
    double discountValue = 0;
    String discountType = 'amount';

    Future<Map<String, dynamic>> validateCoupon(String couponCode) async {
      try {
        final result = await CouponService.validatePromoCode(couponCode);
        if (result != null) {
          return {
            'isValid': true,
            'message': result['discount_type'] == 'percentage' 
                ? 'Success! ${result['discount_amount']}% OFF' 
                : 'Success! ₹${result['discount_amount']} OFF',
            'discount_amount': result['discount_amount'],
            'discount_type': result['discount_type']
          };
        }

        // Fallback for sharing coupons
        final response = await supabase
            .from('user_coupons')
            .select('user_id, is_active')
            .eq('coupon_code', couponCode)
            .maybeSingle();

        if (response != null) {
          if (response['user_id'] == userId) {
            return {'isValid': false, 'message': 'You cannot use your own code'};
          }
          if (!(response['is_active'] ?? true)) {
            return {'isValid': false, 'message': 'Coupon is deactivated'};
          }
          return {
            'isValid': true, 
            'message': 'Coupon applied! ₹50 OFF',
            'discount_amount': 50,
            'discount_type': 'amount'
          };
        }
        return {'isValid': false, 'message': 'Invalid coupon code'};
      } catch (e) {
        return {'isValid': false, 'message': 'Error validating coupon'};
      }
    }


    Widget buildCouponSection(StateSetter safeSetState) {
      return Column(
        children: [
          Divider(color: Colors.yellow.shade600.withValues(alpha: 0.3), height: 32),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: couponController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isApplyingCoupon ? null : () async {
                  safeSetState(() => isApplyingCoupon = true);
                  final res = await validateCoupon(couponController.text);
                  safeSetState(() {
                    isCouponValid = res['isValid'];
                    couponMessage = res['message'];
                    if (isCouponValid) {
                      appliedCoupon = couponController.text;
                      discountValue = (res['discount_amount'] as num).toDouble();
                      discountType = res['discount_type'];
                    }
                    isApplyingCoupon = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isApplyingCoupon ? '...' : 'Apply', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (couponMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(couponMessage, style: TextStyle(color: isCouponValid ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
            ),
        ],
      );
    }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 24),
                    const Text('Unlock Premium Access', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 32),
                    _buildPremiumPerk(Icons.hd_rounded, 'Full HD Video Lessons'),
                    _buildPremiumPerk(Icons.picture_as_pdf_rounded, 'Exclusive Study Materials'),
                    _buildPremiumPerk(Icons.support_agent_rounded, 'Direct Mentor Support'),
                    const SizedBox(height: 24),
                    buildCouponSection(setState),
                    const SizedBox(height: 32),
                    
                    if (iapProduct != null)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => IAPService().buyProduct(iapProduct!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text('Pay ${iapProduct.price} Now', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                    
                    const SizedBox(height: 12),
                    
                    // DIRECT GOOGLE PAY BUTTON (UPI Intent for India)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final double price = () {
                            final val = widget.courseData['course_price'];
                            if (val == null) return 0.0;
                            if (val is num) return val.toDouble();
                            if (val is String) return double.tryParse(val) ?? 0.0;
                            return 0.0;
                          }();
                          double finalPrice = price;
                          if (isCouponValid) {
                            finalPrice = discountType == 'percentage' 
                              ? price * (1 - (discountValue / 100)) 
                              : max(0, price - discountValue);
                          }

                          try {
                            final String? transactionId = await GooglePayService().startDirectPayment(
                              upiId: 'merchant@okaxis', // REPLACE with your actual merchant UPI ID
                              receiverName: 'HandSkill Academy',
                              amount: finalPrice.toStringAsFixed(2),
                              courseId: widget.courseData['course_id'],
                              couponCode: appliedCoupon,
                            );
                            
                            if (transactionId != null) {
                               safeSetState(() {
                                 _lastTransactionId = transactionId;
                               });
                               // Close the sheet so the user is ready to be redirected
                               if (context.mounted) Navigator.pop(context); 
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white),
                        label: const Text('Direct Google Pay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A73E8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await _openWhatsApp(userId, courseTitle, appliedCoupon);
                          if (context.mounted) Navigator.pop(context);
                        },
                        icon: const Icon(Icons.message),
                        label: const Text('Enroll via WhatsApp', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openWhatsApp(String? userId, String courseTitle,
      [String? couponCode]) async {
    // First create access request in database
    if (userId != null) {
      try {
        // Create access request record
        await createUserCourseAccessRecord(
            userId, widget.courseData['course_id'], couponCode);

        // Show confirmation to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Access request sent to admin!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error creating access request: $e');
      }
    }

    // Then open WhatsApp with coupon information if applicable
    String couponInfo = '';
    if (couponCode != null && couponCode.isNotEmpty) {
      couponInfo = "\nI'm using coupon code: $couponCode for ₹50 discount";
    }

    final message =
        "Hello, I want to purchase access to '$courseTitle'. My User ID is: ${userId ?? 'Not logged in'}$couponInfo\nMy User Name is: ${name ?? 'Not logged in'}";
    String phoneNumber = "+919746358192";
    // Multiple WhatsApp URL schemes to try
    String whatsappUrl =
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";

    try {
      await launchUrl(
        Uri.parse(whatsappUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      // Fallback: try opening WhatsApp directly
      try {
        await launchUrl(
          Uri.parse(
              "whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}"),
          mode: LaunchMode.externalApplication,
        );
      } catch (e2) {
        debugPrint("WhatsApp is not available");
      }
    }
  }

// Modified function to store coupon code information
  Future<void> createUserCourseAccessRecord(String userId, String courseId,
      [String? couponCode]) async {
    try {
      // Check if record already exists
      final existing = await supabase
          .from('user_course_access')
          .select()
          .eq('user_id', userId)
          .eq('course_id', courseId)
          .maybeSingle();

      if (existing != null) {
        // Update existing record with coupon code
        await supabase
            .from('user_course_access')
            .update({
              'applied_coupon': couponCode,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('course_id', courseId);
      } else {
        // Create new record with coupon code
        await supabase.from('user_course_access').insert({
          'user_id': userId,
          'course_id': courseId,
          'has_paid': false,
          'applied_coupon': couponCode,
        });
      }
    } catch (e) {
      debugPrint('Error creating/updating access record: $e');
      rethrow;
    }
  }

  Widget _buildPremiumPerk(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.yellow.shade700.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.yellow.shade400, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.check_circle_rounded,
              color: Colors.green.shade400, size: 18),
        ],
      ),
    );
  }


// Add a function to add a share button to the course page
  Widget _buildCouponCodeSection() {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      return Container(); // Don't show if not logged in
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CouponCodeWidget(
        userId: userId,
        courseId: widget.courseData['course_id'],
        courseTitle: widget.courseData['course_title'] ?? 'Course',
        courseImage: widget.courseData['course_thumbnail'] ?? '',
        onCouponGenerated: (code) {
          // You can store the code in state if needed
          safeSetState(() {
            // couponCode = code;
          });
        },
      ),
    );
  }


  Widget _buildLessonItem(Map<String, dynamic> lesson, int index) {
    final isCurrentLesson = currentLessonIndex == index;
    final isLocked = index > 0 && !hasPaidAccess;
    final double progressVal = lessonProgress[lesson['id'].toString()] ?? 0.0;
    final bool isCompleted = progressVal >= 0.95;

    return Card(
      color: Colors.black87,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrentLesson ? Colors.green : Colors.yellow.shade700.withValues(alpha: 0.3),
          width: isCurrentLesson ? 2.0 : 1.0,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isCurrentLesson
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: lesson['thamnail_url'] ?? '',
                  width: 100,
                  height: 60,
                  fit: BoxFit.cover,
                  color: isLocked ? Colors.black87 : Colors.black45,
                  colorBlendMode: BlendMode.darken,
                  placeholder: (context, url) => Container(
                    color: Colors.black54,
                    child: Icon(
                      Icons.play_circle_outline,
                      color: Colors.yellow.shade200,
                    ),
                  ),
                ),
              ),
              if (isLocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.lock,
                        color: Colors.yellow.shade700,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              if (!isLocked && !isCompleted)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              if (isCompleted && !isLocked)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  lesson['title'] ?? 'Untitled Lesson',
                  style: TextStyle(
                    color: isCurrentLesson
                        ? Colors.green.shade100
                        : Colors.yellow.shade100,
                    fontWeight:
                        isCurrentLesson ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (isLocked)
                Text(
                  'Premium',
                  style: TextStyle(
                    color: Colors.yellow.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (isCompleted && !isLocked)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 18,
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                lesson['content'] ?? '',
                style: TextStyle(
                  color: isCurrentLesson
                      ? Colors.green.shade50
                      : Colors.yellow.shade50,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressVal,
                        minHeight: 5,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? Colors.green : Colors.yellow.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(progressVal * 100).toInt()}%',
                    style: TextStyle(
                      color: isCompleted ? Colors.green : Colors.yellow.shade200,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          onTap: () {
            if (index == 0 || hasPaidAccess) {
              _selectLesson(lesson, index);
            } else {
              _showWhatsAppPaymentSheet1();
            }
          },
        ),
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildLessonList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        return _buildLessonItem(lessons[index], index);
      },
    );
  }

  Widget _buildMaterialsList() {
    if (isContentLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.yellow));
    }
    if (lessonMaterials.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.picture_as_pdf_outlined,
                  size: 48, color: Colors.yellow.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text('No PDFs for this lesson',
                  style: TextStyle(color: Colors.yellow.shade100)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lessonMaterials.length,
      itemBuilder: (context, index) {
        final material = lessonMaterials[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.picture_as_pdf_rounded,
                  color: Colors.redAccent, size: 24),
            ),
            title: Text(
              material['title'] ?? 'Downloadable PDF',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                material['description'] ?? 'Course material for this lesson',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ),
            trailing: Container(
              decoration: BoxDecoration(
                color: Colors.yellow.shade700,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.download_rounded, color: Colors.black, size: 20),
                onPressed: () => launchUrl(Uri.parse(material['pdf_url'] ?? ''),
                    mode: LaunchMode.externalApplication),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotesList() {
    if (isContentLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.yellow));
    }
    if (lessonNotes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.note_alt_outlined,
                  size: 48, color: Colors.yellow.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text('No notes for this lesson',
                  style: TextStyle(color: Colors.yellow.shade100)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lessonNotes.length,
      itemBuilder: (context, index) {
        final note = lessonNotes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.yellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.note_alt_rounded, color: Colors.yellow, size: 20),
              ),
              title: Text(
                note['title'] ?? 'Lesson Note',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              iconColor: Colors.yellow,
              collapsedIconColor: Colors.yellow.withValues(alpha: 0.5),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    note['content'] ?? '',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedTabContent() {
    switch (activeTab) {
      case 0:
        return _buildLessonList();
      case 1:
        return _buildMaterialsList();
      case 2:
        return _buildNotesList();
      default:
        return _buildLessonList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.courseData['course_title'] ?? '',
                style: TextStyle(
                  color: Colors.yellow.shade200,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Hero(
                tag: 'course-${widget.courseData['course_id']}',
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        widget.courseData['course_thumbnail'] ?? '',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                          Colors.black,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              // Add the report button here
              ReportButton(
                contentType: 'course',
                contentId: widget.courseData['course_id'].toString(),
                contentTitle:
                    widget.courseData['course_title'] ?? 'course Item',
                onReportSubmitted: () {
                  // Optional: Show feedback to user
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Thank you for your report. We\'ll review it soon.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (currentVideoUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.yellow.shade700.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: FlutterFlowVideoLayer(
                          key: ValueKey(currentVideoUrl),
                          path: currentVideoUrl,
                          videoType: VideoType.network,
                          autoPlay: true,
                          looping: false,
                          showControls: true,
                          allowFullScreen: true,
                          allowPlaybackSpeedMenu: true,
                          initialProgress: lessons.isNotEmpty
                              ? (lessonProgress[lessons[currentLessonIndex]['id'].toString()] ?? 0.0)
                              : 0.0,
                          onProgress: (progress) {
                            if (lessons.isNotEmpty) {
                              _updateProgress(
                                  lessons[currentLessonIndex]['id'].toString(),
                                  progress);
                            }
                          },
                          onCompleted: () {
                            // Auto-advance or show completion
                            if (currentLessonIndex < lessons.length - 1) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Lesson Completed! Next starting...'),
                                  backgroundColor: Colors.green.shade800,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              _selectLesson(lessons[currentLessonIndex + 1],
                                  currentLessonIndex + 1);
                            }
                          },
                        ),
                      ),
                    ),
                  ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
                _buildCouponCodeSection(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with icon
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.yellow.shade400,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.school_outlined,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'About this workshop',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Course Title
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  widget.courseData['course_title'] ??
                                      'Workshop Title',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Price Section
                              Row(
                                children: [
                                  // Current Price
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.yellow.shade400,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Text(
                                      'â‚¹${widget.courseData['course_price'] ?? 'Free'}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Retail Price (struck through)
                                  if (widget
                                          .courseData['course_retail_price'] !=
                                      null)
                                    Text(
                                      'â‚¹${widget.courseData['course_retail_price']}',
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 16,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: Colors.grey.shade400,
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Language
                              Row(
                                children: [
                                  Icon(
                                    Icons.language,
                                    color: Colors.yellow.shade400,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Language: ${widget.courseData['course_language'] ?? 'Not specified'}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Description
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  // ignore: deprecated_member_use
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        Colors.yellow.shade400.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Description',
                                      style: TextStyle(
                                        color: Colors.yellow.shade400,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.courseData['course_description'] ??
                                          'No description available',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),

                              if (!hasPaidAccess)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _showWhatsAppPaymentSheet1();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.yellow.shade400,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: const Text(
                                      'Enroll Now',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        const String groupUrl =
                                            'https://chat.whatsapp.com/LoOfZqsRmer7QXvmk5DOoc';

                                        try {
                                          await launchUrl(
                                            Uri.parse(groupUrl),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        } catch (e) {
                                          // Fallback: try opening WhatsApp directly with group link
                                          try {
                                            await launchUrl(
                                              Uri.parse(
                                                  'whatsapp://chat.whatsapp.com/LoOfZqsRmer7QXvmk5DOoc'),
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          } catch (e2) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Could not open WhatsApp group. Please install WhatsApp or try again.'),
                                                  backgroundColor: Colors.red,
                                                  duration:
                                                      Duration(seconds: 4),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.chat,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      label: const Text(
                                        'Join Art Workshop Group',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF25D366), // WhatsApp green
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: 5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        Navigator.of(context).pop();
                                        final isAuthenticated =
                                            await AuthAlertBox
                                                .checkAuthAndShowAlert(
                                          context: context,
                                          customMessage:
                                              "Please login to send message",
                                        );
                                        if (isAuthenticated && context.mounted) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const MessageScreen(
                                                receiverId:
                                                    '188d1b93-1d15-436e-b6ed-455d91ec8bd6',
                                                receiverName: 'HandSkill Admin',
                                                receiverProfileImage:
                                                    'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                                                phonenumber: '+919746358192',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: Colors.yellow.shade400,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.message,
                                                color: Colors.white, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Message Admin',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (hasPaidAccess)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade900.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green.shade300),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'You have full access to this course',
                                  style:
                                      TextStyle(color: Colors.green.shade100),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(),
                      const SizedBox(height: 8),
                DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TabBar(
                          onTap: (index) {
                            setState(() {
                              activeTab = index;
                            });
                          },
                          isScrollable: false,
                          indicatorSize: TabBarIndicatorSize.label,
                          indicator: UnderlineTabIndicator(
                            borderSide:
                                BorderSide(width: 4, color: Colors.yellow.shade700),
                            borderRadius: BorderRadius.circular(2),
                            insets: const EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          labelColor: Colors.yellow.shade700,
                          unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
                          labelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          dividerColor: Colors.transparent,
                          tabs: const [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.video_library_rounded, size: 16),
                                  SizedBox(width: 8),
                                  Text('Lessons'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.description_rounded, size: 16),
                                  SizedBox(width: 8),
                                  Text('PDFs'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit_note_rounded, size: 16),
                                  SizedBox(width: 8),
                                  Text('Notes'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isLoading)
                        Center(
                          child: CircularProgressIndicator(
                            color: Colors.yellow.shade700,
                          ),
                        )
                      else if (lessons.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'No content available for this course yet.',
                              style: TextStyle(color: Colors.yellow.shade100),
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      
                      // Custom Tab Content Logic to stay within SliverToBoxAdapter easily
                      _buildSelectedTabContent(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ],
),
);
  }
}

// Admin panel parts removed. 
// Legacy admin code removed.

class CouponCodeWidget extends StatefulWidget {
  final String userId;
  final String courseId;
  final String courseTitle;
  final String courseImage;
  final Function(String) onCouponGenerated;

  const CouponCodeWidget({
    super.key,
    required this.userId,
    required this.courseId,
    required this.courseTitle,
    required this.courseImage,
    required this.onCouponGenerated,
  });

  @override
  State<CouponCodeWidget> createState() => _CouponCodeWidgetState();
}

class _CouponCodeWidgetState extends State<CouponCodeWidget> {
  void safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  bool isLoading = true;
  bool isGenerating = false;
  String? couponCode;
  String errorMessage = '';
  String? name;
  final supabase = SupaFlow.client;

  @override
  void initState() {
    super.initState();
    _checkCouponCode();
  }

  // Initial check for coupon code
  Future<void> _checkCouponCode() async {
    if (widget.userId.isEmpty) {
      safeSetState(() {
        isLoading = false;
        errorMessage = 'Please login to get your coupon code';
      });
      return;
    }

    try {
      safeSetState(() {
        isLoading = true;
      });

      // Check if user already has a coupon
      final existingCoupon = await supabase
          .from('user_coupons')
          .select('coupon_code')
          .eq('user_id', widget.userId)
          .maybeSingle();

      if (existingCoupon != null && existingCoupon['coupon_code'] != null) {
        // User already has a coupon code
        safeSetState(() {
          couponCode = existingCoupon['coupon_code'];
          isLoading = false;
        });
        final userProfileResponse = await supabase
            .from('profile') // Changed from 'profiles' to 'profile'
            .select('name') // Changed from 'full_name' to 'name'
            .eq('user_id', widget.userId)
            .maybeSingle();
        name = userProfileResponse?['name'].toString();
        // Notify parent
        widget.onCouponGenerated(couponCode!);
        return;
      }

      // No coupon found, but we've completed checking
      safeSetState(() {
        debugPrint(name);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error checking coupon code: $e');
      safeSetState(() {
        errorMessage = 'Could not check for existing coupon. Please try again.';
        isLoading = false;
      });
    }
  }

  // Generate a new coupon code
  Future<void> _generateCouponCode() async {
    if (widget.userId.isEmpty) {
      safeSetState(() {
        errorMessage = 'Please login to get your coupon code';
      });
      return;
    }

    try {
      safeSetState(() {
        isGenerating = true;
        errorMessage = '';
      });

      // Get user profile to create personalized coupon
      final userProfileResponse = await supabase
          .from('profile') // Changed from 'profiles' to 'profile'
          .select('name') // Changed from 'full_name' to 'name'
          .eq('user_id', widget.userId)
          .maybeSingle(); // Changed from single() to maybeSingle() to handle possible missing data

      String initials = 'USER';
      if (userProfileResponse != null && userProfileResponse['name'] != null) {
        name = userProfileResponse['name'].toString();
        // Get initials from name
        // initials = name
        //     .split(' ')
        //     .map((e) => e.isNotEmpty ? e[0] : '')
        //     .join('')
        //     .toUpperCase();
      }

      // Generate unique code with user initials + random numbers
      final random = Random();
      final randomChars = List.generate(5, (_) {
        const chars =
            'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Removed similar looking characters
        return chars[random.nextInt(chars.length)];
      }).join('');

      // Combine initials and random characters
      final newCouponCode =
          '${initials.substring(0, min(initials.length, 2))}$randomChars';

      // Store in database
      await supabase.from('user_coupons').insert({
        'user_id': widget.userId,
        'coupon_code': newCouponCode,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update state
      safeSetState(() {
        couponCode = newCouponCode;
        isGenerating = false;
      });

      // Notify parent
      widget.onCouponGenerated(newCouponCode);
    } catch (e) {
      debugPrint('Error generating coupon code: $e');
      safeSetState(() {
        errorMessage = 'Could not generate coupon code. Please try again.';
        isGenerating = false;
      });
    }
  }

  void _shareCourse() {
    if (couponCode == null) return;

    final courseLink =
        'https://handskilllearn.web.app/courseDetailPage?courseId=${widget.courseId}';
    final message = 'Check out this amazing course: ${widget.courseTitle}!\n\n'
        'The first lesson is FREE!\n\n'
        'Use my coupon code $couponCode to get â‚¹50 off when you purchase the full course.\n\n'
        'name : $name\n\n'
        '$courseLink';

    SharePlus.instance.share(ShareParams(text: message));
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black87,
              Colors.yellow.shade900.withValues(alpha: 0.4),
              Colors.black87,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.yellow.shade700, width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.yellow.shade700,
              ),
              const SizedBox(height: 16),
              Text(
                'Checking for your referral coupon...',
                style: TextStyle(
                  color: Colors.yellow.shade100,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Error state
    if (errorMessage.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade900.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade700, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade300, size: 32),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red.shade100,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                safeSetState(() {
                  errorMessage = '';
                });
                _checkCouponCode();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    // Empty coupon state (no coupon yet - show generate button)
    if (couponCode == null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black87,
              Colors.yellow.shade900.withValues(alpha: 0.4),
              Colors.black87,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.yellow.shade700, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow.shade900.withValues(alpha: 0.5),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14.5)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.card_giftcard,
                    color: Colors.yellow.shade200,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Referral Program',
                      style: TextStyle(
                        color: Colors.yellow.shade100,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Earning â‚¹300 Today!',
                              style: TextStyle(
                                color: Colors.yellow.shade200,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Generate your unique referral code and start sharing',
                              style: TextStyle(
                                color: Colors.yellow.shade100,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Course thumbnail
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image:
                                CachedNetworkImageProvider(widget.courseImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Benefits info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.yellow.shade700),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How it works:',
                          style: TextStyle(
                            color: Colors.yellow.shade200,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: Colors.yellow.shade500, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your friends get â‚¹50 off with your code',
                                style: TextStyle(
                                  color: Colors.yellow.shade100,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: Colors.yellow.shade500, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'You earn â‚¹300 when they purchase',
                                style: TextStyle(
                                  color: Colors.yellow.shade100,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Generate button
                  ElevatedButton.icon(
                    onPressed: isGenerating ? null : _generateCouponCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade700,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor:
                          Colors.yellow.shade900.withValues(alpha: 0.3),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: isGenerating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.auto_awesome, size: 18),
                    label: Text(
                      isGenerating
                          ? 'Generating Code...'
                          : 'Generate My Referral Code',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Coupon exists state (show the coupon code)
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black87,
            Colors.yellow.shade900.withValues(alpha: 0.4),
            Colors.black87,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.yellow.shade700, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with gift icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.yellow.shade900.withValues(alpha: 0.5),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14.5)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.card_giftcard,
                  color: Colors.yellow.shade200,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your Referral Coupon',
                    style: TextStyle(
                      color: Colors.yellow.shade100,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Coupon code display
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Share & Earn â‚¹300',
                            style: TextStyle(
                              color: Colors.yellow.shade200,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Friends get â‚¹50 off, you get â‚¹300 when they purchase!',
                            style: TextStyle(
                              color: Colors.yellow.shade100,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Course thumbnail
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(widget.courseImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Coupon code container
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.yellow.shade700),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Code:',
                        style: TextStyle(
                          color: Colors.yellow.shade100,
                          fontSize: 14,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          couponCode ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.yellow.shade100,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ).animate().fadeIn().slideX(),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: couponCode ?? ''));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Coupon copied to clipboard!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.copy,
                          color: Colors.yellow.shade500,
                          size: 20,
                        ),
                        tooltip: 'Copy to clipboard',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Share button
                ElevatedButton.icon(
                  onPressed: _shareCourse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text(
                    'Share Course with Friends',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WhatsAppShareHelper {
  // Static base URL for your application
  static const String baseAppUrl = 'https://handskillapp.web.app';

  /// Share to WhatsApp with all item details (for general sharing)
  static Future<void> shareToWhatsApp({
    required BuildContext context,
    required Map<String, dynamic> item,
  }) async {
    try {
      String message = _buildFullMessage(item);
      String whatsappUrl = _buildWhatsAppUrl(message: message);

      await _launchWhatsApp(context, whatsappUrl);
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Error sharing to WhatsApp: $e');
      }
    }
  }

  /// Share to specific WhatsApp number (for direct messaging)
  static Future<void> shareToSpecificWhatsAppNumber({
    required BuildContext context,
    required Map<String, dynamic> item,
    required String phoneNumber,
    bool includeFullDetails = true,
  }) async {
    try {
      String message = includeFullDetails
          ? _buildFullMessage(item)
          : _buildSimpleMessage(item);

      // Format phone number
      String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      if (formattedNumber.startsWith('0')) {
        formattedNumber = formattedNumber.substring(1);
      }

      String whatsappUrl = _buildWhatsAppUrl(
        message: message,
        phoneNumber: formattedNumber,
      );

      await _launchWhatsApp(context, whatsappUrl);
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Error sharing to WhatsApp: $e');
      }
    }
  }

  /// Share only link without item details
  static Future<void> shareOnlyLink({
    required BuildContext context,
    required Map<String, dynamic> item,
  }) async {
    try {
      String itemLink = _generateItemLink(item);
      String message = 'Check this out: $itemLink';
      String whatsappUrl = _buildWhatsAppUrl(message: message);

      await _launchWhatsApp(context, whatsappUrl);
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Error sharing link to WhatsApp: $e');
      }
    }
  }

  static Future<void> sendWhatsAppMessageSimple({
    required BuildContext context,
    required String phoneNumber,
    required String message,
  }) async {
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (!formattedNumber.startsWith('+')) {
      formattedNumber = formattedNumber; // Add your country code
    }

    String encodedMessage = Uri.encodeComponent(message);

    // Try multiple URL formats
    List<String> urls = [
      "https://wa.me/$formattedNumber?text=$encodedMessage",
      "whatsapp://send?phone=$formattedNumber&text=$encodedMessage",
      "https://api.whatsapp.com/send?phone=$formattedNumber&text=$encodedMessage",
    ];

    bool launched = false;
    for (String url in urls) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          launched = true;
          break;
        }
      } catch (e) {
        continue;
      }
    }

    if (!launched && context.mounted) {
      _showError(context, 'Error launching WhatsApp');
    }
  }

  /// Build full message with all item details
  static String _buildFullMessage(Map<String, dynamic> item) {
    String message = '';

    if (item['name'] != null && item['name'].toString().isNotEmpty) {
      message += 'Artist: ${item['name']}\n';
    }

    if (item['shop_name'] != null && item['shop_name'].toString().isNotEmpty) {
      message += 'Shop: ${item['shop_name']}\n';
    }

    if (item['phone_no'] != null && item['phone_no'].toString().isNotEmpty) {
      message += 'Phone: ${item['phone_no']}\n';
    }

    if (item['gallery_description'] != null &&
        item['gallery_description'].toString().isNotEmpty) {
      message += 'Description: ${item['gallery_description']}\n';
    }

    if (item['gallery_category'] != null &&
        item['gallery_category'].toString().isNotEmpty) {
      message += 'Category: ${item['gallery_category']}\n';
    }

    String itemLink = _generateItemLink(item);
    message += '\nðŸ”— Check it out here: $itemLink';

    return message;
  }

  /// Build simple message for direct messaging
  static String _buildSimpleMessage(Map<String, dynamic> item) {
    String message = 'Hi! ';

    if (item['name'] != null && item['name'].toString().isNotEmpty) {
      message += 'I\'m interested in your work (${item['name']}). ';
    }

    String itemLink = _generateItemLink(item);
    message += '\n\nðŸ”— Link: $itemLink';

    return message;
  }

  /// Generate item link based on item data
  static String _generateItemLink(Map<String, dynamic> item) {
    // You can customize this based on your app's URL structure
    String itemId = item['id']?.toString() ??
        item['gallery_id']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();

    return '$baseAppUrl/item/$itemId';
  }

  /// Build WhatsApp URL based on platform
  static String _buildWhatsAppUrl({
    required String message,
    String? phoneNumber,
  }) {
    final encodedMessage = Uri.encodeComponent(message);

    if (kIsWeb) {
      // Web platform
      if (phoneNumber != null) {
        return 'https://wa.me/$phoneNumber?text=$encodedMessage';
      } else {
        return 'https://wa.me/?text=$encodedMessage';
      }
    } else if (Platform.isIOS) {
      // iOS platform
      if (phoneNumber != null) {
        return 'whatsapp://send?phone=$phoneNumber&text=$encodedMessage';
      } else {
        return 'whatsapp://send?text=$encodedMessage';
      }
    } else {
      // Android platform
      if (phoneNumber != null) {
        return 'https://wa.me/$phoneNumber?text=$encodedMessage';
      } else {
        return 'https://wa.me/?text=$encodedMessage';
      }
    }
  }

  /// Launch WhatsApp with error handling
  static Future<void> _launchWhatsApp(
      BuildContext context, String whatsappUrl) async {
    try {
      if (kIsWeb) {
        // Web platform - simple launch
        final uri = Uri.parse(whatsappUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } else if (context.mounted) {
          _showError(context, 'Could not open WhatsApp Web');
        }
      } else {
        // Mobile platforms - try multiple methods
        await _launchWhatsAppMobile(context, whatsappUrl);
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Could not launch WhatsApp: $e');
      }
    }
  }

  static Future<void> _launchWhatsAppMobile(
      BuildContext context, String whatsappUrl) async {
    // Extract phone number and message from the original URL for fallbacks
    String phoneNumber = '';
    String message = '';

    try {
      Uri uri = Uri.parse(whatsappUrl);
      phoneNumber = uri.path.replaceAll('/', '');
      message = uri.queryParameters['text'] ?? '';
    } catch (e) {
      // Continue with original URL if parsing fails
    }

    // Method 1: Try the original URL first
    if (await _tryLaunchUrl(whatsappUrl)) {
      return;
    }

    // Method 2: Try different URL formats based on platform
    List<String> fallbackUrls = [];

    if (Platform.isIOS) {
      // iOS fallbacks
      fallbackUrls = [
        'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}',
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
        'https://api.whatsapp.com/send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}',
      ];
    } else if (Platform.isAndroid) {
      // Android fallbacks
      fallbackUrls = [
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
        'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}',
        'https://api.whatsapp.com/send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}',
      ];
    }

    // Try each fallback URL
    for (String url in fallbackUrls) {
      if (await _tryLaunchUrl(url)) {
        return;
      }
    }

    // If all methods fail, show installation dialog
    if (context.mounted) {
      _showWhatsAppNotInstalledDialog(context);
    }
  }

  static Future<bool> _tryLaunchUrl(String url) async {
    try {
      final uri = Uri.parse(url);

      // Try to launch without checking canLaunchUrl first
      // because canLaunchUrl sometimes returns false even when the app exists
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    } catch (e) {
      // If direct launch fails, try with canLaunchUrl check
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        }
      } catch (e2) {
        // Silently continue to next method
      }
    }
    return false;
  }

  static void _showWhatsAppNotInstalledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('WhatsApp Not Available'),
          content: Text(Platform.isIOS
              ? 'WhatsApp is not installed. Would you like to install it from the App Store?'
              : 'WhatsApp is not installed. Would you like to install it from the Play Store?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _installWhatsApp();
              },
              child: const Text('Install'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _installWhatsApp() async {
    String storeUrl;

    if (Platform.isIOS) {
      storeUrl = 'https://apps.apple.com/app/whatsapp-messenger/id310633997';
    } else if (Platform.isAndroid) {
      storeUrl = 'https://play.google.com/store/apps/details?id=com.whatsapp';
    } else {
      storeUrl = 'https://www.whatsapp.com/download';
    }

    await _tryLaunchUrl(storeUrl);
  }

  /// Show error message to user
  static void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

