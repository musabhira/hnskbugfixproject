import 'package:flutter/material.dart';
import 'package:pocket_mates_app/custom_code/widgets/profile_setup_onboarding_page.dart';

class ProfileCreateCustomWidget extends StatelessWidget {
  final double width;
  final double height;
  static const String routeName = 'ProfileCreate';
  static const String routePath = '/profile_create';

  const ProfileCreateCustomWidget({
    super.key,
    this.width = double.infinity,
    this.height = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileSetupOnboardingPage(
      width: width,
      height: height,
    );
  }
}
