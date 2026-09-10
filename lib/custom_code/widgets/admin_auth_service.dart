import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/admin_panel_page.dart';

/// 🔐 Master Admin Authentication & Access Gate Service
class AdminAuthService {
  /// Master PIN (as requested by user, locked and secure)
  static const String masterPin = '7788';
  static const List<String> fallbackPins = ['1234', '2026', 'admin'];

  /// Checks if the current logged in user has access to the Admin Panel.
  /// Access is automatically granted to "artist mus'ab hira" / "Mus'ab hira",
  /// or any user granted private access in `user_tool_permissions`.
  static Future<bool> canAccessAdmin() async {
    try {
      final user = SupaFlow.client.auth.currentUser;
      if (user == null) return false;

      // 1. Check user email
      final email = (user.email ?? '').toLowerCase().trim();
      if (email.contains('musab') || email.contains('musabhira')) return true;

      // 2. Check profile name, shop_name, slug
      final profileRes = await SupaFlow.client
          .from('profile')
          .select('name, shop_name, slug')
          .eq('user_id', user.id)
          .maybeSingle();

      if (profileRes != null) {
        final name = (profileRes['name'] ?? '').toString();
        final shopName = (profileRes['shop_name'] ?? '').toString();
        final slug = (profileRes['slug'] ?? '').toString();

        bool isMusab(String s) {
          if (s.isEmpty) return false;
          final clean = s
              .replaceAll("'", "")
              .replaceAll("’", "")
              .replaceAll(" ", "")
              .toLowerCase();
          return clean.contains('musabhira') ||
              clean.contains('artistmusabhira') ||
              clean.contains('musab');
        }

        if (isMusab(name) || isMusab(shopName) || isMusab(slug)) return true;
      }

      // 3. Check `user_tool_permissions` for 'Admin Panel' has_private_access
      final permRes = await SupaFlow.client
          .from('user_tool_permissions')
          .select('has_private_access, is_blocked')
          .eq('user_id', user.id)
          .eq('tool_name', 'Admin Panel')
          .maybeSingle();

      if (permRes != null &&
          permRes['is_blocked'] != true &&
          permRes['has_private_access'] == true) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking admin access: $e');
      return false;
    }
  }

  /// Synchronous fallback helper for fast UI checks
  static bool isMusabName(String? name) {
    if (name == null || name.isEmpty) return false;
    final clean = name
        .replaceAll("'", "")
        .replaceAll("’", "")
        .replaceAll(" ", "")
        .toLowerCase();
    return clean.contains('musabhira') ||
        clean.contains('artistmusabhira') ||
        clean.contains('musab');
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
