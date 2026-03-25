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
At Pocket Mates, your privacy is our top priority. This Privacy Policy describes how we collect, use, and protect your information globally.

1. Information Collection
• Account Information: We collect your name, email, profile picture, and bio to provide basic social features.
• Communication Data: For real-time communication (Audio/Video calls via WebRTC), data is transmitted peer-to-peer or via secured relay servers. We do not record or store your private calls.
• Content Data: We store messages, posts, and media you share in group chats or feeds to ensure they are available to authorized recipients.
• Device Data: We collect basic device info (OS version, device model) for troubleshooting and notification services.

2. Usage of Information
• Service Delivery: To enable chatting, calls, and networking features.
• Safety & Security: To monitor for fraudulent activity and enforce our community standards.
• Notifications: To alert you of new messages or call requests.

3. Data Sharing
We do not sell your data. We share only necessary information with:
• Supabase: Our core database and authentication provider.
• Firebase: For push notification services.

4. User Rights & Data Deletion
You have the right to access, correct, or delete your data at any time. You can use the "Delete Account" feature in the app settings to permanently remove your profile and all associated personal data from our active systems.

5. Content Moderation
We implement automated and manual reporting systems. Users can report any content or profile that violates our guidelines.
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
Welcome to Pocket Mates! By using our platform, you agree to the following terms.

1. User Conduct & Content (UGC)
Pocket Mates is a community-driven app. You are solely responsible for the content you post. 
• Zero Tolerance: There is NO tolerance for objectionable content or abusive users. This includes, but is not limited to, harassment, hate speech, explicit adult content, and illegal activities.
• Reporting: Users can report any objectionable content using the "Report" button.
• Blocking: Users can block any other user instantly. Blocked users will not be able to interact with you.

2. Moderation & Enforcement
We reserve the right to:
• Review and remove any content reported by the community.
• Suspend or permanently terminate accounts that violate these terms, without prior notice.

3. Call & Messaging Services
Our real-time communication tools (WebRTC) are provided as-is. You agree not to use these tools for unsolicited marketing or harassment.

4. Intellectual Property
You retain ownership of the content you post, but you grant Pocket Mates a non-exclusive license to host and display it within the app structure.

5. Limitation of Liability
Pocket Mates is not liable for damages resulting from user interactions or content posted by third parties.
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
These Terms govern your legal relationship with Pocket Mates.

1. Eligibility
You must be at least 13 years old (or the legal minimum age in your country) to use this service.

2. Account Security
You are responsible for maintaining the confidentiality of your account credentials.

3. Updates to Service
We may update the app and these terms occasionally. Your continued use after an update signifies your acceptance of the new terms.

4. Dispute Resolution
Any legal disputes will be governed by the laws of the jurisdiction where the company is registered.

5. Termination
Violating our community safety guidelines (UGC policy) is grounds for immediate account termination.
''',
    );
  }
}
