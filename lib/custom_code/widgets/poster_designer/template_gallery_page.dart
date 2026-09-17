import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'poster_models.dart';
import 'poster_editor_page.dart';

class TemplateGalleryPage extends StatefulWidget {
  const TemplateGalleryPage({super.key});

  @override
  State<TemplateGalleryPage> createState() => _TemplateGalleryPageState();
}

class _TemplateGalleryPageState extends State<TemplateGalleryPage> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Events',
    'Education',
    'Quotes',
    'Business',
    'Parties',
    'Social',
  ];

  late final List<Map<String, dynamic>> _templateData;

  @override
  void initState() {
    super.initState();
    _templateData = _buildRichTemplates();
  }

  List<Map<String, dynamic>> get _filteredTemplates {
    final query = _searchController.text.toLowerCase().trim();
    return _templateData.where((item) {
      final category = item['category'] as String;
      final template = item['template'] as PosterDesign;
      final matchesCat = _selectedCategory == 'All' || category == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          template.title.toLowerCase().contains(query) ||
          category.toLowerCase().contains(query);
      return matchesCat && matchesQuery;
    }).toList();
  }

  List<Map<String, dynamic>> _buildRichTemplates() {
    return [
      // 1. Events: English Speaking Club Weekend
      {
        'category': 'Events',
        'template': PosterDesign(
          title: 'English Speaking Club',
          backgroundColor: const Color(0xFF0F172A),
          elements: [
            // Header Badge Pill
            DesignElement(
              id: 'ev1_badge',
              type: ElementType.shape,
              position: const Offset(30, 40),
              size: const Size(140, 32),
              color: const Color(0xFFFFFC00),
              borderRadius: 16,
            ),
            DesignElement(
              id: 'ev1_badge_txt',
              type: ElementType.text,
              text: 'WEEKEND MEETUP',
              position: const Offset(30, 46),
              size: const Size(140, 24),
              textStyle: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: material.Colors.black,
                letterSpacing: 1.0,
              ),
            ),
            // Main Headline
            DesignElement(
              id: 'ev1_title',
              type: ElementType.text,
              text: 'ENGLISH\nSPEAKING\nCLUB',
              position: const Offset(30, 90),
              size: const Size(300, 150),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.outfit(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: material.Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            // Accent Line
            DesignElement(
              id: 'ev1_line',
              type: ElementType.shape,
              position: const Offset(30, 255),
              size: const Size(80, 4),
              color: const Color(0xFFFFFC00),
              borderRadius: 2,
            ),
            // Subtitle
            DesignElement(
              id: 'ev1_sub',
              type: ElementType.text,
              text: 'Practice fluent conversations, idioms,\nand debate with fellow mates.',
              position: const Offset(30, 275),
              size: const Size(280, 50),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF94A3B8),
              ),
            ),
            // Event Details Card
            DesignElement(
              id: 'ev1_card',
              type: ElementType.shape,
              position: const Offset(25, 345),
              size: const Size(310, 85),
              color: const Color(0xFF1E293B),
              borderRadius: 16,
            ),
            DesignElement(
              id: 'ev1_date',
              type: ElementType.text,
              text: '📅 Saturday, 7:00 PM IST\n📍 Poket Mates Voice Lounge\n🎟️ Free Entry for all Mates',
              position: const Offset(40, 360),
              size: const Size(280, 60),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: material.Colors.white,
              ),
            ),
          ],
        ),
      },

      // 2. Events: Tech Hackathon 2026
      {
        'category': 'Events',
        'template': PosterDesign(
          title: 'AI Hackathon 2026',
          backgroundColor: const Color(0xFF030712),
          elements: [
            DesignElement(
              id: 'ev2_bg_glow',
              type: ElementType.shape,
              position: const Offset(20, 30),
              size: const Size(320, 420),
              color: const Color(0xFF1E1B4B),
              borderRadius: 24,
            ),
            DesignElement(
              id: 'ev2_badge',
              type: ElementType.text,
              text: '⚡ 48-HOUR VIRTUAL SPRINT',
              position: const Offset(40, 55),
              size: const Size(280, 24),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF00E5FF),
                letterSpacing: 1.5,
              ),
            ),
            DesignElement(
              id: 'ev2_title',
              type: ElementType.text,
              text: 'BUILD THE\nFUTURE\nWITH AI',
              position: const Offset(40, 95),
              size: const Size(280, 140),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.outfit(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: material.Colors.white,
              ),
            ),
            DesignElement(
              id: 'ev2_prize_box',
              type: ElementType.shape,
              position: const Offset(40, 260),
              size: const Size(280, 70),
              color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
              borderRadius: 14,
            ),
            DesignElement(
              id: 'ev2_prize',
              type: ElementType.text,
              text: '🏆 \$10,000 PRIZE POOL\n+ Incubator Mentorship',
              position: const Offset(50, 275),
              size: const Size(260, 45),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00E5FF),
              ),
            ),
            DesignElement(
              id: 'ev2_cta',
              type: ElementType.shape,
              position: const Offset(40, 350),
              size: const Size(280, 45),
              color: const Color(0xFF00E5FF),
              borderRadius: 22,
            ),
            DesignElement(
              id: 'ev2_cta_txt',
              type: ElementType.text,
              text: 'REGISTER NOW',
              position: const Offset(40, 362),
              size: const Size(280, 24),
              textStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: material.Colors.black,
              ),
            ),
          ],
        ),
      },

      // 3. Education: Daily Vocab Masterclass
      {
        'category': 'Education',
        'template': PosterDesign(
          title: 'Daily Vocab Masterclass',
          backgroundColor: const Color(0xFF14532D),
          elements: [
            DesignElement(
              id: 'ed1_pill',
              type: ElementType.shape,
              position: const Offset(30, 40),
              size: const Size(120, 28),
              color: const Color(0xFF4ADE80),
              borderRadius: 14,
            ),
            DesignElement(
              id: 'ed1_pill_txt',
              type: ElementType.text,
              text: 'ENGLISH HUB',
              position: const Offset(30, 46),
              size: const Size(120, 20),
              textStyle: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF052E16),
              ),
            ),
            DesignElement(
              id: 'ed1_title',
              type: ElementType.text,
              text: 'WORD OF\nTHE DAY',
              position: const Offset(30, 85),
              size: const Size(280, 90),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.outfit(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: material.Colors.white,
              ),
            ),
            DesignElement(
              id: 'ed1_card',
              type: ElementType.shape,
              position: const Offset(25, 195),
              size: const Size(310, 165),
              color: material.Colors.black.withValues(alpha: 0.3),
              borderRadius: 18,
            ),
            DesignElement(
              id: 'ed1_word',
              type: ElementType.text,
              text: 'Eloquent / ˈeləkwənt /',
              position: const Offset(40, 215),
              size: const Size(280, 28),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4ADE80),
              ),
            ),
            DesignElement(
              id: 'ed1_def',
              type: ElementType.text,
              text: 'Meaning: Fluent or persuasive in speaking or writing clearly and beautifully.',
              position: const Offset(40, 250),
              size: const Size(280, 45),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: material.Colors.white70,
              ),
            ),
            DesignElement(
              id: 'ed1_ex',
              type: ElementType.text,
              text: '"Her eloquent speech inspired the entire audience to take action."',
              position: const Offset(40, 305),
              size: const Size(280, 45),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.inter(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFBBF7D0),
              ),
            ),
            DesignElement(
              id: 'ed1_tag',
              type: ElementType.text,
              text: 'Poket Mates Language Academy',
              position: const Offset(30, 385),
              size: const Size(300, 24),
              textAlign: TextAlign.center,
              textStyle: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: material.Colors.white38,
              ),
            ),
          ],
        ),
      },

      // 4. Quotes: Minimalist Swiss Typography
      {
        'category': 'Quotes',
        'template': PosterDesign(
          title: 'Stay Hungry Quote',
          backgroundColor: const Color(0xFFF8FAFC),
          elements: [
            DesignElement(
              id: 'q1_box',
              type: ElementType.shape,
              position: const Offset(30, 40),
              size: const Size(40, 40),
              color: material.Colors.black,
            ),
            DesignElement(
              id: 'q1_quote',
              type: ElementType.text,
              text: 'STAY\nHUNGRY.\nSTAY\nFOOLISH.',
              position: const Offset(30, 110),
              size: const Size(300, 180),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.inter(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: material.Colors.black,
                letterSpacing: -1.0,
                height: 1.05,
              ),
            ),
            DesignElement(
              id: 'q1_line',
              type: ElementType.shape,
              position: const Offset(30, 310),
              size: const Size(60, 4),
              color: const Color(0xFFEF4444),
            ),
            DesignElement(
              id: 'q1_author',
              type: ElementType.text,
              text: 'STEVE JOBS — STANFORD 2005',
              position: const Offset(30, 330),
              size: const Size(300, 30),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF64748B),
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      },

      // 5. Quotes: Neon Cyberpunk
      {
        'category': 'Quotes',
        'template': PosterDesign(
          title: 'Cyberpunk Motivation',
          backgroundColor: const Color(0xFF09090B),
          elements: [
            DesignElement(
              id: 'q2_border',
              type: ElementType.shape,
              position: const Offset(20, 20),
              size: const Size(320, 420),
              color: const Color(0xFFEC4899).withValues(alpha: 0.1),
              borderRadius: 20,
            ),
            DesignElement(
              id: 'q2_badge',
              type: ElementType.text,
              text: '// SYSTEM.OVERRIDE',
              position: const Offset(40, 50),
              size: const Size(280, 24),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                color: const Color(0xFFEC4899),
                fontWeight: FontWeight.bold,
              ),
            ),
            DesignElement(
              id: 'q2_title',
              type: ElementType.text,
              text: 'THE FUTURE\nBELONGS TO\nTHOSE WHO\nCREATE IT.',
              position: const Offset(40, 95),
              size: const Size(280, 180),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.outfit(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFF007A),
                height: 1.1,
              ),
            ),
            DesignElement(
              id: 'q2_accent',
              type: ElementType.shape,
              position: const Offset(40, 300),
              size: const Size(120, 3),
              color: const Color(0xFF00E5FF),
            ),
            DesignElement(
              id: 'q2_sub',
              type: ElementType.text,
              text: 'Daily Motivation · Poket Mates',
              position: const Offset(40, 320),
              size: const Size(280, 24),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.inter(
                fontSize: 12,
                color: material.Colors.white54,
              ),
            ),
          ],
        ),
      },

      // 6. Business: Flash Sale 50% Off
      {
        'category': 'Business',
        'template': PosterDesign(
          title: 'Mega Flash Sale',
          backgroundColor: const Color(0xFFFFFC00),
          elements: [
            DesignElement(
              id: 'bs1_pill',
              type: ElementType.shape,
              position: const Offset(30, 40),
              size: const Size(150, 34),
              color: material.Colors.black,
              borderRadius: 8,
            ),
            DesignElement(
              id: 'bs1_pill_txt',
              type: ElementType.text,
              text: 'LIMITED TIME ONLY',
              position: const Offset(30, 48),
              size: const Size(150, 24),
              textStyle: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFFFC00),
              ),
            ),
            DesignElement(
              id: 'bs1_title',
              type: ElementType.text,
              text: 'MEGA\nFLASH\nSALE',
              position: const Offset(30, 90),
              size: const Size(300, 140),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.outfit(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: material.Colors.black,
                height: 0.95,
              ),
            ),
            DesignElement(
              id: 'bs1_badge',
              type: ElementType.shape,
              position: const Offset(30, 250),
              size: const Size(200, 60),
              color: const Color(0xFFEF4444),
              borderRadius: 12,
            ),
            DesignElement(
              id: 'bs1_discount',
              type: ElementType.text,
              text: 'UP TO 50% OFF',
              position: const Offset(30, 264),
              size: const Size(200, 34),
              textStyle: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: material.Colors.white,
              ),
            ),
            DesignElement(
              id: 'bs1_code',
              type: ElementType.text,
              text: 'USE CODE: POCKET50 AT CHECKOUT',
              position: const Offset(30, 335),
              size: const Size(300, 24),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: material.Colors.black87,
              ),
            ),
          ],
        ),
      },

      // 7. Business: Specialty Coffee Morning
      {
        'category': 'Business',
        'template': PosterDesign(
          title: 'Artisan Coffee Brew',
          backgroundColor: const Color(0xFF291B15),
          elements: [
            DesignElement(
              id: 'bs2_badge',
              type: ElementType.text,
              text: '☕ FRESH ROASTED DAILY',
              position: const Offset(30, 45),
              size: const Size(300, 24),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFD97706),
                letterSpacing: 1.2,
              ),
            ),
            DesignElement(
              id: 'bs2_title',
              type: ElementType.text,
              text: 'MORNING\nESPRESSO\n& CROISSANT',
              position: const Offset(30, 85),
              size: const Size(300, 140),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.outfit(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFDE68A),
              ),
            ),
            DesignElement(
              id: 'bs2_card',
              type: ElementType.shape,
              position: const Offset(25, 245),
              size: const Size(310, 80),
              color: const Color(0xFF3F2D24),
              borderRadius: 16,
            ),
            DesignElement(
              id: 'bs2_offer',
              type: ElementType.text,
              text: 'Buy 1 Specialty Latte, Get 1 Pastry 50% Off!\nValid Every Morning 7:00 AM - 11:00 AM',
              position: const Offset(40, 262),
              size: const Size(280, 50),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.inter(
                fontSize: 12,
                color: material.Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            DesignElement(
              id: 'bs2_loc',
              type: ElementType.text,
              text: 'Visit us at Poket Mates Cafe & Lounge',
              position: const Offset(30, 350),
              size: const Size(300, 24),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFD97706),
              ),
            ),
          ],
        ),
      },

      // 8. Parties: Sunset Rooftop Vibe
      {
        'category': 'Parties',
        'template': PosterDesign(
          title: 'Sunset Rooftop Session',
          backgroundColor: const Color(0xFF4C0519),
          elements: [
            DesignElement(
              id: 'pt1_pill',
              type: ElementType.shape,
              position: const Offset(30, 40),
              size: const Size(130, 28),
              color: const Color(0xFFFB7185),
              borderRadius: 14,
            ),
            DesignElement(
              id: 'pt1_pill_txt',
              type: ElementType.text,
              text: 'LIVE DJ SET',
              position: const Offset(30, 46),
              size: const Size(130, 20),
              textStyle: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: material.Colors.black,
              ),
            ),
            DesignElement(
              id: 'pt1_title',
              type: ElementType.text,
              text: 'SUNSET\nROOFTOP\nVIBES',
              position: const Offset(30, 85),
              size: const Size(300, 130),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.outfit(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFDA4AF),
              ),
            ),
            DesignElement(
              id: 'pt1_line',
              type: ElementType.shape,
              position: const Offset(30, 235),
              size: const Size(280, 2),
              color: material.Colors.white24,
            ),
            DesignElement(
              id: 'pt1_details',
              type: ElementType.text,
              text: 'Deep House · Ambient Beats · Mocktails\nFRIDAY NIGHT | DOORS OPEN 6:00 PM',
              position: const Offset(30, 255),
              size: const Size(300, 50),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: material.Colors.white,
              ),
            ),
            DesignElement(
              id: 'pt1_rsvp',
              type: ElementType.shape,
              position: const Offset(30, 330),
              size: const Size(200, 45),
              color: const Color(0xFFFFFC00),
              borderRadius: 22,
            ),
            DesignElement(
              id: 'pt1_rsvp_txt',
              type: ElementType.text,
              text: 'RSVP ON APP',
              position: const Offset(30, 342),
              size: const Size(200, 24),
              textStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: material.Colors.black,
              ),
            ),
          ],
        ),
      },

      // 9. Social: Podcast Drop Announcement
      {
        'category': 'Social',
        'template': PosterDesign(
          title: 'Podcast Episode Drop',
          backgroundColor: const Color(0xFF18181B),
          elements: [
            DesignElement(
              id: 'sc1_badge',
              type: ElementType.shape,
              position: const Offset(30, 40),
              size: const Size(110, 28),
              color: const Color(0xFF6366F1),
              borderRadius: 14,
            ),
            DesignElement(
              id: 'sc1_badge_txt',
              type: ElementType.text,
              text: 'NEW EPISODE',
              position: const Offset(30, 46),
              size: const Size(110, 20),
              textStyle: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: material.Colors.white,
              ),
            ),
            DesignElement(
              id: 'sc1_ep',
              type: ElementType.text,
              text: 'EPISODE 42',
              position: const Offset(30, 80),
              size: const Size(280, 26),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFA5B4FC),
              ),
            ),
            DesignElement(
              id: 'sc1_title',
              type: ElementType.text,
              text: 'HOW TO SPEAK\nENGLISH WITH\nZERO FEAR',
              position: const Offset(30, 115),
              size: const Size(300, 120),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: material.Colors.white,
              ),
            ),
            DesignElement(
              id: 'sc1_guest_box',
              type: ElementType.shape,
              position: const Offset(25, 255),
              size: const Size(310, 75),
              color: const Color(0xFF27272A),
              borderRadius: 16,
            ),
            DesignElement(
              id: 'sc1_guest',
              type: ElementType.text,
              text: 'FEATURING: ELENA VANCE\nLanguage Coach & Polyglot',
              position: const Offset(40, 275),
              size: const Size(280, 40),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFA5B4FC),
              ),
            ),
            DesignElement(
              id: 'sc1_listen',
              type: ElementType.text,
              text: '🎧 STREAMING NOW ON POKET MATES',
              position: const Offset(30, 355),
              size: const Size(300, 24),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: material.Colors.white54,
              ),
            ),
          ],
        ),
      },

      // 10. Education: IELTS Speaking Camp
      {
        'category': 'Education',
        'template': PosterDesign(
          title: 'IELTS Band 8+ Camp',
          backgroundColor: const Color(0xFF0F172A),
          elements: [
            DesignElement(
              id: 'ielts_pill',
              type: ElementType.shape,
              position: const Offset(30, 40),
              size: const Size(130, 30),
              color: const Color(0xFF38BDF8),
              borderRadius: 8,
            ),
            DesignElement(
              id: 'ielts_pill_txt',
              type: ElementType.text,
              text: 'CRASH COURSE',
              position: const Offset(30, 47),
              size: const Size(130, 20),
              textStyle: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A),
              ),
            ),
            DesignElement(
              id: 'ielts_title',
              type: ElementType.text,
              text: 'IELTS\nBAND 8+\nBOOTCAMP',
              position: const Offset(30, 90),
              size: const Size(300, 130),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.outfit(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: material.Colors.white,
              ),
            ),
            DesignElement(
              id: 'ielts_points',
              type: ElementType.text,
              text: '✓ Live Cue Card Simulations\n✓ Fluency & Pronunciation Drills\n✓ 1-on-1 AI Accent Feedback',
              position: const Offset(30, 240),
              size: const Size(300, 70),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFBAE6FD),
                height: 1.5,
              ),
            ),
            DesignElement(
              id: 'ielts_btn',
              type: ElementType.shape,
              position: const Offset(30, 335),
              size: const Size(220, 45),
              color: const Color(0xFF38BDF8),
              borderRadius: 12,
            ),
            DesignElement(
              id: 'ielts_btn_txt',
              type: ElementType.text,
              text: 'JOIN BATCH TODAY',
              position: const Offset(30, 348),
              size: const Size(220, 24),
              textStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      },

      // 11. Motivation: Golden Luxury
      {
        'category': 'Quotes',
        'template': PosterDesign(
          title: 'Discipline Over Motivation',
          backgroundColor: const Color(0xFF1C1917),
          elements: [
            DesignElement(
              id: 'gold_star',
              type: ElementType.shape,
              position: const Offset(30, 45),
              size: const Size(30, 4),
              color: const Color(0xFFFBBF24),
            ),
            DesignElement(
              id: 'gold_title',
              type: ElementType.text,
              text: 'DISCIPLINE\nWILL TAKE\nYOU WHERE\nMOTIVATION\nCANNOT.',
              position: const Offset(30, 75),
              size: const Size(300, 200),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.outfit(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFDE68A),
                height: 1.05,
              ),
            ),
            DesignElement(
              id: 'gold_card',
              type: ElementType.shape,
              position: const Offset(25, 300),
              size: const Size(310, 60),
              color: const Color(0xFF292524),
              borderRadius: 12,
            ),
            DesignElement(
              id: 'gold_note',
              type: ElementType.text,
              text: 'Consistency beats intensity every single day.\nKeep showing up.',
              position: const Offset(38, 312),
              size: const Size(290, 40),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.inter(
                fontSize: 12,
                color: material.Colors.white70,
              ),
            ),
          ],
        ),
      },

      // 12. Parties: Retro Neon Game Night
      {
        'category': 'Parties',
        'template': PosterDesign(
          title: 'Retro Game Night Arena',
          backgroundColor: const Color(0xFF1E1B4B),
          elements: [
            DesignElement(
              id: 'gn_pill',
              type: ElementType.shape,
              position: const Offset(30, 40),
              size: const Size(120, 28),
              color: const Color(0xFFA855F7),
              borderRadius: 14,
            ),
            DesignElement(
              id: 'gn_pill_txt',
              type: ElementType.text,
              text: 'ARCADE NIGHT',
              position: const Offset(30, 46),
              size: const Size(120, 20),
              textStyle: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: material.Colors.white,
              ),
            ),
            DesignElement(
              id: 'gn_title',
              type: ElementType.text,
              text: 'RETRO\nGAMING\nARENA',
              position: const Offset(30, 85),
              size: const Size(300, 130),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.outfit(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFC084FC),
              ),
            ),
            DesignElement(
              id: 'gn_sub',
              type: ElementType.text,
              text: 'Smash Bros · Street Fighter · Chess\nTournament Winner takes Home \$250!',
              position: const Offset(30, 240),
              size: const Size(300, 50),
              textAlign: TextAlign.left,
              textStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: material.Colors.white,
              ),
            ),
            DesignElement(
              id: 'gn_btn',
              type: ElementType.shape,
              position: const Offset(30, 315),
              size: const Size(200, 45),
              color: const Color(0xFFFFFC00),
              borderRadius: 22,
            ),
            DesignElement(
              id: 'gn_btn_txt',
              type: ElementType.text,
              text: 'CLAIM FREE PASS',
              position: const Offset(30, 328),
              size: const Size(200, 24),
              textStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: material.Colors.black,
              ),
            ),
          ],
        ),
      },
    ];
  }

  void _openEditor(PosterDesign design) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PosterEditorPage(initialDesign: design),
      ),
    );
  }

  void _createBlankCanvas() {
    final blank = PosterDesign(
      title: 'Blank Canvas',
      backgroundColor: material.Colors.black,
      elements: [
        DesignElement(
          id: 'blank_title',
          type: ElementType.text,
          text: 'YOUR TITLE HERE',
          position: const Offset(40, 100),
          size: const Size(280, 60),
          textStyle: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: material.Colors.white,
          ),
        ),
      ],
    );
    _openEditor(blank);
  }

  @override
  Widget build(BuildContext context) {
    const accentYellow = Color(0xFFFFFC00);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1015),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentYellow.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.palette_rounded, color: accentYellow, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Poster Designer Pro',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_rounded, color: accentYellow, size: 26),
            tooltip: 'Create Blank Canvas',
            onPressed: _createBlankCanvas,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search templates (Event, Sale, Quote, IELTS)...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: accentYellow, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Category Chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? accentYellow : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? accentYellow : Colors.white10,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.inter(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          // Blank Canvas Creator Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: _createBlankCanvas,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF312E81), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start with a Blank Poster',
                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'Custom background, texts, stickers, shapes & high-res export.',
                            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCategory == 'All' ? 'Designer Templates' : '$_selectedCategory Templates',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_filteredTemplates.length} designs',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Grid of Templates
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.68,
              ),
              itemCount: _filteredTemplates.length,
              itemBuilder: (context, index) {
                final item = _filteredTemplates[index];
                final template = item['template'] as PosterDesign;
                return _buildTemplateCard(template, item['category'] as String);
              },
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(PosterDesign template, String category) {
    const accentYellow = Color(0xFFFFFC00);

    return InkWell(
      onTap: () => _openEditor(template),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardW = constraints.maxWidth;
            final cardH = constraints.maxHeight;
            const double originalW = 360.0;
            final scale = cardW / originalW;

            return Stack(
              children: [
                // Template Canvas Background
                Container(
                  width: cardW,
                  height: cardH,
                  color: template.backgroundColor,
                ),

                // Scaled Design Elements Preview
                ...template.elements.map((element) {
                  final left = element.position.dx * scale;
                  final top = element.position.dy * scale;
                  final width = element.size.width * scale;
                  final height = element.size.height * scale;

                  if (element.type == ElementType.text) {
                    final fontSize = (element.textStyle?.fontSize ?? 14.0) * scale;
                    return Positioned(
                      left: left,
                      top: top,
                      width: width,
                      child: Text(
                        element.text ?? '',
                        textAlign: element.textAlign,
                        style: (element.textStyle ?? GoogleFonts.inter()).copyWith(
                          fontSize: fontSize.clamp(6.0, 32.0),
                          color: element.textStyle?.color ?? element.color,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  } else if (element.type == ElementType.shape) {
                    return Positioned(
                      left: left,
                      top: top,
                      child: Container(
                        width: width,
                        height: height,
                        decoration: BoxDecoration(
                          color: element.color,
                          borderRadius: BorderRadius.circular((element.borderRadius ?? 0.0) * scale),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Bottom Title Bar Overlay
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          material.Colors.black.withValues(alpha: 0.0),
                          material.Colors.black.withValues(alpha: 0.95),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            template.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              color: material.Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentYellow,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'EDIT',
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: material.Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
