import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:ui';

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

final supabase = SupaFlow.client;

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
  }

  void _navigateToCourseDetail(
      BuildContext context, Map<String, dynamic> course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailPage(courseData: course),
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
      }
    } catch (e) {
      safeSetState(() {
        error = 'Error fetching courses: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
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
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () => _navigateToCourseDetail(context, course),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.alternate.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section: Image & Header Info
              Stack(
                children: [
                  Hero(
                    tag: 'course-$courseId',
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                      child: CachedNetworkImage(
                        imageUrl: course['course_thumbnail'] ?? '',
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          height: 220,
                          color: theme.accent1.withValues(alpha: 0.2),
                          child: Icon(Icons.broken_image_outlined,
                              color: theme.accent1, size: 48),
                        ),
                      ),
                    ),
                  ),
                  // Glassmorphic Overlays
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: FavoriteButton(
                            courseId: courseId?.toString() ?? ''),
                      ),
                    ),
                  ),
                  if (course['course_language'] != null)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            color: Colors.black.withValues(alpha: 0.4),
                            child: Row(
                              children: [
                                Icon(Icons.language,
                                    color: theme.primary, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  course['course_language'].toString(),
                                  style: theme.bodySmall.override(
                                    fontFamily: theme.bodySmallFamily,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            course['course_title'] ??
                                'Full Drawing Masterclass',
                            style: theme.titleLarge.override(
                              fontFamily: theme.titleLargeFamily,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star_rounded,
                                  color: theme.primary, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '4.9',
                                style: theme.bodySmall.override(
                                  fontFamily: theme.bodySmallFamily,
                                  color: theme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      course['course_description'] ??
                          'Master the art of sketching with this comprehensive guide.',
                      style: theme.labelMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Investment',
                              style: theme.labelSmall,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'â‚¹${course['course_price'] ?? '0'}',
                                  style: theme.titleLarge.override(
                                    fontFamily: theme.titleLargeFamily,
                                    color: theme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (course['course_retail_price'] != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    'â‚¹${course['course_retail_price']}',
                                    style: theme.labelSmall.override(
                                      fontFamily: theme.labelSmallFamily,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (mounted) {
                              _navigateToCourseDetail(context, course);
                            }
                          },
                          icon: const Icon(Icons.play_circle_filled, size: 20),
                          label: const Text('Start Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
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
    )
        .animate()
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
          isFavorite = response != null;
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
  _CourseDetailPageState createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  void safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  List<Map<String, dynamic>> lessons = [];
  int currentLessonIndex = 0;
  String currentVideoUrl = '';
  bool isLoading = true;
  bool hasPaidAccess = false;
  String? name;

  final supabase = SupaFlow.client;

  @override
  void initState() {
    super.initState();
    _fetchLessons();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPaidAccess(); // If this includes setState or overlay/dialog
    });
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
        if (lessons.isNotEmpty) {
          currentVideoUrl = lessons[0]['video_url'] ?? '';
        }
      });
    } catch (e) {
      debugPrint('Error fetching lessons: $e');
      safeSetState(() {
        isLoading = false;
      });
    }
  }

  void _showWhatsAppPaymentSheet1() {
    final userId = supabase.auth.currentUser?.id;

    final courseTitle = widget.courseData['course_title'] ?? 'Course';

    final courseId = widget.courseData['course_id'];
    final TextEditingController couponController = TextEditingController();
    String? appliedCoupon;
    bool isApplyingCoupon = false;
    bool isCouponValid = false;
    String couponMessage = '';

    // Function to validate coupon
    Future<Map<String, dynamic>> validateCoupon(String couponCode) async {
      // if (couponCode.isEmpty) ;

      try {
        // Check if coupon exists in database
        final response = await supabase
            .from('user_coupons')
            .select('user_id, is_active')
            .eq('coupon_code', couponCode)
            .single();

        final couponOwnerId = response['user_id'];
        final isActive = response['is_active'] ?? true;

        // Don't allow users to use their own coupon
        if (couponOwnerId == userId) {
          return {
            'isValid': false,
            'message': 'You cannot use your own coupon code'
          };
        }

        if (!isActive) {
          return {
            'isValid': false,
            'message': 'This coupon has been deactivated'
          };
        }

        return {
          'isValid': true,
          'message': 'Coupon applied! â‚¹50 off',
          'couponOwnerId': couponOwnerId
        };

        return {'isValid': false, 'message': 'Invalid coupon code'};
      } catch (e) {
        debugPrint('Error validating coupon: $e');
        return {'isValid': false, 'message': 'Error validating coupon'};
      }
    }

    // This function will generate a unique coupon code for the user
    Future<String> generateCouponCode() async {
      try {
        // Check if user already has a coupon code
        final existingCoupon = await supabase
            .from('user_coupons')
            .select('coupon_code')
            .eq('user_id', userId as Object)
            .maybeSingle();

        if (existingCoupon != null) {
          return existingCoupon['coupon_code'];
        }

        // Generate a new coupon code - user's initials + random alphanumeric
        final userResponse = await supabase
            .from('profile')
            .select('name')
            .eq('user_id', userId as Object)
            .single();

        String initials = 'USER';
        if (userResponse['name'] != null) {
          final fullName = userResponse['name'].toString();
          initials = fullName
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0] : '')
              .join('')
              .toUpperCase();
        }

        // Add random characters to make it unique
        final random = Random();
        final randomStr = List.generate(4, (_) => random.nextInt(10)).join('');
        final couponCode = '$initials$randomStr';

        // Store in database
        await supabase.from('user_coupons').insert({
          'user_id': userId,
          'coupon_code': couponCode,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        });

        return couponCode;
      } catch (e) {
        debugPrint('Error generating coupon: $e');
        return 'ERROR';
      }
    }

    // This builds the coupon application section
    Widget buildCouponSection(StateSetter safeSetState) {
      return Column(
        children: [
          Divider(color: Colors.yellow.shade600, height: 32),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: couponController,
                  style: TextStyle(color: Colors.yellow.shade100),
                  decoration: InputDecoration(
                    hintText: 'Have a coupon code?',
                    hintStyle: TextStyle(
                        color: Colors.yellow.shade100.withValues(alpha: 0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.yellow.shade700),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.yellow.shade500),
                    ),
                    filled: true,
                    fillColor: Colors.black45,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isApplyingCoupon
                    ? null
                    : () async {
                        safeSetState(() {
                          isApplyingCoupon = true;
                        });

                        final result =
                            await validateCoupon(couponController.text);

                        safeSetState(() {
                          isCouponValid = result['isValid'] ?? false;
                          couponMessage = result['message'] ?? 'Invalid coupon';
                          if (isCouponValid) {
                            appliedCoupon = couponController.text;
                          }
                          isApplyingCoupon = false;
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade700,
                  disabledBackgroundColor:
                      Colors.yellow.shade900.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isApplyingCoupon ? 'Applying...' : 'Apply',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (couponMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                couponMessage,
                style: TextStyle(
                  color: isCouponValid
                      ? Colors.green.shade300
                      : Colors.red.shade300,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (isCouponValid)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.green.shade900.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green.shade300, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Discount: â‚¹50 off',
                      style: TextStyle(
                        color: Colors.green.shade100,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    // This builds the share course with coupon section
    Widget buildShareSection(String userCoupon) {
      return Column(
        children: [
          Divider(color: Colors.yellow.shade600, height: 32),
          Text(
            'Share & Earn â‚¹300',
            style: TextStyle(
              color: Colors.yellow.shade200,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your coupon code with friends. They get â‚¹50 off and you earn â‚¹300 when they purchase!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.yellow.shade100),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.yellow.shade700),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    userCoupon,
                    style: TextStyle(
                      color: Colors.yellow.shade100,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: userCoupon));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Coupon copied to clipboard!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.copy,
                    color: Colors.yellow.shade500,
                  ),
                  tooltip: 'Copy to clipboard',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              final courseLink =
                  '${WhatsAppShareHelper.baseAppUrl}/elearningPage/${widget.courseData['course_id']}';
              final message =
                  'Check out this amazing course: ${widget.courseData['title']}!\n\n'
                  'The first lesson is FREE!\n\n'
                  'Use my coupon code $userCoupon to get â‚¹50 off when you purchase the full course.\n\n'
                  'name : $name\n\n'
                  '$courseLink';

              Share.share(message);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.share, color: Colors.black),
            label: const Text(
              'Share Course with Friends',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // This StatefulBuilder allows us to update state within the bottom sheet
        return StatefulBuilder(
          builder: (context, setState) {
            // Get or generate user's coupon code for sharing
            Future<String> userCouponFuture = userId != null
                ? generateCouponCode()
                : Future.value('Login to get a coupon');

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black87,
                    Colors.yellow.shade900.withValues(alpha: 0.7),
                    Colors.black87,
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border.all(color: Colors.yellow.shade700, width: 1.5),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock,
                      color: Colors.yellow.shade200,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Premium Content',
                      style: TextStyle(
                        color: Colors.yellow.shade200,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'To access all lessons in "$courseTitle", you need to purchase this course.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.yellow.shade100,
                        fontSize: 16,
                      ),
                    ),

                    // Coupon application section
                    buildCouponSection(safeSetState),

                    const SizedBox(height: 16),
                    Text(
                      'Steps:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.yellow.shade100,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1. Click the button below to send your request',
                            style: TextStyle(color: Colors.yellow.shade100),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '2. Chat with us on WhatsApp to discuss payment',
                            style: TextStyle(color: Colors.yellow.shade100),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '3. After payment, admin will grant you access',
                            style: TextStyle(color: Colors.yellow.shade100),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your User ID: ${userId ?? "Not logged in"}',
                      style: TextStyle(
                        color: Colors.yellow.shade100,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // If coupon is applied, we pass this information to WhatsApp
                        await _openWhatsApp(userId, courseTitle, appliedCoupon);

                        try {
                          // Insert record into user_course_access table
                          await supabase.from('user_course_access').insert({
                            'user_id': userId,
                            'course_id': courseId,
                            'has_paid': false,
                            'applied_coupon':
                                appliedCoupon, // Store which coupon was used
                          });

                          // Show success message
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Access request submitted successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Close dialog
                            if (Navigator.canPop(context)) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Navigator.pop(context);
                              });
                            }
                          }
                        } catch (e) {
                          // Show error message
                          debugPrint('Error submitting request: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF25D366), // WhatsApp green
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.message, color: Colors.white),
                      label: Text(
                        isCouponValid
                            ? 'Request Access & Pay via WhatsApp (₹50 off)'
                            : 'Request Access & Pay via WhatsApp',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // User's coupon code to share with others
                    FutureBuilder<String>(
                      future: userCouponFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: CircularProgressIndicator(
                              color: Colors.yellow.shade200,
                            ),
                          );
                        }

                        if (snapshot.hasData && userId != null) {
                          return buildShareSection(snapshot.data!);
                        }

                        return const SizedBox.shrink();
                      },
                    ),

                    const SizedBox(height: 16),
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

// Add a function to add a share button to the course page
  Widget _buildShareCourseButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: () async {
          final userId = supabase.auth.currentUser?.id;

          // Get or generate coupon code
          String couponCode = 'FREELESSON';
          if (userId != null) {
            try {
              final existingCoupon = await supabase
                  .from('user_coupons')
                  .select('coupon_code')
                  .eq('user_id', userId)
                  .maybeSingle();

              if (existingCoupon != null) {
                couponCode = existingCoupon['coupon_code'];
              } else {
                // Generate code logic (simplified here)
                final random = Random();
                final randomStr =
                    List.generate(4, (_) => random.nextInt(10)).join('');
                couponCode = 'USER$randomStr';

                // Store in database
                await supabase.from('user_coupons').insert({
                  'user_id': userId,
                  'coupon_code': couponCode,
                  'is_active': true,
                  'created_at': DateTime.now().toIso8601String(),
                });
              }
            } catch (e) {
              debugPrint('Error getting/generating coupon: $e');
            }
          }

          // Create share message
          final courseTitle = widget.courseData['course_title'];
          final courseId = widget.courseData['course_id'];
          final courseLink = 'https://yourappdomain.com/course/$courseId';
          final message =
              'Check out this amazing course: $courseTitle!\n\nThe first lesson is FREE!\n\nUse my coupon code $couponCode to get â‚¹50 off when you decide to purchase.\n\n$courseLink';

          // Share course
          Share.share(message);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.share, color: Colors.white),
        label: const Text(
          'Share Course (First lesson FREE)',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

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

  Future<void> _openWhatsApp1(String? userId, String courseTitle) async {
    // First create access request in database
    if (userId != null) {
      try {
        // Create access request record
        await createUserCourseAccessRecord(
            userId, widget.courseData['course_id']);

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

    // Then open WhatsApp
    final message =
        "Hello, I want to purchase access to '$courseTitle'. My User ID is: ${userId ?? 'Not logged in'}";
    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = "https://wa.me/919746358192?text=$encodedMessage";

    // Launch WhatsApp with Uri.parse
    launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
  }


  Widget _buildLessonItem(Map<String, dynamic> lesson, int index) {
    final isCurrentLesson = currentLessonIndex == index;
    final isLocked = index > 0 && !hasPaidAccess;

    return Card(
      color: Colors.black87,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          // Change border color based on selection
          color: isCurrentLesson ? Colors.green : Colors.yellow.shade700,
          width: isCurrentLesson ? 2.0 : 1.5,
        ),
      ),
      child: Container(
        // Add a subtle background color change for selected item
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
              // Add green checkmark for selected lesson
              if (isCurrentLesson && !isLocked)
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
                      size: 16,
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
              // Alternative: Add checkmark in title area
              if (isCurrentLesson && !isLocked)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
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
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: 0.0,
                backgroundColor: Colors.black54,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCurrentLesson ? Colors.green : Colors.yellow.shade700,
                ),
              ),
            ],
          ),
          onTap: () {
            if (index == 0 || hasPaidAccess) {
              // Free first lesson or paid user can access any lesson
              safeSetState(() {
                currentLessonIndex = index;
                currentVideoUrl = lesson['video_url'] ?? '';
              });
            } else {
              // Show payment bottom sheet for premium lessons
              _showWhatsAppPaymentSheet1();
            }
          },
        ),
      ),
    ).animate().fadeIn().slideX();
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
                          path: currentVideoUrl,
                          videoType: VideoType.network,
                          autoPlay: false,
                          looping: false,
                          showControls: true,
                          allowFullScreen: true,
                          allowPlaybackSpeedMenu: false,
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
                                            if (mounted) {
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
                                        if (isAuthenticated) {
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Course Content',
                            style: TextStyle(
                              color: Colors.yellow.shade200,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!hasPaidAccess)
                            TextButton.icon(
                              onPressed: () {
                                _showWhatsAppPaymentSheet1();
                              },
                              icon: Icon(
                                Icons.lock_open,
                                color: Colors.yellow.shade700,
                                size: 16,
                              ),
                              label: Text(
                                'Get Full Access',
                                style: TextStyle(
                                  color: Colors.yellow.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                        'No lessons available for this course yet.',
                        style: TextStyle(color: Colors.yellow.shade100),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lessons.length,
                    itemBuilder: (context, index) {
                      return _buildLessonItem(lessons[index], index);
                    },
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

    Share.share(message);
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
      _showError(context, 'Error sharing to WhatsApp: $e');
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
      _showError(context, 'Error sharing to WhatsApp: $e');
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
      _showError(context, 'Error sharing link to WhatsApp: $e');
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

    if (!launched) {
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
        } else {
          _showError(context, 'Could not open WhatsApp Web');
        }
      } else {
        // Mobile platforms - try multiple methods
        await _launchWhatsAppMobile(context, whatsappUrl);
      }
    } catch (e) {
      _showError(context, 'Could not launch WhatsApp: $e');
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
    _showWhatsAppNotInstalledDialog(context);
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
