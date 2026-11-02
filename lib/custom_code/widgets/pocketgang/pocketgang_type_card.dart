import 'package:flutter/material.dart';
import 'pocketgang_models.dart';

/// Interactive Gang Type Selector Card
class PocketGangTypeCard extends StatelessWidget {
  final PocketGangType type;
  final bool isSelected;
  final VoidCallback onTap;

  const PocketGangTypeCard({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color activeColor;
    LinearGradient activeGradient;
    List<String> featureHighlights;

    switch (type) {
      case PocketGangType.individual:
        activeColor = const Color(0xFF38BDF8);
        activeGradient = const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        featureHighlights = ['1 Member (Private)', 'Habits & Goals', 'Focus Timer', 'Personal Dashboard'];
        break;
      case PocketGangType.couple:
        activeColor = const Color(0xFFF43F5E);
        activeGradient = const LinearGradient(
          colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        featureHighlights = ['Exactly 2 Consenting Mates', 'Romantic Themes', 'Memories Timeline', 'Love Notes'];
        break;
      case PocketGangType.friendsTeam:
        activeColor = const Color(0xFFFFD700);
        activeGradient = const LinearGradient(
          colors: [Color(0xFFD97706), Color(0xFFB45309)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        featureHighlights = ['Multi-Member Teamwork', 'Kanban Tasks & Sprints', 'Diagram Studio', '100% Contribution'];
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : Colors.white12,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: activeGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(type.icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        type.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? activeColor : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? activeColor : Colors.white30,
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 13, color: Colors.black)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    type.subtitle,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: featureHighlights.map((feat) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: activeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          feat,
                          style: TextStyle(
                            color: activeColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

