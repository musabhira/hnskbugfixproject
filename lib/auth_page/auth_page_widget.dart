import 'package:flutter/material.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_home_page.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && PocketKidsService.isKidAccount) {
        debugPrint('AuthPage: Kid account active. Redirecting to PocketKidsHomePage.');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PocketKidsHomePage()),
        );
      } else if (mounted && loggedIn) {
        debugPrint(
            'AuthPage: User is already logged in. Redirecting to HomePage.');
        context.goNamed(HomePageWidget.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (PocketKidsService.isKidAccount) {
      return const PocketKidsHomePage();
    }
    if (loggedIn) {
      return const Scaffold(backgroundColor: Colors.black);
    }

    return const WelcomeOnboardingPage();
  }
}
