// Automatic FlutterFlow imports
import 'package:pocket_mates_app/auth_page/auth_page_widget.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!

class ReportDialog extends StatefulWidget {
  final double? width;
  final double? height;
  final String contentType;
  final String contentId;
  final String contentTitle;
  final VoidCallback? onReportSubmitted;

  const ReportDialog({
    super.key,
    required this.contentType,
    required this.contentId,
    required this.contentTitle,
    this.onReportSubmitted,
    this.width,
    this.height,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog>
    with SingleTickerProviderStateMixin {
  ReportType? _selectedReportType;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  bool _hasReported = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _animationController.forward();
    _checkIfAlreadyReported();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _checkIfAlreadyReported() async {
    final hasReported = await ReportHelper.hasUserReported(
      contentType: widget.contentType,
      contentId: widget.contentId,
    );
    setState(() {
      _hasReported = hasReported;
    });
  }

  Future<void> _submitReport() async {
    if (_selectedReportType == null) {
      _showSnackBar('Please select a report reason', Colors.orange);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await ReportHelper.submitReport(
      contentType: widget.contentType,
      contentId: widget.contentId,
      reportType: _selectedReportType!.name,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      widget.onReportSubmitted?.call();
      Navigator.of(context).pop();
      _showSnackBar('Report submitted successfully. We\'ll review it soon.',
          Colors.green);
    } else {
      _showSnackBar('Failed to submit report. Please try again.', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.yellow, Color.fromARGB(255, 249, 198, 12)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.flag,
                      color: Colors.black,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Report Content',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_hasReported) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 253, 195, 195),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info, color: Colors.red),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'You have already reported this content. Our team is reviewing it.',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Content info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reporting: ${widget.contentTitle}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Type: ${widget.contentType.toUpperCase()}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Report reasons
                      const Text(
                        'Why are you reporting this content?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ...ReportType.values.map((reportType) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedReportType == reportType
                                  ? Colors.red.shade400
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: RadioListTile<ReportType>(
                            title: Text(
                              reportType.displayName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            value: reportType,
                            groupValue: _selectedReportType,
                            onChanged: _hasReported
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedReportType = value;
                                    });
                                  },
                            activeColor: Colors.red.shade400,
                          ),
                        );
                      }),

                      const SizedBox(height: 20),

                      // Description field
                      const Text(
                        'Additional details (optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        enabled: !_hasReported,
                        maxLines: 3,
                        maxLength: 500,
                        decoration: InputDecoration(
                          hintText:
                              'Please provide more details about the issue...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red.shade400),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer buttons
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _hasReported || _isSubmitting
                            ? null
                            : _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(_hasReported
                                ? 'Already Reported'
                                : 'Submit Report'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Usage example for your GalleryDetailPage
class ReportButton extends StatelessWidget {
  final String contentType;
  final String contentId;
  final String contentTitle;
  final VoidCallback? onReportSubmitted;

  const ReportButton({
    super.key,
    required this.contentType,
    required this.contentId,
    required this.contentTitle,
    this.onReportSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: const Color.fromARGB(255, 27, 27, 27),
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) async {
        if (value == 'report') {
          final isAuthenticated = await AuthAlertBox.checkAuthAndShowAlert(
            context: context,
            customMessage: "Please login to report content",
          );
          if (isAuthenticated) {
            ReportHelper.showReportDialog(
              // ignore: use_build_context_synchronously
              context: context,
              contentType: contentType,
              contentId: contentId,
              contentTitle: contentTitle,
              onReportSubmitted: onReportSubmitted,
            );
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'report',
          child: Container(
            color: const Color.fromARGB(255, 27, 27, 27), // Background color
            padding: const EdgeInsets.symmetric(
                vertical: 8, horizontal: 12), // Optional padding
            child: const Row(
              children: [
                Icon(Icons.flag, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text(
                  'Report',
                  style: TextStyle(color: Colors.white), // White text
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ReportHelper {
  static final _supabase = Supabase.instance.client;

  // Report types enum for consistency
  // enum ReportType {
  //   inappropriate('Inappropriate Content'),
  //   spam('Spam'),
  //   harassment('Harassment'),
  //   violence('Violence'),
  //   nudity('Nudity/Sexual Content'),
  //   hateSpeech('Hate Speech'),
  //   misinformation('Misinformation'),
  //   copyright('Copyright Violation'),
  //   other('Other');

  //   const ReportType(this.displayName);
  //   final String displayName;
  // }

  // Submit report to Supabase
  static Future<bool> submitReport({
    required String contentType, // 'gallery', 'comment', 'user'
    required String contentId,
    required String reportType,
    required String? description,
    String? additionalInfo,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be logged in to report content');
      }

      await _supabase.from('reports').insert({
        'reporter_id': currentUser.id,
        'content_type': contentType,
        'content_id': contentId,
        'report_type': reportType,
        'description': description,
        'additional_info': additionalInfo,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error submitting report: $e');
      return false;
    }
  }

  // Check if user has already reported this content
  static Future<bool> hasUserReported({
    required String contentType,
    required String contentId,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return false;

      final response = await _supabase
          .from('reports')
          .select('id')
          .eq('reporter_id', currentUser.id)
          .eq('content_type', contentType)
          .eq('content_id', contentId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking report status: $e');
      return false;
    }
  }

  // Show report dialog
  static void showReportDialog({
    required BuildContext context,
    required String contentType,
    required String contentId,
    required String contentTitle,
    VoidCallback? onReportSubmitted,
  }) {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        contentType: contentType,
        contentId: contentId,
        contentTitle: contentTitle,
        onReportSubmitted: onReportSubmitted,
      ),
    );
  }
}

enum ReportType {
  inappropriate('Inappropriate Content'),
  spam('Spam'),
  harassment('Harassment'),
  violence('Violence'),
  nudity('Nudity/Sexual Content'),
  hateSpeech('Hate Speech'),
  misinformation('Misinformation'),
  copyright('Copyright Violation'),
  other('Other');

  const ReportType(this.displayName);
  final String displayName;
}

class AuthAlertBox {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Check if user is authenticated and show alert if not
  static Future<bool> checkAuthAndShowAlert({
    required BuildContext context,
    String? customMessage,
    String? authPageRoute,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      await _showAuthAlert(
        context: context,
        message: customMessage ?? "Please login to continue",
        authPageRoute: authPageRoute ?? '/auth',
      );
      return false;
    }

    return true;
  }

  /// Show the custom alert dialog
  static Future<void> _showAuthAlert({
    required BuildContext context,
    required String message,
    required String authPageRoute,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning,
                color: Colors.yellow,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    if (context.mounted) {
                      context.pushReplacementNamed(AuthPageWidget.routeName);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Background color
                    foregroundColor: Colors.yellow, // Text (and ripple) color
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(
                          color: Colors.yellow), // Border color
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow, // Explicitly set text color
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Widget wrapper that checks auth before showing content
  static Widget authWrapper({
    required BuildContext context,
    required Widget child,
    String? customMessage,
    String? authPageRoute,
  }) {
    return FutureBuilder<User?>(
      future: Future.value(_supabase.auth.currentUser),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          // User not authenticated, show placeholder or trigger alert
          return GestureDetector(
            onTap: () => checkAuthAndShowAlert(
              context: context,
              customMessage: customMessage,
              authPageRoute: authPageRoute,
            ),
            child: child,
          );
        }
        return child;
      },
    );
  }
}
