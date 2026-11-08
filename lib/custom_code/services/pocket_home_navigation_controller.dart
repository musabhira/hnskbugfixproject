import 'package:flutter/widgets.dart';

/// 🏠 Controller to coordinate navigation between PoketHomesReelsFeed and HomePageWidgetTree
class PocketHomeNavigationController {
  static PageController? horizontalPageController;
  static void Function()? switchToHomes;
  static void Function()? switchToChat;

  /// Smoothly switches or animates to PoketHomesReelsFeedWidget (Homes)
  static void scrollToHomes() {
    if (switchToHomes != null) {
      switchToHomes!();
      return;
    }
    if (horizontalPageController != null &&
        horizontalPageController!.hasClients) {
      horizontalPageController!.animateToPage(
        0,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  /// Smoothly switches or animates back to HomePageWidgetTree / Chat
  static void scrollToChat() {
    if (switchToChat != null) {
      switchToChat!();
      return;
    }
    if (horizontalPageController != null &&
        horizontalPageController!.hasClients) {
      horizontalPageController!.animateToPage(
        1,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }
}
