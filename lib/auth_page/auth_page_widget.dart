import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:pocket_mates_app/custom_code/widgets/legal_policy_widget.dart';
export 'auth_page_model.dart';

class AuthPageWidget extends StatefulWidget {
  const AuthPageWidget({super.key});

  static String routeName = 'Auth_page';
  static String routePath = '/authPage';

  @override
  State<AuthPageWidget> createState() => _AuthPageWidgetState();
}

class _AuthPageWidgetState extends State<AuthPageWidget> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && loggedIn) {
        debugPrint('AuthPage: User is already logged in. Redirecting to HomePage.');
        context.goNamed(HomePageWidget.routeName);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    safeSetState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      GoRouter.of(context).prepareAuthEvent();
      final user = await authManager.signInWithEmail(
        context,
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null && mounted) {
        context.goNamedAuth(HomePageWidget.routeName, context.mounted);
      }
    } on AuthException catch (e) {
      if (mounted) {
        safeSetState(() => _errorMessage = e.message);
      }
    } catch (e) {
      if (mounted) {
        safeSetState(() => _errorMessage = 'Sign in failed. Please verify your credentials.');
      }
    } finally {
      if (mounted) {
        safeSetState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      safeSetState(() => _errorMessage = 'Please agree to the Terms of Service & Privacy Policy.');
      return;
    }

    safeSetState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      GoRouter.of(context).prepareAuthEvent();
      final user = await authManager.createAccountWithEmail(
        context,
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null && mounted) {
        // Automatically initialize default profile record to guarantee instant profile hydration
        try {
          final emailPrefix = _emailController.text.trim().split('@').first;
          final displayName = emailPrefix.isNotEmpty ? emailPrefix : 'Pocket Mate';
          final cleanSlug = displayName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
          await SupaFlow.client.from('profile').upsert({
            'user_id': user.uid,
            'name': displayName,
            'shop_name': displayName.toLowerCase().replaceAll(' ', '-'),
            'slug': cleanSlug.isNotEmpty ? cleanSlug : 'mate${DateTime.now().millisecondsSinceEpoch % 10000}',
            'learning_day': 1,
            'learning_stage': 1,
            'learning_points': 0,
            'xp': 0,
            'native_language': 'Malayalam',
            'english_level': 'Beginner (A1-A2)',
            'learning_goal': 'Daily Fluency & Speaking',
          }, onConflict: 'user_id');
        } catch (profileInitError) {
          debugPrint('Profile initialization error (non-fatal): $profileInitError');
        }

        if (mounted) {
          context.goNamedAuth(HomePageWidget.routeName, context.mounted);
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        safeSetState(() => _errorMessage = e.message);
      }
    } catch (e) {
      if (mounted) {
        safeSetState(() => _errorMessage = 'Account creation failed: $e');
      }
    } finally {
      if (mounted) {
        safeSetState(() => _isLoading = false);
      }
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text.trim());
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF18181B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Password',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your email address and we will send you a password reset link.',
              style: GoogleFonts.inter(color: const Color(0xFFA1A1AA), fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'name@example.com',
                hintStyle: GoogleFonts.inter(color: const Color(0xFF71717A)),
                filled: true,
                fillColor: const Color(0xFF121214),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF27272A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFACC15), width: 1.5),
                ),
                prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFFA1A1AA), size: 20),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: GoogleFonts.inter(color: const Color(0xFFA1A1AA))),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFACC15),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) return;
              Navigator.pop(dialogCtx);
              try {
                await authManager.resetPassword(email: email, context: context);
              } catch (_) {}
            },
            child: Text('Send Link', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loggedIn) {
      return const Scaffold(backgroundColor: Colors.black);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    // App Logo & Header
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E1E1E),
                          border: Border.all(color: const Color(0xFFFACC15).withValues(alpha: 0.4), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFACC15).withValues(alpha: 0.15),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          color: Color(0xFFFACC15),
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'PoketMates',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your smart AI companions & personal space',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFA1A1AA),
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Clean Segmented Pill Mode Switcher
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF18181B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF27272A)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (_isSignUp) {
                                  safeSetState(() {
                                    _isSignUp = false;
                                    _errorMessage = null;
                                  });
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !_isSignUp ? const Color(0xFFFACC15) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Sign In',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    color: !_isSignUp ? Colors.black : const Color(0xFFA1A1AA),
                                    fontWeight: !_isSignUp ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (!_isSignUp) {
                                  safeSetState(() {
                                    _isSignUp = true;
                                    _errorMessage = null;
                                  });
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _isSignUp ? const Color(0xFFFACC15) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Sign Up',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    color: _isSignUp ? Colors.black : const Color(0xFFA1A1AA),
                                    fontWeight: _isSignUp ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Error Notification Banner
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7F1D1D).withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Color(0xFFF87171), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.inter(color: const Color(0xFFFECACA), fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email Field
                    Text(
                      'Email Address',
                      style: GoogleFonts.inter(color: const Color(0xFFE4E4E7), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
                      cursorColor: const Color(0xFFFACC15),
                      decoration: InputDecoration(
                        hintText: 'name@example.com',
                        hintStyle: GoogleFonts.inter(color: const Color(0xFF71717A)),
                        filled: true,
                        fillColor: const Color(0xFF141416),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFFA1A1AA), size: 20),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF27272A), width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFFACC15), width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Email is required';
                        if (!val.contains('@') || !val.contains('.')) return 'Enter a valid email address';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    Text(
                      'Password',
                      style: GoogleFonts.inter(color: const Color(0xFFE4E4E7), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
                      cursorColor: const Color(0xFFFACC15),
                      decoration: InputDecoration(
                        hintText: 'Enter password',
                        hintStyle: GoogleFonts.inter(color: const Color(0xFF71717A)),
                        filled: true,
                        fillColor: const Color(0xFF141416),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFFA1A1AA), size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: const Color(0xFFA1A1AA),
                            size: 20,
                          ),
                          onPressed: () => safeSetState(() => _obscurePassword = !_obscurePassword),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF27272A), width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFFACC15), width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Password is required';
                        if (_isSignUp && val.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),

                    // Confirm Password Field (Sign Up Only)
                    if (_isSignUp) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Confirm Password',
                        style: GoogleFonts.inter(color: const Color(0xFFE4E4E7), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocus,
                        obscureText: _obscureConfirmPassword,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
                        cursorColor: const Color(0xFFFACC15),
                        decoration: InputDecoration(
                          hintText: 'Re-enter password',
                          hintStyle: GoogleFonts.inter(color: const Color(0xFF71717A)),
                          filled: true,
                          fillColor: const Color(0xFF141416),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          prefixIcon: const Icon(Icons.lock_reset_rounded, color: Color(0xFFA1A1AA), size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: const Color(0xFFA1A1AA),
                              size: 20,
                            ),
                            onPressed: () => safeSetState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF27272A), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFFFACC15), width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                          ),
                        ),
                        validator: (val) {
                          if (val != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      // Terms and Privacy Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _agreedToTerms,
                              activeColor: const Color(0xFFFACC15),
                              checkColor: Colors.black,
                              side: const BorderSide(color: Color(0xFF52525B)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) => safeSetState(() => _agreedToTerms = val ?? false),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text('I agree to the ', style: GoogleFonts.inter(color: const Color(0xFFA1A1AA), fontSize: 12.5)),
                                InkWell(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const TermsOfServicePage()),
                                  ),
                                  child: Text(
                                    'Terms of Service',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFFFACC15),
                                      fontSize: 12.5,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                Text(' and ', style: GoogleFonts.inter(color: const Color(0xFFA1A1AA), fontSize: 12.5)),
                                InkWell(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
                                  ),
                                  child: Text(
                                    'Privacy Policy',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFFFACC15),
                                      fontSize: 12.5,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Forgot Password Link (Sign In Only)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 4)),
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFACC15),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Primary Submit Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : (_isSignUp ? _handleSignUp : _handleSignIn),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFACC15),
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: const Color(0xFFFACC15).withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                              )
                            : Text(
                                _isSignUp ? 'Create Account' : 'Sign In',
                                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Color(0xFF27272A))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text('OR', style: GoogleFonts.inter(color: const Color(0xFF71717A), fontSize: 12)),
                        ),
                        const Expanded(child: Divider(color: Color(0xFF27272A))),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Continue as Guest Button
                    OutlinedButton(
                      onPressed: () => context.goNamed(HomePageWidget.routeName),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF27272A), width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Continue as Guest', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFFFACC15)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
