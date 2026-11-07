import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/custom_code/widgets/kids/pocket_pure_kids_home_page.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/pocket_homes_reels_feed_widget.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  static String routeName = 'HomePage';
  static String routePath = '/homePage';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;
  final PageController _homeHorizontalPageController = PageController(initialPage: 0);

  void _onModeChanged() {
    if (mounted) {
      safeSetState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    PocketGameAudioService.instance.stop();
    _model = createModel(context, () => HomePageModel());

    PocketKidsService.isKidAccountNotifier.addListener(_onModeChanged);
    PocketKidsService.currentWorldModeNotifier.addListener(_onModeChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _homeHorizontalPageController.dispose();
    PocketKidsService.isKidAccountNotifier.removeListener(_onModeChanged);
    PocketKidsService.currentWorldModeNotifier.removeListener(_onModeChanged);
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (PocketKidsService.isKidsWorld) {
      return const PocketPureKidsHomePage(
        key: ValueKey('pocket_pure_kids_active_home_root'),
      );
    }
    return PageView(
      controller: _homeHorizontalPageController,
      physics: const ClampingScrollPhysics(),
      children: const [
        custom_widgets.HomePageWidgetTree(
          key: ValueKey('adult_active_home_root'),
        ),
        PocketHomesReelsFeedWidget(
          key: ValueKey('adult_active_homes_reels_root'),
        ),
      ],
    );
  }
}
