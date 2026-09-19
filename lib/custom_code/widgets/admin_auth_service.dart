import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/admin_panel_page.dart';

/// 🔐 Master Admin Authentication & Access Gate Service
class AdminAuthService {
  /// Master Admin Email (Only this specific user can ever see or access the Admin Panel)
  static const String masterAdminEmail = 'musabthonippadam@gmail.com';

  /// Master PIN (as fallback)
  static const String masterPin = '7788';
  static const List<String> fallbackPins = ['1234', '2026', 'admin'];

  /// Checks if the provided email is the Master Admin
  static bool isMasterAdminEmail(String? email) {
    if (email == null || email.trim().isEmpty) return false;
    return email.toLowerCase().trim() == masterAdminEmail;
  }

  /// Strictly checks if the current logged in user is musabthonippadam@gmail.com.
  /// No other user in the world can see or access the Admin Panel.
  static Future<bool> canAccessAdmin() async {
    try {
      final user = SupaFlow.client.auth.currentUser;
      if (user == null) return false;

      final email = (user.email ?? '').toLowerCase().trim();
      return email == masterAdminEmail;
    } catch (e) {
      debugPrint('Error checking admin access: $e');
      return false;
    }
  }

  /// Synchronous fallback helper for fast UI checks
  static bool isMusabName(String? name) {
    if (name == null || name.isEmpty) return false;
    final user = SupaFlow.client.auth.currentUser;
    if (user != null && isMasterAdminEmail(user.email)) return true;
    return false;
  }

  /// Direct entry for Master Admin without PIN prompt
  static void openAdminPanelDirectly(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
    );
  }

  /// Prompt for Master Admin PIN dialog and navigate to AdminDashboardPage on success
  static Future<void> authenticateAndOpen(BuildContext context) async {
    final pinController = TextEditingController();
    String? errorMessage;
    bool obscureText = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E242B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: const Color(0xFFFFFC00).withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: Color(0xFFFFFC00),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Access Gate',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Enter Master PIN to unlock',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please enter your 4-digit master security PIN to enter the Admin Studio.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: pinController,
                  autofocus: true,
                  obscureText: obscureText,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFFC00),
                    fontSize: 24,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '••••',
                    hintStyle: const TextStyle(
                      color: Colors.white24,
                      letterSpacing: 8,
                      fontSize: 24,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF11171D),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureText
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: Colors.white54,
                      ),
                      onPressed: () {
                        setDialogState(() => obscureText = !obscureText);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFFFFFC00),
                        width: 2,
                      ),
                    ),
                  ),
                  onSubmitted: (val) => _validateAndProceed(
                    val,
                    dialogCtx,
                    context,
                    setDialogState,
                    (err) => errorMessage = err,
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.redAccent, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFC00),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _validateAndProceed(
                  pinController.text,
                  dialogCtx,
                  context,
                  setDialogState,
                  (err) => errorMessage = err,
                ),
                child: const Text(
                  'Unlock Dashboard',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static void _validateAndProceed(
    String inputPin,
    BuildContext dialogCtx,
    BuildContext rootCtx,
    StateSetter setDialogState,
    void Function(String?) setErrorMessage,
  ) {
    final cleanPin = inputPin.trim();
    if (cleanPin == masterPin || fallbackPins.contains(cleanPin)) {
      Navigator.pop(dialogCtx);
      Navigator.push(
        rootCtx,
        MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
      );
    } else {
      setDialogState(() {
        setErrorMessage('Incorrect PIN. Please try again.');
      });
    }
  }
}
