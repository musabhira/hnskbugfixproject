// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import '/pages/home_page/home_page_widget.dart';
import '/auth_page/auth_page_widget.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!

class AutoLoginBottomSheet extends StatefulWidget {
  final double? width;
  final double? height;
  const AutoLoginBottomSheet({
    super.key,
    this.width,
    this.height,
  });

  // Static method to show the bottom sheet from anywhere
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AutoLoginBottomSheet(),
    );
  }

  @override
  State<AutoLoginBottomSheet> createState() => _AutoLoginBottomSheetState();
}

class _AutoLoginBottomSheetState extends State<AutoLoginBottomSheet> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> autoLoginUsers = [];
  bool isLoading = true;
  bool showAuth = false;
  bool isCreatingAccount = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAutoLoginUsers();
  }

  Future<void> _loadAutoLoginUsers() async {
    try {
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) return;

      // Query auto_login table filtered by parent_user_id (current user)
      // This will show all sub-accounts linked to the current main account
      // Use the specific foreign key relationship for user_id -> users table
      final response = await supabase.from('auto_login').select('''
            id,
            created_at,
            user_id,
            parent_user_id,
            users!auto_login_user_id_fkey(
              id,
              email,
              password,
              profile!inner(name, profile_image_url)
            )
          ''').eq('parent_user_id', currentUserId);

      safeSetState(() {
        autoLoginUsers = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      safeSetState(() {
        debugPrint(e.toString());
        isLoading = false;
      });
      _showError('Failed to load accounts: $e');
    }
  }

  Future<void> _quickLogin(Map<String, dynamic> userData) async {
    try {
      GoRouter.of(context).prepareAuthEvent();
      // First logout current user
      await supabase.auth.signOut();
      if (!mounted) return;
      GoRouter.of(context).clearRedirectLocation();

      // Login with stored credentials
      final userInfo = userData['users'];
      final email = userInfo['email'];
      final password = userInfo['password'];

      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close bottom sheet
      Navigator.of(context).pop();
      // Navigate to home page
      context.pushReplacementNamed(
        HomePageWidget.routeName,
      );
    } catch (e) {
      print(e);
      _showError('Login failed: $e');
    }
  }

  Future<void> _deleteAutoLogin(String autoLoginId) async {
    try {
      await supabase.from('auto_login').delete().eq('id', autoLoginId);
      _loadAutoLoginUsers(); // Refresh list
      _showSuccess('Account removed from quick login');
    } catch (e) {
      _showError('Failed to remove account: $e');
    }
  }

  Future<void> _createAccount() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    try {
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        _showError('No parent user found');
        return;
      }

      // Create user account
      final response = await supabase.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
      );

      if (response.user != null) {
        // Add to users table
        await supabase.from('users').insert({
          // 'id': response.user!.id,
          'email': emailController.text,
          'password': passwordController
              .text, // Note: In production, never store plain passwords
        });

        // Create profile
        // await supabase.from('profile').insert({
        //   'user_id': response.user!.id,
        //   'name': emailController.text.split('@')[0],
        //   'profile_image_url': 'https://via.placeholder.com/150',
        // });

        // Add to auto_login table with parent_user_id
        await supabase.from('auto_login').insert({
          'user_id': response.user!.id,
          'parent_user_id': currentUserId, // Link to current main account
        });

        if (!mounted) return;
        emailController.clear();
        passwordController.clear();
        Navigator.of(context).pop(); // Close bottom sheet
        Navigator.of(context).pop();
        // Navigate to home page
        context.pushReplacementNamed(
          HomePageWidget.routeName,
        );
        safeSetState(() {
          showAuth = false;
          isCreatingAccount = false;
        });
        _showSuccess('Sub-account created and linked successfully!');
        _loadAutoLoginUsers(); // Refresh the list
      }
    } catch (e) {
      _showError('Failed to create account: $e');
    }
  }

  Future<void> _loginAccount() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    try {
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        _showError('No parent user found');
        return;
      }

      // Temporarily sign out to login with new credentials
      // Temporarily sign out to login with new credentials
      await supabase.auth.signOut();

      final response = await supabase.auth.signInWithPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (response.user != null) {
        // Check if user exists in auto_login table
        final existingAutoLogin = await supabase
            .from('auto_login')
            .select()
            .eq('user_id', response.user!.id)
            .eq('parent_user_id', currentUserId);

        if (existingAutoLogin.isEmpty) {
          // Insert new auto_login entry with parent_user_id
          await supabase.from('auto_login').insert({
            'user_id': response.user!.id,
            'parent_user_id': currentUserId, // Link to the parent account
          });
        } else {
          // Update existing auto_login entry
          await supabase
              .from('auto_login')
              .update({'created_at': DateTime.now().toIso8601String()})
              .eq('user_id', response.user!.id)
              .eq('parent_user_id', currentUserId);
        }

        emailController.clear();
        passwordController.clear();
        safeSetState(() {
          showAuth = false;
        });

        if (!mounted) return;
        Navigator.of(context).pop(); // Close bottom sheet
        Navigator.of(context).pop();
        // Navigate to home page
        context.pushReplacementNamed(
          HomePageWidget.routeName,
        );
        _showSuccess('Sub-account linked successfully!');
      }
    } catch (e) {
      debugPrint(e.toString());
      _showError('Login failed: $e');
    }
  }

  Future<void> _logout() async {
    try {
      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      
      GoRouter.of(context).prepareAuthEvent();
      await supabase.auth.signOut();
      
      if (!mounted) return;
      GoRouter.of(context).clearRedirectLocation();
      context.pushReplacementNamed(
        AuthPageWidget.routeName,
      );

      context.goNamedAuth(AuthPageWidget.routeName, context.mounted);

      // Navigator.of(context).pop();
      // Navigator.of(context).pushReplacementNamed('/auth');
    } catch (e) {
      _showError('Logout failed: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 10),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.account_circle,
                  color: Colors.amber,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Login Accounts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Sub-accounts linked to your main account',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          if (showAuth) ...[
            // Auth Form
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      isCreatingAccount
                          ? 'Create Sub-Account'
                          : 'Link Existing Account',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isCreatingAccount
                          ? 'Create a new account that will be linked to your main account'
                          : 'Link an existing account to your main account for quick access',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // Email field
                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.amber),
                        prefixIcon:
                            const Icon(Icons.email, color: Colors.amber),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.amber),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.amber, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password field
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.amber),
                        prefixIcon: const Icon(Icons.lock, color: Colors.amber),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.amber),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.amber, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Action button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            isCreatingAccount ? _createAccount : _loginAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isCreatingAccount
                              ? 'Create Sub-Account'
                              : 'Link Account',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Switch mode button
                    TextButton(
                      onPressed: () {
                        safeSetState(() {
                          isCreatingAccount = !isCreatingAccount;
                        });
                      },
                      child: Text(
                        isCreatingAccount
                            ? 'Already have an account? Link it'
                            : 'Don\'t have an account? Create a new one',
                        style: const TextStyle(color: Colors.amber),
                      ),
                    ),

                    // Back button
                    TextButton(
                      onPressed: () {
                        safeSetState(() {
                          showAuth = false;
                        });
                      },
                      child: const Text(
                        'Back to accounts',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Accounts List
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    )
                  : autoLoginUsers.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.account_box_outlined,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'No Sub-Accounts Found',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Create or link sub-accounts to quickly switch between them',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: autoLoginUsers.length,
                          itemBuilder: (context, index) {
                            final user = autoLoginUsers[index];
                            final userInfo =
                                user['users'] as Map<String, dynamic>?;

                            // Handle profiles as a list (since it might return multiple profiles)
                            final profilesList =
                                userInfo?['profile'] as List<dynamic>?;
                            final profile = profilesList?.isNotEmpty == true
                                ? profilesList!.first as Map<String, dynamic>?
                                : null;

                            // Safely extract data with type casting
                            final profileImageUrl =
                                profile?['profile_image_url']?.toString();
                            final profileName =
                                profile?['name']?.toString() ?? 'Unknown';
                            final userEmail =
                                userInfo?['email']?.toString() ?? 'No email';
                            final userId = user['id']?.toString();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                color: Colors.grey[850]?.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: Colors.amber.withValues(alpha: 0.3)),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(15),
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.amber,
                                  backgroundImage: (profileImageUrl != null &&
                                          profileImageUrl.isNotEmpty)
                                      ? NetworkImage(profileImageUrl)
                                      : null,
                                  child: (profileImageUrl == null ||
                                          profileImageUrl.isEmpty)
                                      ? const Icon(Icons.person,
                                          color: Colors.black)
                                      : null,
                                ),
                                title: Text(
                                  profileName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userEmail,
                                      style: TextStyle(color: Colors.grey[400]),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.link,
                                          size: 12,
                                          color: Colors.amber.withValues(alpha: 0.7),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Sub-account',
                                          style: TextStyle(
                                            color:
                                                Colors.amber.withValues(alpha: 0.7),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: const Icon(
                                  Icons.login,
                                  color: Colors.amber,
                                ),
                                onTap: () => _quickLogin(user),
                                onLongPress: () {
                                  if (userId == null) return;

                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Colors.grey[900],
                                      title: const Text(
                                        'Remove Sub-Account',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      content: Text(
                                        'Remove "$profileName" from quick login?\n\nThis will only unlink the account, not delete it.',
                                        style:
                                            TextStyle(color: Colors.grey[300]),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text(
                                            'Cancel',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteAutoLogin(userId);
                                          },
                                          child: const Text(
                                            'Remove',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Manage accounts button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        safeSetState(() {
                          showAuth = true;
                          isCreatingAccount = false;
                        });
                      },
                      icon: const Icon(Icons.add_circle, color: Colors.black),
                      label: const Text(
                        'Add Sub-Account',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
