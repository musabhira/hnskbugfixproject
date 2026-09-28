import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import '/backend/supabase/supabase.dart';
import 'whatsapp_group_chat.dart';
import 'package:shimmer/shimmer.dart';

import 'english_hub_level_group_service.dart';
import 'audio_space/pocket_audio_spaces_lobby_page.dart';
import 'pocket_homes_reels_feed_widget.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:flutter/services.dart';

class EnglishLearningGroupChatWidget extends ConsumerStatefulWidget {
  final VoidCallback onCancel;

  const EnglishLearningGroupChatWidget({
    super.key,
    required this.onCancel,
  });

  @override
  ConsumerState<EnglishLearningGroupChatWidget> createState() =>
      _EnglishLearningGroupChatWidgetState();
}

class _EnglishLearningGroupChatWidgetState
    extends ConsumerState<EnglishLearningGroupChatWidget> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  bool _isMember = false;
  String? _groupId;
  String? _groupName;
  EnglishHubLevelGroup? _levelGroup;
  String? _currentUserProfileId;
  String? _currentUserId;
  int _selectedHubTab = 1; // 0 = Spaces (Left), 1 = Chat (Center), 2 = Homes (Right)
  int _homesEpoch = 0; // Incremented when switching back to Homes tab to auto-refresh seen items
  late PageController _hubPageController;

  @override
  void initState() {
    super.initState();
    _hubPageController = PageController(initialPage: _selectedHubTab);
    _currentUserId = _supabase.auth.currentUser?.id;
    // Initial tab is Chat (tab 1) - ensure BGM is quiet during chat
    PocketGameAudioService.instance.pause();
    _initGroupAndMembership();
  }

  @override
  void dispose() {
    PocketGameAudioService.instance.stop();
    _hubPageController.dispose();
    super.dispose();
  }

  Future<void> _initGroupAndMembership() async {
    if (_currentUserId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // 1. Get user profile
      final profileResponse = await _supabase
          .from('profile')
          .select('id')
          .eq('user_id', _currentUserId!)
          .maybeSingle();
      _currentUserProfileId = profileResponse?['id']?.toString() ?? _currentUserId!;

      // 2. Resolve user's current learning level
      final userLevel = await EnglishHubLevelGroupService.resolveCurrentUserLevel();

      // 3. Ensure user is in their level group & auto-leaves older level groups
      final matchedGroup = await EnglishHubLevelGroupService.ensureUserInLevelGroup(
        userLevel: userLevel,
        userId: _currentUserId!,
        profileId: _currentUserProfileId,
        forceLevelMatch: true,
      );

      _groupId = matchedGroup.groupId;
      _groupName = matchedGroup.groupName;
      _levelGroup = matchedGroup;
      _isMember = true;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error initializing dynamic English Hub level group: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildShimmerLoading(BuildContext context) {
    const baseColor = Color(0xFF1E293B);
    const highlightColor = Color(0xFF334155);
    const darkBg = Color(0xFF070B0D);
    const appBarColor = Color(0xFF121B22);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 12,
        title: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: baseColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 110,
                    height: 14,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 65,
                    height: 10,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: ListView.builder(
          reverse: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 14,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          itemBuilder: (context, index) {
            final isMe = index % 2 == 0;
            final bubbleWidths = [170.0, 240.0, 130.0, 210.0, 280.0, 150.0, 220.0];
            final width = bubbleWidths[index % bubbleWidths.length];
            final height = (index % 3 == 0) ? 56.0 : ((index % 3 == 1) ? 40.0 : 48.0);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isMe) ...[
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: baseColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                        bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSegmentedHeader() {
    return Container(
      color: const Color(0xFF0A0F1D),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 2,
        bottom: 4,
        left: 8,
        right: 8,
      ),
      child: Row(
        children: [
          // Back button to exit English Hub
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white70, size: 16),
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            onPressed: widget.onCancel,
          ),
          const SizedBox(width: 6),

          // Ultra-minimal icons-only pill switcher: Spaces (Left) | Chat (Center) | Homes (Right)
          Expanded(
            child: Container(
              height: 38,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFF141C2B),
                borderRadius: BorderRadius.circular(19),
                border: Border.all(color: const Color(0xFF26334D), width: 0.8),
              ),
              child: Row(
                children: [
                  // Tab 0 (Left): 🎙️ Spaces
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _hubPageController.animateToPage(
                          0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedHubTab == 0
                              ? const Color(0xFFFFFC00)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🎙️', style: TextStyle(fontSize: 16)),
                              if (_selectedHubTab != 0) ...[
                                const SizedBox(width: 3),
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Tab 1 (Center): 💬 Chat
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _hubPageController.animateToPage(
                          1,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedHubTab == 1
                              ? const Color(0xFFFFFC00)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text('💬', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                  ),

                  // Tab 2 (Right): 🏰 Homes
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _hubPageController.animateToPage(
                          2,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedHubTab == 2
                              ? const Color(0xFFFFFC00)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text('🏰', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return _buildGuestLanding(context);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF070B0D),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF070B0D),
        body: Column(
          children: [
            _buildSegmentedHeader(),
            Expanded(
              child: PageView(
                controller: _hubPageController,
                onPageChanged: (idx) {
                  HapticFeedback.selectionClick();
                  // Audio Directive: When on Chat (tab 1) or Voice Spaces (tab 0), silence background music
                  if (idx != 2) {
                    PocketGameAudioService.instance.pause();
                  }
                  setState(() {
                    if (idx == 2 && _selectedHubTab != 2) {
                      _homesEpoch++;
                    }
                    _selectedHubTab = idx;
                  });
                },
                children: [
                  // 0 (Left): Live Voice Spaces
                  const PocketAudioSpacesLobbyPage(
                    showHeader: false,
                    enableSafeArea: false,
                  ),

                  // 1 (Center): Level Chat
                  _isLoading
                      ? _buildShimmerLoading(context)
                      : (_isMember && _groupId != null
                          ? MediaQuery.removePadding(
                              context: context,
                              removeTop: true,
                              child: WhatsAppGroupChat(
                                groupId: _groupId!,
                                groupName: _groupName ??
                                    _levelGroup?.groupName ??
                                    'English Hub (All Learners • Lvl 1 - 90)',
                                showBackButton: false,
                              ),
                            )
                          : _buildErrorState(context)),

                // 2 (Right): Homes (Reels-style Homestead & Attack Feed)
                PocketHomesReelsFeedWidget(
                  key: ValueKey('homes_reel_$_homesEpoch'),
                  userLevel: _levelGroup?.minLevel ?? 1,
                  isActive: _selectedHubTab == 2,
                  onBackToChat: () {
                    _hubPageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.group_off_rounded, color: Colors.white54, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Unable to connect to group right now.',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() => _isLoading = true);
                _initGroupAndMembership();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFC00),
                foregroundColor: Colors.black,
              ),
              child: const Text('Retry Connection'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestLanding(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121B22),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: widget.onCancel,
        ),
        title: Text(
          'English Learning Hub',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFFC00).withValues(alpha: 0.1),
                  border: Border.all(color: const Color(0xFFFFFC00), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFFC00).withValues(alpha: 0.25),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('👥', style: TextStyle(fontSize: 42)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Join English Learning Groups',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Group chats and study brackets require an active user account. Log in to connect with peers at your stage, practice English daily, and earn XP streaks.',
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => AuthAlertBox.checkAuthAndShowAlert(
                    context: context,
                    customMessage: "Please login to access Group Chats and English Hub",
                  ),
                  icon: const Icon(Icons.login_rounded, color: Colors.black),
                  label: Text(
                    'Log In / Sign Up',
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFC00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: widget.onCancel,
                child: Text(
                  'Return to Chats',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF94A3B8),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
