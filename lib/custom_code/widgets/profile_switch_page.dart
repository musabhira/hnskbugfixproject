import 'package:flutter/material.dart';
import 'package:pocket_mates_app/custom_code/widgets/main_profile_widget.dart';

class ProfileSwitchPage extends StatelessWidget {
  final double width;
  final double height;
  final Map<String, dynamic>? preloadedProfile;
  final String? followersCount;
  final String? followingCount;
  final List<Map<String, dynamic>>? userThreads;

  const ProfileSwitchPage({
    super.key,
    required this.width,
    required this.height,
    this.preloadedProfile,
    this.followersCount,
    this.followingCount,
    this.userThreads,
  });

  @override
  Widget build(BuildContext context) {
    return MainProfileWidget(
      width: width,
      height: height,
      preloadedProfile: preloadedProfile,
      followersCount: followersCount,
      followingCount: followingCount,
      userThreads: userThreads,
    );
  }
}
