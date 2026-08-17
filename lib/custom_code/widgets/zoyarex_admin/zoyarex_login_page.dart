import 'package:flutter/material.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_dashboard_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_superadmin_dashboard_page.dart';
import '/backend/supabase/supabase.dart';

class ZoyarexLoginPage extends StatefulWidget {
  const ZoyarexLoginPage({Key? key}) : super(key: key);

  @override
  _ZoyarexLoginPageState createState() => _ZoyarexLoginPageState();
}

class _ZoyarexLoginPageState extends State<ZoyarexLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSavedCredentials();
  }

  Future<void> _checkSavedCredentials() async {
    final userId = SupaFlow.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      final res = await SupaFlow.client
          .from('zoyarex_credentials')
          .select('email, password')
          .eq('user_id', userId)
          .maybeSingle();

      if (res != null) {
        final email = res['email'];
        final password = res['password'];
        
        final response = await ZoyarexSupabase.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.session != null && mounted) {
          final isSuperAdmin = email.toString().toLowerCase() == 'superadmin@vaasits.com';
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => isSuperAdmin 
                  ? const ZoyarexSuperadminDashboardPage() 
                  : const ZoyarexDashboardPage(),
            ),
          );
          return; // Don't turn off loading
        }
      }
    } catch (e) {
      debugPrint('Error auto-logging in: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text;
      
      final response = await ZoyarexSupabase.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        // Save to Pocket Mates Supabase
        final userId = SupaFlow.client.auth.currentUser?.id;
        if (userId != null) {
          await SupaFlow.client.from('zoyarex_credentials').upsert({
            'user_id': userId,
            'email': email,
            'password': password,
            'updated_at': DateTime.now().toIso8601String(),
          });
        }

        if (mounted) {
          final isSuperAdmin = email == 'superadmin@vaasits.com';
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => isSuperAdmin 
                  ? const ZoyarexSuperadminDashboardPage() 
                  : const ZoyarexDashboardPage(),
            ),
          );
        }
        return; // Don't turn off loading indicator
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: ${e.toString()}')),
        );
      }
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zoyarex POS Admin Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  size: 80,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Zoyarex Admin Console',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Login',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
