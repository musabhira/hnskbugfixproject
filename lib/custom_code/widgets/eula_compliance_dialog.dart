import 'package:flutter/material.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EulaComplianceDialog extends StatefulWidget {
  final VoidCallback onAccepted;

  const EulaComplianceDialog({super.key, required this.onAccepted});

  @override
  State<EulaComplianceDialog> createState() => _EulaComplianceDialogState();
}

class _EulaComplianceDialogState extends State<EulaComplianceDialog> {
  bool _isLoading = false;

  Future<void> _handleAccept() async {
    setState(() => _isLoading = true);
    try {
      final user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        // 1. Update Remote Profile Status
        await SupaFlow.client
            .from('profile')
            .update({'eula_accepted': true})
            .eq('user_id', user.id);

        // 2. Update Local Device Status
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('eula_accepted_${user.id}', true);

        widget.onAccepted();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving acceptance: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.security_rounded, color: Color(0xFFFFFC00), size: 28),
                const SizedBox(width: 12),
                Text(
                  'Community Safety (EULA)',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'To ensure a safe and positive experience for all users, you must agree to our End User License Agreement (EULA).',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ZERO TOLERANCE for objectionable content (nudity, violence, etc.)',
                            style: TextStyle(color: Color(0xFFFFFC00), fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• ZERO TOLERANCE for abusive users, harassment, or hate speech.',
                            style: TextStyle(color: Color(0xFFFFFC00), fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• Your content will be moderated. Violations may result in immediate account termination.',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'By continuing, you agree to these terms and our full Terms of Service.',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFFC00),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : const Text(
                        'I Agree & Continue',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => SupaFlow.client.auth.signOut(),
                child: const Text('Decline & Logout', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

