import 'package:flutter/widgets.dart';

/// 🏠 Controller to coordinate horizontal navigation between PoketHomesReelsFeed and HomePageWidgetTree
class PocketHomeNavigationController {
  static PageController? horizontalPageController;

  /// Smoothly animates horizontal PageView to PoketHomesReelsFeedWidget (Index 0)
  static void scrollToHomes() {
    if (horizontalPageController != null && horizontalPageController!.hasClients) {
      horizontalPageController!.animateToPage(
        0,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  /// Smoothly animates horizontal PageView back to HomePageWidgetTree / Chat (Index 1)
  static void scrollToChat() {
    if (horizontalPageController != null && horizontalPageController!.hasClients) {
      horizontalPageController!.animateToPage(
        1,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }
}

