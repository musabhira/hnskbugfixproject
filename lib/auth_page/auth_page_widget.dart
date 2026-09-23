import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:pocket_mates_app/custom_code/widgets/legal_policy_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/welcome_onboarding_page.dart';
export 'auth_page_model.dart';

/// 🌟 Duolingo-Style Social & Email Authentication Page
///
/// Features:
/// 1. Top 1-Tap Social Logins:
///    - Continue with Google (Clean white surface, Google brand icon)
///    - Continue with Facebook (Meta official blue '#1877F2')
///    - Sign in with Apple (Prepared for activation once Apple Developer account is renewed)
/// 2. Clean Segmented "OR WITH EMAIL" Divider
/// 3. Email & Password Sign In / Sign Up tabs
/// 4. Forgot password & Terms of Service confirmation
/// 5. Continue as Guest button for instant preview
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
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  String? _errorMessage;

  // Toggle this to true once Apple Developer account is renewed and configured in Supabase
  static const bool kEnableAppleSignIn = false;

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

  // --- Supabase OAuth: Google Sign-In ---
  Future<void> _handleGoogleSignIn() async {
    safeSetState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      GoRouter.of(context).prepareAuthEvent();
      await SupaFlow.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb
            ? null
            : 'pocketmatesapp://pocketmatesapp.com/auth-callback',
      );
    } on AuthException catch (e) {
      if (mounted) safeSetState(() => _errorMessage = e.message);
    } catch (e) {
      if (mounted) {
        safeSetState(() => _errorMessage =
            'Google Sign-In failed: $e. Please verify Supabase Google Provider setup.');
      }
    } finally {
      if (mounted) safeSetState(() => _isLoading = false);
    }
  }

  // --- Supabase OAuth: Apple Sign-In ---
  Future<void> _handleAppleSignIn() async {
    safeSetState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      GoRouter.of(context).prepareAuthEvent();
      await SupaFlow.client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: kIsWeb
            ? null
            : 'pocketmatesapp://pocketmatesapp.com/auth-callback',
      );
    } on AuthException catch (e) {
      if (mounted) safeSetState(() => _errorMessage = e.message);
    } catch (e) {
      if (mounted) {
        safeSetState(() => _errorMessage =
            'Apple Sign-In failed: $e. Please verify Supabase Apple Provider setup.');
      }
    } finally {
      if (mounted) safeSetState(() => _isLoading = false);
    }
  }

  // --- Traditional Email & Password Sign In ---
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
        safeSetState(
            () => _errorMessage = 'Sign in failed. Please verify your credentials.');
      }
    } finally {
      if (mounted) {
        safeSetState(() => _isLoading = false);
      }
    }
  }

  // --- Traditional Email & Password Sign Up ---
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      safeSetState(() =>
          _errorMessage = 'Please agree to the Terms of Service & Privacy Policy.');
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
        try {
          final emailPrefix = _emailController.text.trim().split('@').first;
          final displayName =
              emailPrefix.isNotEmpty ? emailPrefix : 'Poket Mate';
          final cleanSlug =
              displayName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

          await SupaFlow.client.from('users').upsert({
            'id': user.uid,
            'email': _emailController.text.trim(),
          }, onConflict: 'id');

          await SupaFlow.client.from('profile').upsert({
            'id': user.uid,
            'user_id': user.uid,
            'name': displayName,
            'shop_name': displayName.toLowerCase().replaceAll(' ', '-'),
            'slug': cleanSlug.isNotEmpty
                ? cleanSlug
                : 'mate${DateTime.now().millisecondsSinceEpoch % 10000}',
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
          context.goNamedAuth(
              ProfileCreateCustomWidget.routeName, context.mounted);
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
    final resetEmailController =
        TextEditingController(text: _emailController.text.trim());
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF18181B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Password',
          style: GoogleFonts.inter(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your email address and we will send you a password reset link.',
              style: GoogleFonts.inter(
                  color: const Color(0xFFA1A1AA), fontSize: 13),
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
                  borderSide:
                      const BorderSide(color: Color(0xFFFACC15), width: 1.5),
                ),
                prefixIcon: const Icon(Icons.mail_outline_rounded,
                    color: Color(0xFFA1A1AA), size: 20),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: const Color(0xFFA1A1AA))),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFACC15),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) return;
              Navigator.pop(dialogCtx);
              try {
                await authManager.resetPassword(email: email, context: context);
              } catch (_) {}
            },
            child: Text('Send Link',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
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

    return const WelcomeOnboardingPage();
  }

  // ==========================================
  // 🌟 DUOLINGO-STYLE SOCIAL BUTTONS WIDGET
  // ==========================================
  Widget _buildSocialButtons() {
    return Column(
      children: [
        // Continue with Google Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleGoogleSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFE4E4E7), width: 1.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(
                  FontAwesomeIcons.google,
                  color: Color(0xFFEA4335),
                  size: 19,
                ),
                const SizedBox(width: 12),
                Text(
                  'Continue with Google',
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),


        // Sign in with Apple (Shown if enabled)
        if (kEnableAppleSignIn) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleAppleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF18181B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFF3F3F46), width: 1.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.apple,
                    color: Colors.white,
                    size: 21,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Sign in with Apple',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 22),

        // Divider: OR WITH EMAIL
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFF27272A))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Text(
                'OR WITH EMAIL',
                style: GoogleFonts.inter(
                  color: const Color(0xFF71717A),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFF27272A))),
          ],
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
