import 'dart:ui' as ui;
import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'poster_models.dart';
import 'poster_editor_page.dart';

class TemplateGalleryPage extends StatelessWidget {
  const TemplateGalleryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock templates for now
    final templates = [
      PosterDesign(
        title: 'Morning Vibes',
        backgroundColor: const Color(0xFFFFD700),
        elements: [
          DesignElement(
            id: '1',
            type: ElementType.text,
            text: 'Good Morning!',
            position: const Offset(40, 50),
            textStyle: GoogleFonts.outfit(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: material.Colors.black),
          ),
          DesignElement(
            id: '2',
            type: ElementType.shape,
            position: const Offset(0, 300),
            size: const Size(400, 100),
            color: material.Colors.white.withValues(alpha: 0.5),
          ),
        ],
      ),
      PosterDesign(
        title: 'Minimal Quote',
        backgroundColor: material.Colors.black,
        elements: [
          DesignElement(
            id: '3',
            type: ElementType.text,
            text: '"Complexity is the enemy of execution"',
            position: const Offset(50, 150),
            size: const Size(300, 100),
            textStyle: GoogleFonts.inter(
                fontSize: 24,
                fontStyle: ui.FontStyle.italic,
                color: material.Colors.white),
          ),
        ],
      ),
      PosterDesign(
        title: 'Malay Style Greeting',
        backgroundColor: const Color(0xFF1B5E20),
        elements: [
          DesignElement(
            id: '4',
            type: ElementType.text,
            text: 'Selamat Hari Raya',
            position: const Offset(20, 100),
            textStyle: GoogleFonts.notoSans(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFD700)),
          ),
        ],
      ),
    ];

    return material.Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: material.AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Design Templates',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        leading: material.IconButton(
          icon: const Icon(FluentIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: material.GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const material.SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: templates.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildCreateNewTile(context);
          return _buildTemplateTile(context, templates[index - 1]);
        },
      ),
    );
  }

  Widget _buildCreateNewTile(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        material.MaterialPageRoute(
            builder: (context) => const PosterEditorPage()),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: material.Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: material.Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(FluentIcons.add,
                size: 40, color: material.Colors.yellow),
            const SizedBox(height: 12),
            Text('Create New',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, color: material.Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateTile(BuildContext context, PosterDesign template) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        material.MaterialPageRoute(
            builder: (context) => PosterEditorPage(initialDesign: template)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: template.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: material.Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 2),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  template.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: template.backgroundColor.computeLuminance() > 0.5
                        ? material.Colors.black
                        : material.Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: material.Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('EDIT',
                    style: GoogleFonts.inter(
                        fontSize: 10, color: material.Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
