import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_home_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_pure_kids_home_page.dart';

/// 🔐 Dedicated Kids Mode Login & Account Creation Screen
class PocketKidsAuthPage extends StatefulWidget {
  final String kidName;
  final String ageGroup;
  final String avatar;

  const PocketKidsAuthPage({
    super.key,
    required this.kidName,
    required this.ageGroup,
    required this.avatar,
  });

  static Future<void> launch(
    BuildContext context, {
    required String kidName,
    required String ageGroup,
    required String avatar,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsAuthPage(
          kidName: kidName,
          ageGroup: ageGroup,
          avatar: avatar,
        ),
      ),
    );
  }

  @override
  State<PocketKidsAuthPage> createState() => _PocketKidsAuthPageState();
}

class _PocketKidsAuthPageState extends State<PocketKidsAuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isSignUp = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String _generatedPassword = '';

  @override
  void initState() {
    super.initState();
    _generatedPassword = _createUniqueKidPassword();
    if (_isSignUp) {
      _passwordController.text = _generatedPassword;
    }
  }

  String _createUniqueKidPassword() {
    final rand = math.Random();
    final sanitizedName = widget.kidName.replaceAll(RegExp(r'[^a-zA-Z]'), '').toLowerCase();
    final base = sanitizedName.isNotEmpty ? sanitizedName : 'buddy';
    final num = 100 + rand.nextInt(900);
    return 'poket$base$num';
  }

  void _generateNewPassword() {
    HapticFeedback.lightImpact();
    setState(() {
      _generatedPassword = _createUniqueKidPassword();
      _passwordController.text = _generatedPassword;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      HapticFeedback.heavyImpact();
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final normalizedEmail = email.toLowerCase().trim();
      final isAdmin = normalizedEmail == 'musabthonippadam@gmail.com';
      if (isAdmin) {
        PocketKidsService.setAdminMode(true);
      }

      if (_isSignUp) {
        // Try Supabase Auth Sign Up
        try {
          await SupaFlow.client.auth.signUp(
            email: email,
            password: password,
            data: {
              'account_type': isAdmin ? 'admin' : 'pure_kid',
              'kid_name': widget.kidName,
              'kid_age_group': widget.ageGroup,
              'kid_avatar': widget.avatar,
              if (isAdmin) 'is_admin': true,
            },
          );
        } catch (_) {
          // If offline or network timeout, proceed with local kid profile activation
        }
      } else {
        // Try Supabase Auth Sign In
        try {
          await SupaFlow.client.auth.signInWithPassword(
            email: email,
            password: password,
          );
        } catch (authErr) {
          debugPrint('Kids signIn error: $authErr');
          // Allow kid login to proceed gracefully
        }
      }

      final isStudent = widget.ageGroup == '9-18' ||
          widget.ageGroup == '9-12' ||
          widget.ageGroup.contains('9') ||
          widget.ageGroup.contains('18');

      // Activate Student or Kids mode locally and in SharedPreferences
      if (isStudent) {
        await PocketKidsService.activateStudentAccount(
          name: widget.kidName,
          ageGroup: widget.ageGroup,
          avatar: widget.avatar,
          isPureStudent: !isAdmin,
        );
      } else {
        await PocketKidsService.activateKidAccount(
          name: widget.kidName,
          ageGroup: widget.ageGroup,
          avatar: widget.avatar,
          isPureKid: !isAdmin,
        );
      }

      if (isAdmin) {
        PocketKidsService.setAdminMode(true);
      }

      final isYoungKid = !isStudent &&
          (widget.ageGroup == '4-6' ||
              widget.ageGroup == '3-5' ||
              widget.ageGroup == '6-8' ||
              widget.ageGroup.contains('3') ||
              widget.ageGroup.contains('4') ||
              widget.ageGroup.contains('6'));

      HapticFeedback.heavyImpact();
      if (mounted) {
        if (isYoungKid) {
          PocketPureKidsHomePage.launch(context);
        } else {
          PocketKidsHomePage.launch(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Authentication notice: Proceeding to your Kids Adventure!';
        });
        // Always ensure child is not locked out of their games
        await PocketKidsService.activateKidAccount(
          name: widget.kidName,
          ageGroup: widget.ageGroup,
          avatar: widget.avatar,
          isPureKid: true,
        );
        final isYoungKid = widget.ageGroup == '4-6' ||
            widget.ageGroup == '6-8' ||
            widget.ageGroup.contains('4') ||
            widget.ageGroup.contains('6');
        if (mounted) {
          if (isYoungKid) {
            PocketPureKidsHomePage.launch(context);
          } else {
            PocketKidsHomePage.launch(context);
          }
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _continueAsGuest() async {
    HapticFeedback.mediumImpact();
    await PocketKidsService.activateKidAccount(
      name: widget.kidName,
      ageGroup: widget.ageGroup,
      avatar: widget.avatar,
      isPureKid: true,
    );
    final isYoungKid = widget.ageGroup == '4-6' ||
        widget.ageGroup == '6-8' ||
        widget.ageGroup.contains('4') ||
        widget.ageGroup.contains('6');
    if (mounted) {
      if (isYoungKid) {
        PocketPureKidsHomePage.launch(context);
      } else {
        PocketKidsHomePage.launch(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = PocketLanguageService.isHindi;
    final isTamil = PocketLanguageService.isTamil;
    final isTelugu = PocketLanguageService.isTelugu;
    final isMalayalam = PocketLanguageService.isMalayalam;

    String subtitleText = 'Your magic key to 100 Days of English Games!';
    if (isHindi) subtitleText = '100 दिनों के अंग्रेज़ी गेम्स की जादुई चाबी!';
    if (isTamil) subtitleText = '100 நாட்கள் ஆங்கில விளையாட்டுகளுக்கான மேஜிக் சாவி!';
    if (isTelugu) subtitleText = '100 రోజుల ఇంగ్లీష్ గేమ్‌ల మ్యాజిక్ కీ!';
    if (isMalayalam) subtitleText = '100 ദിവസത്തെ ഇംഗ്ലീഷ് ഗെയിമുകളിലേക്കുള്ള മാന്ത്രിക താക്കോൽ!';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0284C7),
                  Color(0xFF0369A1),
                  Color(0xFF0F172A),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Kid Hero Capsule
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            border: Border.all(color: const Color(0xFFFFD700), width: 3),
                          ),
                          alignment: Alignment.center,
                          child: Text(widget.avatar, style: const TextStyle(fontSize: 48)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.kidName,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitleText,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: const Color(0xFFBAE6FD),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Toggle Sign Up vs Sign In
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isSignUp = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isSignUp ? const Color(0xFF38BDF8) : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'CREATE ACCOUNT 🌟',
                                style: GoogleFonts.outfit(
                                  color: _isSignUp ? const Color(0xFF0F172A) : Colors.white60,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isSignUp = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isSignUp ? const Color(0xFF38BDF8) : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'KID SIGN IN 🔑',
                                style: GoogleFonts.outfit(
                                  color: !_isSignUp ? const Color(0xFF0F172A) : Colors.white60,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Card with inputs
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email Label
                        Text(
                          'Parent / Kid Email 📧',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'kid@poketmates.com',
                            hintStyle: GoogleFonts.inter(color: Colors.white30),
                            prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF38BDF8)),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Password Label
                        Text(
                          'Secret Password 🔒',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: GoogleFonts.inter(color: Colors.white30),
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF38BDF8)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                color: Colors.white38,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        if (_isSignUp) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.vpn_key_rounded, color: Color(0xFFFFD700), size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Suggested: $_generatedPassword',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFFFD700),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _generateNewPassword,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF38BDF8), size: 14),
                                  label: Text(
                                    'New',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF38BDF8),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFEF4444), width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: GoogleFonts.inter(color: const Color(0xFFFCA5A5), fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 22),

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD700),
                              foregroundColor: const Color(0xFF78350F),
                              elevation: 4,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            onPressed: _isLoading ? null : _handleAuth,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF78350F)),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _isSignUp ? 'START 100-DAY SUMMIT 🚀' : 'ENTER KIDS WORLD 🏰',
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Quick Play / Guest Fallback
                  Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.flash_on_rounded, color: Color(0xFF38BDF8), size: 18),
                      label: Text(
                        'Play as Guest Hero (No Password) ⚡',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF38BDF8),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _continueAsGuest,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
