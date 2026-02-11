import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';

class LegalPolicyWidget extends StatelessWidget {
  final String title;
  final String content;

  const LegalPolicyWidget({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 0.5,
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: February 2026',
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              content,
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                '© 2026 Pocket Mates. All rights reserved.',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LegalPolicyWidget(
      title: 'Privacy Policy',
      content: '''
At Pocket Mates, we take your privacy seriously. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.

1. Information We Collect
We collect information that you provide directly to us, such as when you create an account, update your profile, or communicate with us. This may include your name, email address, phone number, and profile picture.

2. How We Use Your Information
We use the information we collect to:
- Provide and maintain our services
- Personalize your experience
- Communicate with you about updates and promotions
- Monitor and analyze usage and trends
- Protect the security and integrity of our platform

3. Sharing of Information
We do not sell your personal information to third parties. We may share information with service providers who perform services for us, or when required by law.

4. Data Security
We implement reasonable security measures to protect your information. However, no method of transmission over the internet is 100% secure.

5. Your Choices
You can update your account information at any time through the app settings. You can also request to delete your account, which will permanently remove your data from our systems.
''',
    );
  }
}

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LegalPolicyWidget(
      title: 'Terms of Service',
      content: '''
Welcome to Pocket Mates! By using our application, you agree to these Terms of Service.

1. Acceptance of Terms
By accessing or using our services, you agree to be bound by these terms. If you do not agree, please do not use the app.

2. User Content
You are responsible for any content you post on Pocket Mates. You must not post content that is illegal, offensive, or violates the rights of others.

3. Prohibited Activities
You agree not to engage in any activity that interferes with or disrupts the operation of our services.

4. Termination
We reserve the right to suspend or terminate your account at our discretion, without notice, for conduct that violates these terms.

5. Limitation of Liability
Pocket Mates is provided "as is" without warranties of any kind. We are not liable for any direct or indirect damages arising from your use of the app.
''',
    );
  }
}

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LegalPolicyWidget(
      title: 'Terms & Conditions',
      content: '''
These Terms & Conditions govern your use of the Pocket Mates platform.

1. License to Use
We grant you a personal, non-exclusive license to use the app for personal, non-commercial purposes.

2. Intellectual Property
All content and materials on Pocket Mates are the property of Pocket Mates or its licensors and are protected by intellectual property laws.

3. Privacy
Your use of the app is also governed by our Privacy Policy.

4. Changes to Terms
We may update these terms from time to time. Your continued use of the app after changes are posted constitutes acceptance of the new terms.
''',
    );
  }
}