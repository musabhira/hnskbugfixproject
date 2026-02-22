import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'poster_models.dart';
import 'poster_editor_page.dart';

class TemplateGalleryPage extends StatelessWidget {
  const TemplateGalleryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final templates = [
      PosterDesign(
        title: 'Retro Wave',
        backgroundColor: const Color(0xFF1A1A24),
        elements: [
          DesignElement(
              id: '1_1',
              type: ElementType.text,
              text: 'Retro Wave',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.outfit(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00E5FF))),
          DesignElement(
              id: '1_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: const Color(0xFFFFD700).withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Modern Corporate',
        backgroundColor: const Color(0xFF2A4B7C),
        elements: [
          DesignElement(
              id: '2_1',
              type: ElementType.text,
              text: 'Modern Corporate',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.inter(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: material.Colors.white)),
          DesignElement(
              id: '2_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: material.Colors.white.withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Elegant Wedding',
        backgroundColor: const Color(0xFF8B4513),
        elements: [
          DesignElement(
              id: '3_1',
              type: ElementType.text,
              text: 'Elegant Wedding',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.notoSans(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700))),
          DesignElement(
              id: '3_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: const Color(0xFFFFD700).withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Fitness Bootcamp',
        backgroundColor: const Color(0xFFD32F2F),
        elements: [
          DesignElement(
              id: '4_1',
              type: ElementType.text,
              text: 'Fitness Bootcamp',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.roboto(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: material.Colors.white)),
          DesignElement(
              id: '4_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: material.Colors.white.withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Summer Festival',
        backgroundColor: const Color(0xFFFBC02D),
        elements: [
          DesignElement(
              id: '5_1',
              type: ElementType.text,
              text: 'Summer Festival',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.lato(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: material.Colors.black)),
          DesignElement(
              id: '5_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: material.Colors.black.withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Tech Conference',
        backgroundColor: const Color(0xFF0288D1),
        elements: [
          DesignElement(
              id: '6_1',
              type: ElementType.text,
              text: 'Tech Conference',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.montserrat(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: material.Colors.white)),
          DesignElement(
              id: '6_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: const Color(0xFF00E5FF).withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Real Estate',
        backgroundColor: const Color(0xFF388E3C),
        elements: [
          DesignElement(
              id: '7_1',
              type: ElementType.text,
              text: 'Real Estate',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: material.Colors.white)),
          DesignElement(
              id: '7_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: material.Colors.white.withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Coffee Shop',
        backgroundColor: const Color(0xFF5D4037),
        elements: [
          DesignElement(
              id: '8_1',
              type: ElementType.text,
              text: 'Coffee Shop',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.oswald(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700))),
          DesignElement(
              id: '8_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: const Color(0xFFFFD700).withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Creative Agency',
        backgroundColor: const Color(0xFF7B1FA2),
        elements: [
          DesignElement(
              id: '9_1',
              type: ElementType.text,
              text: 'Creative Agency',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.outfit(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00E5FF))),
          DesignElement(
              id: '9_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: material.Colors.white.withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Music Concert',
        backgroundColor: const Color(0xFFE91E63),
        elements: [
          DesignElement(
              id: '10_1',
              type: ElementType.text,
              text: 'Music Concert',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.inter(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: material.Colors.white)),
          DesignElement(
              id: '10_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: material.Colors.black.withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Travel Agency',
        backgroundColor: const Color(0xFF0097A7),
        elements: [
          DesignElement(
              id: '11_1',
              type: ElementType.text,
              text: 'Travel Agency',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.notoSans(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: material.Colors.white)),
          DesignElement(
              id: '11_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: const Color(0xFFFFD700).withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Food Festival',
        backgroundColor: const Color(0xFFE64A19),
        elements: [
          DesignElement(
              id: '12_1',
              type: ElementType.text,
              text: 'Food Festival',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.roboto(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700))),
          DesignElement(
              id: '12_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: material.Colors.black.withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Cyberpunk Night',
        backgroundColor: const Color(0xFF1976D2),
        elements: [
          DesignElement(
              id: '13_1',
              type: ElementType.text,
              text: 'Cyberpunk Night',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.lato(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00E5FF))),
          DesignElement(
              id: '13_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: const Color(0xFF00E5FF).withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Minimalist Art',
        backgroundColor: const Color(0xFF616161),
        elements: [
          DesignElement(
              id: '14_1',
              type: ElementType.text,
              text: 'Minimalist Art',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.montserrat(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: material.Colors.white)),
          DesignElement(
              id: '14_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: material.Colors.black.withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Photography Portfolio',
        backgroundColor: const Color(0xFF455A64),
        elements: [
          DesignElement(
              id: '15_1',
              type: ElementType.text,
              text: 'Photography Portfolio',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: material.Colors.white)),
          DesignElement(
              id: '15_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: material.Colors.white.withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Yoga Retreat',
        backgroundColor: const Color(0xFF00796B),
        elements: [
          DesignElement(
              id: '16_1',
              type: ElementType.text,
              text: 'Yoga Retreat',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.oswald(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: material.Colors.white)),
          DesignElement(
              id: '16_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: const Color(0xFFFFD700).withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Startup Launch',
        backgroundColor: const Color(0xFF303F9F),
        elements: [
          DesignElement(
              id: '17_1',
              type: ElementType.text,
              text: 'Startup Launch',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.outfit(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00E5FF))),
          DesignElement(
              id: '17_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: material.Colors.white.withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Dance Party',
        backgroundColor: const Color(0xFFE91E63),
        elements: [
          DesignElement(
              id: '18_1',
              type: ElementType.text,
              text: 'Dance Party',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.inter(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: material.Colors.white)),
          DesignElement(
              id: '18_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: material.Colors.black.withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Business Workshop',
        backgroundColor: const Color(0xFF1976D2),
        elements: [
          DesignElement(
              id: '19_1',
              type: ElementType.text,
              text: 'Business Workshop',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.notoSans(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: material.Colors.white)),
          DesignElement(
              id: '19_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: material.Colors.white.withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Spring Sale',
        backgroundColor: const Color(0xFF689F38),
        elements: [
          DesignElement(
              id: '20_1',
              type: ElementType.text,
              text: 'Spring Sale',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.roboto(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700))),
          DesignElement(
              id: '20_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: material.Colors.white.withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Halloween Party',
        backgroundColor: const Color(0xFFF57C00),
        elements: [
          DesignElement(
              id: '21_1',
              type: ElementType.text,
              text: 'Halloween Party',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.lato(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: material.Colors.black)),
          DesignElement(
              id: '21_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: material.Colors.black.withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Christmas Greetings',
        backgroundColor: const Color(0xFFD32F2F),
        elements: [
          DesignElement(
              id: '22_1',
              type: ElementType.text,
              text: 'Christmas Greetings',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.montserrat(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: material.Colors.white)),
          DesignElement(
              id: '22_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: const Color(0xFFFFD700).withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'New Year Bash',
        backgroundColor: const Color(0xFF512DA8),
        elements: [
          DesignElement(
              id: '23_1',
              type: ElementType.text,
              text: 'New Year Bash',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700))),
          DesignElement(
              id: '23_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: const Color(0xFF00E5FF).withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Product Promo',
        backgroundColor: const Color(0xFFFBC02D),
        elements: [
          DesignElement(
              id: '24_1',
              type: ElementType.text,
              text: 'Product Promo',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.oswald(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: material.Colors.black)),
          DesignElement(
              id: '24_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: material.Colors.white.withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Fashion Show',
        backgroundColor: const Color(0xFF1A1A24),
        elements: [
          DesignElement(
              id: '25_1',
              type: ElementType.text,
              text: 'Fashion Show',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.outfit(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: material.Colors.white)),
          DesignElement(
              id: '25_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: const Color(0xFFFFD700).withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Charity Event',
        backgroundColor: const Color(0xFF00796B),
        elements: [
          DesignElement(
              id: '26_1',
              type: ElementType.text,
              text: 'Charity Event',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.inter(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700))),
          DesignElement(
              id: '26_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: material.Colors.white.withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Book Club',
        backgroundColor: const Color(0xFF5D4037),
        elements: [
          DesignElement(
              id: '27_1',
              type: ElementType.text,
              text: 'Book Club',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.notoSans(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700))),
          DesignElement(
              id: '27_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: const Color(0xFFFFD700).withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Gaming Tournament',
        backgroundColor: const Color(0xFF2A4B7C),
        elements: [
          DesignElement(
              id: '28_1',
              type: ElementType.text,
              text: 'Gaming Tournament',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.roboto(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00E5FF))),
          DesignElement(
              id: '28_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: const Color(0xFF00E5FF).withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Sports Event',
        backgroundColor: const Color(0xFFD32F2F),
        elements: [
          DesignElement(
              id: '29_1',
              type: ElementType.text,
              text: 'Sports Event',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.lato(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: material.Colors.white)),
          DesignElement(
              id: '29_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: material.Colors.white.withValues(alpha: 0.1)),
        ],
      ),
      PosterDesign(
        title: 'Bake Sale',
        backgroundColor: const Color(0xFFE64A19),
        elements: [
          DesignElement(
              id: '30_1',
              type: ElementType.text,
              text: 'Bake Sale',
              position: const Offset(40, 50),
              textStyle: GoogleFonts.montserrat(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700))),
          DesignElement(
              id: '30_2',
              type: ElementType.shape,
              position: const Offset(0, 300),
              size: const Size(400, 100),
              color: material.Colors.white.withValues(alpha: 0.1)),
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
