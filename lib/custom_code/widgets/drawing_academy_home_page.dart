// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'courses_widget.dart'; // For CourseDetailPage

class DrawingAcademyHomePage extends StatefulWidget {
  const DrawingAcademyHomePage({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<DrawingAcademyHomePage> createState() => _DrawingAcademyHomePageState();
}

class _DrawingAcademyHomePageState extends State<DrawingAcademyHomePage> {
  final supabase = SupaFlow.client;
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> offlineEvents = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      safeSetState(() => isLoading = true);
      await Future.wait([_loadCourses(), _loadEvents()]);
    } catch (e) {
      print('Error loading initial data: $e');
      safeSetState(() => error = 'Failed to load data');
    } finally {
      safeSetState(() => isLoading = false);
    }
  }

  Future<void> _loadEvents() async {
    try {
      final response = await supabase.from('offline_event').select();
      if (mounted) {
        safeSetState(() {
          offlineEvents = List<Map<String, dynamic>>.from(response ?? []);
        });
      }
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  Future<void> _loadCourses() async {
    try {
      final response = await supabase.from('allcourses_tech').select();
      if (mounted) {
        final allCourses = List<Map<String, dynamic>>.from(response);
        final uniqueTitles = <String>{};
        final uniqueCourses = <Map<String, dynamic>>[];

        for (final course in allCourses) {
          final title = course['course_title']?.toString() ?? '';
          if (!uniqueTitles.contains(title)) {
            uniqueTitles.add(title);
            uniqueCourses.add(course);
          }
        }

        safeSetState(() {
          courses = uniqueCourses;
        });
      }
    } catch (e) {
      print('Error fetching courses: $e');
      rethrow;
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: Colors.black, // Sleeker dark background
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.primary,
              ).animate().fadeIn(),
            )
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: theme.error),
                      const SizedBox(height: 16),
                      Text(error!, style: theme.bodyMedium),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadInitialData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildAppBar(theme),
                    _buildWelcomeHeader(theme),
                    if (offlineEvents.isNotEmpty) _buildEventsSection(theme),
                    _buildSectionHeader(theme, 'Featured Masterclasses'),
                    _buildCoursesList(theme),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
    );
  }

  Widget _buildAppBar(FlutterFlowTheme theme) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: 0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.black.withValues(alpha: 0.6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
            ),
            child: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.yellow.shade600,
                          Colors.orange.shade600
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child:
                        const Icon(Icons.brush, color: Colors.black, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Hand Skill Academy',
                    style: theme.headlineSmall.override(
                      fontFamily: theme.headlineSmallFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: theme.primaryText),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeHeader(FlutterFlowTheme theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, Creative!',
              style: theme.displaySmall.override(
                fontFamily: theme.displaySmallFamily,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
            const SizedBox(height: 8),
            Text(
              "What would you like to master today?",
              style: theme.labelLarge.override(
                fontFamily: theme.labelLargeFamily,
                color: Colors.grey.shade400,
              ),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsSection(FlutterFlowTheme theme) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeaderPadding(theme, 'Upcoming Events'),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: offlineEvents.length,
              itemBuilder: (context, index) {
                final event = offlineEvents[index];
                return _buildEventCard(theme, event);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(FlutterFlowTheme theme, Map<String, dynamic> event) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
        image: DecorationImage(
          image: NetworkImage(event['image_url'] ?? ''),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.yellow.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.8),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'LIVE EVENT',
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event['title']?.toString() ?? '',
              style: theme.titleLarge.override(
                fontFamily: theme.titleLargeFamily,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              event['description']?.toString() ?? '',
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                color: Colors.white70,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildSectionHeader(FlutterFlowTheme theme, String title) {
    return SliverToBoxAdapter(
      child: _buildSectionHeaderPadding(theme, title),
    );
  }

  Widget _buildSectionHeaderPadding(FlutterFlowTheme theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.titleLarge.override(
              fontFamily: theme.titleLargeFamily,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'See All',
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                color: Colors.yellow.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList(FlutterFlowTheme theme) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final course = courses[index];
            return _buildCourseListItem(theme, course, index);
          },
          childCount: courses.length,
        ),
      ),
    );
  }

  Widget _buildCourseListItem(
      FlutterFlowTheme theme, Map<String, dynamic> course, int index) {
    return InkWell(
      onTap: () => _navigateToCourseDetail(context, course),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'course-${course['course_id']}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  course['course_thumbnail'] ?? '',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 100,
                    color: theme.accent1.withValues(alpha: 0.2),
                    child:
                        Icon(Icons.image_not_supported, color: theme.accent1),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['course_title'] ?? '',
                    style: theme.titleMedium.override(
                      fontFamily: theme.titleMediumFamily,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          color: Colors.yellow.shade600, size: 18),
                      const SizedBox(width: 4),
                      Text('4.8',
                          style: theme.bodySmall.override(
                              fontFamily: theme.bodySmallFamily,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time_rounded,
                          color: Colors.grey.shade500, size: 16),
                      const SizedBox(width: 4),
                      Text('12 Hours',
                          style: theme.bodySmall.override(
                              fontFamily: theme.bodySmallFamily,
                              color: Colors.grey.shade400)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${course['course_price'] ?? 'Free'}',
                        style: theme.titleMedium.override(
                          fontFamily: theme.titleMediumFamily,
                          color: Colors.yellow.shade600,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.yellow.shade700,
                              Colors.orange.shade700
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.yellow.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            size: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1),
    );
  }
}

