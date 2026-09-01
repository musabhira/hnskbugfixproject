import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'vector_avatar_studio_page.dart';

/// Floating Action Button for Testing and Opening Vector Avatar Studio
class AvatarFloatingButton extends StatefulWidget {
  const AvatarFloatingButton({super.key});

  @override
  State<AvatarFloatingButton> createState() => _AvatarFloatingButtonState();
}

class _AvatarFloatingButtonState extends State<AvatarFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFFC00).withValues(alpha: 0.4),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          heroTag: 'vector_avatar_studio_fab',
          backgroundColor: const Color(0xFFFFFC00),
          foregroundColor: Colors.black,
          elevation: 6,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VectorAvatarStudioPage(),
              ),
            );
          },
          icon: const Icon(Icons.face_retouching_natural, color: Colors.black, size: 22),
          label: Text(
            'Avatar Studio',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
