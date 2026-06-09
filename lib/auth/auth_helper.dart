import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/index.dart';

class AuthHelper {
  static bool checkLoggedIn(BuildContext context) {
    if (loggedIn) {
      return true;
    }

    showLoginAlert(context);
    return false;
  }

  static void showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text(
          'You need to be logged in to access this feature. Would you like to login or sign up now?',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Login / Sign Up'),
            onPressed: () {
              Navigator.pop(context);
              context.goNamed(AuthPageWidget.routeName);
            },
          ),
        ],
      ),
    );
  }
}
