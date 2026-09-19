import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_president_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_mate_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/president_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/pocket_ambient_flame_background.dart';

/// 🏛️ Official Presidential Palace & Sovereign Citadel of Pocket World
/// Displayed when visiting the President's profile, bio, or Citadel
class PresidentPalacePage extends StatefulWidget {
  const PresidentPalacePage({super.key});

  @override
  State<PresidentPalacePage> createState() => _PresidentPalacePageState();
}

class _PresidentPalacePageState extends State<PresidentPalacePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  bool _isMate = false;
  bool _isLoadingMate = true;
  List<Map<String, dynamic>> _announcements = [];
  bool _isLoadingAnnouncements = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadPresidentData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadPresidentData() async {
    final currentUserId = SupaFlow.client.auth.currentUser?.id ?? '';
    bool mateStatus = false;
    if (currentUserId.isNotEmpty) {
      mateStatus = await PocketMateService.isMate(
          currentUserId, PocketPresidentService.presidentId);
    }

    final vibes = await PocketPresidentService.getActivePresidentVibes();

    if (mounted) {
      setState(() {
        _isMate = mateStatus;
        _isLoadingMate = false;
        _announcements = vibes;
        _isLoadingAnnouncements = false;
      });
    }
  }

  Future<void> _toggleMateStatus() async {
    HapticFeedback.mediumImpact();
    final currentUserId = SupaFlow.client.auth.currentUser?.id ?? '';
    if (currentUserId.isEmpty) return;

    if (_isMate) {
      await PocketMateService.removeMateLocally(
          currentUserId, PocketPresidentService.presidentId);
      if (mounted) {
        setState(() => _isMate = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Honorary Mateship Charter withdrawn.'),
            backgroundColor: Colors.black87,
          ),
        );
      }
    } else {
      await PocketMateService.addMateLocally(
          currentUserId, PocketPresidentService.presidentId);
      if (mounted) {
        setState(() => _isMate = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('👑 Royal Mateship Charter granted! You are connected with The President.'),
            backgroundColor: Color(0xFF1E3A8A),
          ),
        );
      }
    }
  }

  void _openPresidentChat() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WhatsAppGroupChat(
          groupId: 'p:${PocketPresidentService.presidentId}',
          groupName: PocketPresidentService.presidentName,
        ),
      ),
    );
  }

  void _showAppealDialog() {
    HapticFeedback.selectionClick();
    final messageController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0F1D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: bottomInset + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const PresidentAvatarWidget(size: 36, showGlow: true),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Presidential Appeal & Inquiry',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Direct hotline to the Supreme Citadel Desk',
                            style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(bContext),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText:
                        'Describe your question, request for Citadel shield protection, or report to The President...',
                    hintStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 13),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final text = messageController.text.trim();
                            if (text.isEmpty) return;
                            setModalState(() => isSubmitting = true);

                            final uid = SupaFlow.client.auth.currentUser?.id ?? 'guest';
                            await PocketPresidentService.sendUserMessageToPresident(
                              userId: uid,
                              messageText: text,
                            );

                            if (context.mounted) {
                              Navigator.pop(bContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('🏛️ Dispatched to The President! You will receive a response shortly.'),
                                  backgroundColor: Color(0xFF1E3A8A),
                                ),
                              );
                            }
                          },
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            'Dispatch to President 🏛️',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Stack(
        children: [
          // 1. Ambient Flame & Ember particle layer
          const Positioned.fill(
            child: PocketAmbientFlameBackground(
              showTopFlameGlow: true,
              emberDensity: 0.85,
            ),
          ),

          // 2. Scrollable Palace Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildPalaceHeroSection(),
                        const SizedBox(height: 16),
                        _buildIdentityCard(),
                        const SizedBox(height: 16),
                        _buildCitadelStatsGrid(),
                        const SizedBox(height: 16),
                        _buildActionRow(),
                        const SizedBox(height: 16),
                        _buildProtectionStatusBanner(),
                        const SizedBox(height: 16),
                        _buildDecreesSection(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_balance_rounded, color: Color(0xFFFFD700), size: 18),
          const SizedBox(width: 8),
          Text(
            'Presidential Palace',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFFFFD700), size: 17),
          ),
          tooltip: 'Presidential Desk',
          onPressed: _openPresidentChat,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildPalaceHeroSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.15),
            blurRadius: 24,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 16,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Palace Artwork
            ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                'assets/images/presidential_palace.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 240,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 240,
                    color: const Color(0xFF1E293B),
                    child: const Center(
                      child: Icon(Icons.castle_rounded, size: 80, color: Color(0xFFFFD700)),
                    ),
                  );
                },
              ),
            ),

            // Ambient Royal Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      const Color(0xFF070B14).withValues(alpha: 0.7),
                      const Color(0xFF070B14),
                    ],
                    stops: const [0.0, 0.4, 0.75, 1.0],
                  ),
                ),
              ),
            ),

            // Bottom Label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF38BDF8), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🏰', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 5),
                        Text(
                          'Sovereign Seat of Pocket World',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFE0F2FE),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFD700)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_rounded, color: Color(0xFFFFD700), size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'Level 90 Supreme',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const PresidentAvatarWidget(size: 64, showGlow: true),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            PocketPresidentService.presidentName,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFD700),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.black,
                            size: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Head of State & Sovereign Protector',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFFFD700),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pocket World Executive Desk',
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              'Official guardian of Pocket World\'s citadels. Ensuring fair play, defending citizens against dishonorable raids, and empowering everyone to master the English language with daily speech.',
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitadelStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatTile(
            title: 'Citadel HP',
            value: '10,000',
            sub: 'Maximum Max',
            icon: Icons.favorite_rounded,
            accentColor: const Color(0xFFEF4444),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatTile(
            title: 'Defense',
            value: '9,999',
            sub: 'Unbreakable',
            icon: Icons.shield_rounded,
            accentColor: const Color(0xFF38BDF8),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatTile(
            title: 'Imperial Seal',
            value: 'Day 90',
            sub: 'Supreme Rank',
            icon: Icons.military_tech_rounded,
            accentColor: const Color(0xFFFFD700),
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        // Primary: Enter Desk
        Expanded(
          flex: 3,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            icon: const Icon(Icons.mark_chat_unread_rounded, size: 18),
            label: Text(
              'Presidential Desk',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            onPressed: _openPresidentChat,
          ),
        ),
        const SizedBox(width: 10),

        // Secondary: Mate Charter
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _isMate ? const Color(0xFF22C55E) : const Color(0xFFFFD700),
                width: 1.5,
              ),
              backgroundColor: _isMate
                  ? const Color(0xFF22C55E).withValues(alpha: 0.12)
                  : Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: Icon(
              _isMate ? Icons.handshake_rounded : Icons.person_add_alt_1_rounded,
              color: _isMate ? const Color(0xFF22C55E) : const Color(0xFFFFD700),
              size: 17,
            ),
            label: Text(
              _isMate ? 'Mate 🏅' : 'Be Mate',
              style: GoogleFonts.outfit(
                color: _isMate ? const Color(0xFF22C55E) : const Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            onPressed: _isLoadingMate ? null : _toggleMateStatus,
          ),
        ),
      ],
    );
  }

  Widget _buildProtectionStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E3A8A).withValues(alpha: 0.4),
            const Color(0xFF0F172A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_rounded, color: Color(0xFF38BDF8), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '24-Hour Citadel Protection Ready',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'If your Citadel is raided, the President automatically places it under Imperial Shelter.',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Color(0xFF38BDF8), size: 20),
            tooltip: 'Appeal / Request Shield',
            onPressed: _showAppealDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildDecreesSection() {
    if (_isLoadingAnnouncements) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Color(0xFFFFD700)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFD700), size: 16),
            const SizedBox(width: 8),
            Text(
              'Presidential Decrees & Vibes',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_announcements.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'No active decrees at this moment.',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
              ),
            ),
          )
        else
          ..._announcements.map((ann) {
            final caption = ann['caption']?.toString() ?? 'Official address from The President';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📜', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          caption,
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
