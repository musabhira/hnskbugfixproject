import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewUserOnboardingDialog extends StatefulWidget {
  final VoidCallback? onCompleted;
  final VoidCallback? onStartCall;

  const NewUserOnboardingDialog({
    super.key,
    this.onCompleted,
    this.onStartCall,
  });

  static Future<void> checkAndShow(
    BuildContext context, {
    String? userId,
    VoidCallback? onStartCall,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = userId != null
          ? 'pm_onboarding_seen_$userId'
          : 'pm_onboarding_seen_global';
      final hasSeen = prefs.getBool(key) ?? false;
      if (!hasSeen && context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => NewUserOnboardingDialog(
            onCompleted: () async {
              await prefs.setBool(key, true);
            },
            onStartCall: onStartCall,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error showing onboarding: $e');
    }
  }

  @override
  State<NewUserOnboardingDialog> createState() =>
      _NewUserOnboardingDialogState();
}

class _NewUserOnboardingDialogState extends State<NewUserOnboardingDialog> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _onboardingPages = [
    {
      'icon': Icons.phone_in_talk_rounded,
      'badge': 'NEW • INSTANT MATCH',
      'title': 'Practice Spoken English Live',
      'desc':
          'Connect 1-on-1 with live peers and practice English fluency in real-time calls. Tap the glowing 📞 Call button in the top bar anytime!',
      'tag': 'Live Peer Calls',
    },
    {
      'icon': Icons.chat_bubble_outline_rounded,
      'badge': 'REAL-TIME CHAT',
      'title': 'Fast & Private Messaging',
      'desc':
          'Send messages, crystal-clear voice notes, photo stories, and connect with language mates across the globe.',
      'tag': 'Smart Inbox',
    },
    {
      'icon': Icons.dashboard_customize_rounded,
      'badge': 'ALL-IN-ONE SUITE',
      'title': 'Productivity & Daily Tools',
      'desc':
          'Explore our minimal Tools Suite: Poster Maker, Insta Saver, Daily Tasks, Habit Tracker, Games, and AI Accent Coach.',
      'tag': 'Tools Suite',
    },
  ];

  void _finishOnboarding([bool openCall = false]) {
    widget.onCompleted?.call();
    Navigator.of(context, rootNavigator: true).pop();
    if (openCall) {
      widget.onStartCall?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: const Color(0xFF0F131C),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFFFC00).withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFFC00).withValues(alpha: 0.12),
              blurRadius: 30,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Branding
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFFC00).withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFFC00).withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFFFFFC00),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Poket Mates',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Welcome to your learning community',
                            style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white54, size: 20),
                      onPressed: () => _finishOnboarding(false),
                    ),
                  ],
                ),
              ),

              // Page Content
              SizedBox(
                height: 240,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardingPages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final item = _onboardingPages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon Badge
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFC00)
                                  .withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFFFC00)
                                  .withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFFC00)
                                      .withValues(alpha: 0.15),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: const Color(0xFFFFFC00),
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Badge Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E2638),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFFFFC00)
                                    .withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              item['badge'] as String,
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFFC00),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Title
                          Text(
                            item['title'] as String,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Description
                          Text(
                            item['desc'] as String,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Page Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingPages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFFFFFC00)
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    // Primary Action
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage < _onboardingPages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _finishOnboarding(true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFC00),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          _currentPage == _onboardingPages.length - 1
                              ? 'Start Practice Call 📞'
                              : 'Next',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Secondary Skip / Dismiss
                    TextButton(
                      onPressed: () => _finishOnboarding(false),
                      child: Text(
                        'Explore App',
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
}
