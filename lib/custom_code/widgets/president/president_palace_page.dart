import 'package:flutter/material.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_world_street_page.dart';

/// 🏛️ Official Presidential Palace & Sovereign Citadel of Pocket World
/// Renders the full interactive virtual world estate with the Grand Presidential Castle,
/// elite security perimeter, state limousine, Black Cat commandos, honor guards,
/// Level 90 attack lock, and 200-question boss battle.
class PresidentPalacePage extends StatelessWidget {
  const PresidentPalacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PocketCitadelAttackPage(
      neighbor: PocketNeighbor.createPresident(),
    );
  }
}
