import 'package:flutter/material.dart';
import 'package:pocket_mates_app/custom_code/widgets/profile_custom_widget.dart';

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
    return ProfileCustomWidget(
      width: width,
      height: height,
    );
  }
}
