import 'package:flutter/material.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_learning_track_service.dart';
import 'german_day_open_world_adventure_page.dart';

/// 🇩🇪 Dedicated German 90-Day Open World Wrapper
class GermanDayOpenWorldPage extends StatefulWidget {
  final int day;
  final String? userId;
  final VoidCallback? onCompleted;

  const GermanDayOpenWorldPage({
    super.key,
    required this.day,
    this.userId,
    this.onCompleted,
  });

  @override
  State<GermanDayOpenWorldPage> createState() => _GermanDayOpenWorldPageState();
}

class _GermanDayOpenWorldPageState extends State<GermanDayOpenWorldPage> {
  @override
  void initState() {
    super.initState();
    PocketLearningTrackService.setTrack(
      PocketLearningTrackService.trackGerman,
      userId: widget.userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GermanDayOpenWorldAdventurePage(
      day: widget.day,
      userId: widget.userId,
      onCompleted: widget.onCompleted,
    );
  }
}
