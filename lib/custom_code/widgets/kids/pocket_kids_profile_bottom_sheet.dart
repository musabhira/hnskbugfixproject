import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_avatar_house_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_attacking_profile_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_mate_chat_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/cards/pop_art_cards_viewer_page.dart';

/// 🏰 Dedicated Kids Player Profile Bottom Sheet
/// Audio Directive:
/// "ഈ മറ്റേ അറ്റാക്കിങ് പ്രൊഫൈൽ ഒക്കെ നമ്മളെ സെയിം അഡൽറ്റിലെ അതേ അറ്റാക്കിങ് പ്രൊഫൈൽ കൊടുത്താൽ മതി ട്ടോ.
/// പക്ഷെ കേറുമ്പോൾ ആ ബോട്ടം ഷീറ്റിൽ ഇവരുടെ പ്രൊഫൈൽ കാണിച്ചാൽ മതി. പ്രൊഫൈൽ വേണം, മനസ്സിലായില്ലേ?
/// അറ്റാക്കിങ് ഭയങ്കര ഇന്ററസ്റ്റിംഗ് ആണ്. കിഡ്സിന്റെ അറ്റാക്കിങ് പ്രൊഫൈലിൽ പോയി അറ്റാക്ക് ടാപ്പ് ചെയ്തു കഴിഞ്ഞാൽ
/// അവർക്ക് റോബോട്ടുകളെ അറ്റാക്ക് ചെയ്യുക, വീടുകൾ അറ്റാക്ക് ചെയ്യുക..."
class PocketKidsProfileBottomSheet extends StatefulWidget {
  final KidMate mate;

  const PocketKidsProfileBottomSheet({
    super.key,
    required this.mate,
  });

  static Future<void> show(
    BuildContext context, {
    required KidMate mate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PocketKidsProfileBottomSheet(mate: mate),
    );
  }

  @override
  State<PocketKidsProfileBottomSheet> createState() =>
      _PocketKidsProfileBottomSheetState();
}

class _PocketKidsProfileBottomSheetState
    extends State<PocketKidsProfileBottomSheet> {
  final FlutterTts _tts = FlutterTts();
  late KidMateRequestStatus _requestStatus;
  bool _speaking = false;
  int _friendshipHearts = 3;

  @override
  void initState() {
    super.initState();
    _requestStatus = PocketKidsService.getMateRequestStatus(widget.mate.id);
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3);
      await _tts.setSpeechRate(0.44);
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _speaking = false);
      });
      _speak("Meet ${widget.mate.name}! Day ${widget.mate.dayLevel} Explorer!");
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    try {
      setState(() => _speaking = true);
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      if (mounted) setState(() => _speaking = false);
    }
  }

  void _onAttackPressed() {
    HapticFeedback.heavyImpact();
    Navigator.pop(context); // Close bottom sheet first
    PocketGameAudioService.instance.playAttackTheme(
      targetId: widget.mate.id,
      targetDay: widget.mate.dayLevel,
    );
    PocketKidsService.incrementAttackCount();

    // Navigate to Kids Attacking Profile Page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsAttackingProfilePage(mate: widget.mate),
      ),
    );
  }

  void _onChatPressed() {
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsMateChatPage(mate: widget.mate),
      ),
    );
  }

  void _giftCookie() {
    HapticFeedback.heavyImpact();
    PocketGameSFX.playCorrectChime();
    setState(() {
      _friendshipHearts++;
    });
    _speak("You gifted a glowing Star Cookie to ${widget.mate.name}! 🍪⭐");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Gifted a Star Cookie to ${widget.mate.name}! 🍪✨ (+10 KS)',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final house = PocketKidsService.getHouseForDay(widget.mate.dayLevel);
    final card = PopArtCardHelper.getCardForDay(widget.mate.dayLevel, isMale: true);
    final isMate = _requestStatus == KidMateRequestStatus.accepted;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: Color(0xFF38BDF8), width: 2.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),

          // Top Header: Avatar + Name + Level Badge + Audio
          Row(
            children: [
              // Avatar with Golden Story Ring
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                  ),
                ),
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.mate.avatar,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.mate.name,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isMate)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFF10B981), width: 1),
                            ),
                            child: Text(
                              '🤝 MATE',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF34D399),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ages ${widget.mate.ageGroup} • ${widget.mate.isRobot ? "🤖 Robot Peer" : "🌟 Pocket Kid"}',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: house.themeColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: house.themeColor, width: 1),
                      ),
                      child: Text(
                        'Tier ${house.tier} • ${house.title}',
                        style: GoogleFonts.outfit(
                          color: house.themeColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: Icon(
                  _speaking
                      ? Icons.volume_up_rounded
                      : Icons.volume_mute_rounded,
                  color: const Color(0xFFFFD700),
                ),
                onPressed: () {
                  if (_speaking) {
                    _tts.stop();
                    setState(() => _speaking = false);
                  } else {
                    _speak("${widget.mate.name} is on Day ${widget.mate.dayLevel}. Living in ${house.title}!");
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Middle: House Vector Art & Defense Card Preview
          Row(
            children: [
              // Living Cartoon House Container
              Expanded(
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: house.themeColor.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🏡 ', style: TextStyle(fontSize: 12)),
                          Text(
                            'HOUSE STAGE',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: PocketAvatarHouseWidget(
                          day: widget.mate.dayLevel,
                          width: 120,
                          height: 75,
                          lightsOn: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // PopArt Card Preview
              Expanded(
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: card.rarityColor.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DEFENSE CARD',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            card.badgeEmoji,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        card.title,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Day ${widget.mate.dayLevel} • 🛡️ Guarding',
                        style: GoogleFonts.inter(
                          color: card.rarityColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 4 Stats Bar: Day Level, Friendship, Stars, Mates
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatPill('🛡️ Day', '${widget.mate.dayLevel}'),
                _buildStatPill('⭐ KS Score', '+${widget.mate.stars > 0 ? widget.mate.stars : 50}'),
                _buildStatPill('❤️ Friendship', '$_friendshipHearts/5'),
                _buildStatPill('🍪 Cookies', '2'),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Main Action Row: ⚔️ ATTACK RAID & 💬 SAFE TALK
          Row(
            children: [
              // ⚔️ ATTACK RAID BUTTON
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    onPressed: _onAttackPressed,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('⚔️ ', style: TextStyle(fontSize: 16)),
                        Text(
                          'ATTACK RAID',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // 💬 SAFE CHAT BUTTON
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _onChatPressed,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('💬 ', style: TextStyle(fontSize: 15)),
                        Text(
                          'TALK',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // 🎁 GIFT COOKIE BUTTON
              SizedBox(
                height: 48,
                width: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: _giftCookie,
                  child: const Text('🍪', style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF94A3B8),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
