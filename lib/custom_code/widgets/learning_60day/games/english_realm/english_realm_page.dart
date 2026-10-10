import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_language_selection_dialog.dart';
import 'english_realm_flame_game.dart';
import 'english_realm_game_session_page.dart';
import 'english_realm_localization_service.dart';
import 'english_realm_manifest.dart';
import 'english_realm_models.dart';
import 'english_realm_progress_service.dart';

/// 🌍 Fullscreen Immersive 2D Open-World Page: "English Realm"
class EnglishRealmPage extends StatefulWidget {
  final int initialDay;

  const EnglishRealmPage({
    super.key,
    this.initialDay = 1,
  });

  static Future<void> launch(BuildContext context, {int day = 1}) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EnglishRealmPage(initialDay: day),
      ),
    );
  }

  @override
  State<EnglishRealmPage> createState() => _EnglishRealmPageState();
}

class _EnglishRealmPageState extends State<EnglishRealmPage> {
  late final EnglishRealmFlameGame _game;
  WorldGameStation? _activeStation;
  int _currentDay = 1;

  // Virtual Joystick touch state
  Offset _joystickOffset = Offset.zero;
  bool _isDraggingJoystick = false;

  @override
  void initState() {
    super.initState();
    _currentDay = widget.initialDay;
    EnglishRealmProgressService.init();
    PocketLanguageService.activeLanguageNotifier.addListener(_onLangChanged);

    _game = EnglishRealmFlameGame(
      initialDay: widget.initialDay,
      onProximityChanged: (station) {
        if (mounted) {
          setState(() {
            _activeStation = station;
            if (station != null) {
              _currentDay = station.day;
            }
          });
        }
      },
      onStationSelected: (station) {
        _launchGame(station);
      },
    );
  }

  void _onLangChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    PocketLanguageService.activeLanguageNotifier.removeListener(_onLangChanged);
    super.dispose();
  }

  void _launchGame(WorldGameStation station) {
    HapticFeedback.heavyImpact();
    final spec = EnglishRealmManifest.getGame(station.day, station.gameIndex);
    if (spec == null) return;

    EnglishRealmGameSessionPage.launch(
      context,
      spec: spec,
      onCompleted: () {
        _game.refreshProgress();
        setState(() {});
      },
    );
  }

  void _openWorldMap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildWorldMapModal(),
    );
  }

  void _teleportTo(int day) {
    Navigator.pop(context);
    setState(() => _currentDay = day);
    _game.teleportToDay(day);
  }

  @override
  Widget build(BuildContext context) {
    final curRegion = EnglishRealmManifest.getRegionForDay(_currentDay);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: Stack(
        children: [
          // 1. Full-screen 2D Flame Game Canvas
          Positioned.fill(
            child: GameWidget(game: _game),
          ),

          // 2. Top Realm Navigation HUD
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopRealmHud(curRegion),
          ),

          // 3. Virtual Joystick on Bottom-Left
          Positioned(
            bottom: 30,
            left: 24,
            child: _buildVirtualJoystick(),
          ),

          // 4. Interactive Game Launch Button on Bottom-Right
          if (_activeStation != null)
            Positioned(
              bottom: 30,
              right: 24,
              child: _buildActiveStationPrompt(_activeStation!),
            ),

          // 5. Controls Guide & Zoom Helper (Top-Right under HUD)
          Positioned(
            top: 90,
            right: 16,
            child: _buildQuickControlsPill(),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // TOP REALM HUD
  // --------------------------------------------------------------------------
  Widget _buildTopRealmHud(RealmRegion region) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: region.primaryColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: region.primaryColor),
              ),
              child: Text(region.icon, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    region.getLocalizedName(PocketLanguageService.currentLanguage).toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: region.primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Day $_currentDay Landmark • English Realm 🌍',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
            // Progress Stats (XP & Coins)
            ValueListenableBuilder<int>(
              valueListenable: EnglishRealmProgressService.totalXpNotifier,
              builder: (_, xp, __) => _buildStatChip('⚡', '$xp XP', const Color(0xFFA855F7)),
            ),
            const SizedBox(width: 6),
            ValueListenableBuilder<int>(
              valueListenable: EnglishRealmProgressService.completedGamesNotifier,
              builder: (_, completed, __) => _buildStatChip('🏆', '$completed/180', const Color(0xFFFFD700)),
            ),
            const SizedBox(width: 6),
            // Language Switcher Badge
            GestureDetector(
              onTap: () async {
                HapticFeedback.selectionClick();
                await PocketLanguageSelectionDialog.show(
                  context,
                  currentLanguage: PocketLanguageService.currentLanguage,
                );
                if (mounted) setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🌐', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      EnglishRealmLocalizationService.getLanguageBadge(PocketLanguageService.currentLanguage),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            // World Map Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _openWorldMap,
              icon: const Icon(Icons.map_rounded, size: 16),
              label: Text('MAP', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String emoji, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.outfit(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // VIRTUAL JOYSTICK (TOUCH / MOBILE CONTROLS)
  // --------------------------------------------------------------------------
  Widget _buildVirtualJoystick() {
    const double radius = 55.0;

    return GestureDetector(
      onPanStart: (details) {
        _isDraggingJoystick = true;
      },
      onPanUpdate: (details) {
        final pos = _joystickOffset + details.delta;
        final dist = pos.distance;
        final clamped = dist > radius ? Offset.fromDirection(pos.direction, radius) : pos;

        setState(() => _joystickOffset = clamped);
        _game.setJoystickInput(clamped.dx / radius, clamped.dy / radius);
      },
      onPanEnd: (_) {
        setState(() {
          _joystickOffset = Offset.zero;
          _isDraggingJoystick = false;
        });
        _game.setJoystickInput(0.0, 0.0);
      },
      onPanCancel: () {
        setState(() {
          _joystickOffset = Offset.zero;
          _isDraggingJoystick = false;
        });
        _game.setJoystickInput(0.0, 0.0);
      },
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF0F172A).withValues(alpha: 0.75),
          border: Border.all(
            color: _isDraggingJoystick ? const Color(0xFF38BDF8) : Colors.white24,
            width: 2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center stick knob
            Transform.translate(
              offset: _joystickOffset,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isDraggingJoystick ? const Color(0xFF38BDF8) : Colors.white70,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.navigation_rounded, color: Colors.black, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // INTERACTIVE STATION PROMPT (ACTION BUTTON)
  // --------------------------------------------------------------------------
  Widget _buildActiveStationPrompt(WorldGameStation station) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: station.color,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 10,
          shadowColor: station.color.withValues(alpha: 0.6),
        ),
        onPressed: () => _launchGame(station),
        icon: Text(station.icon, style: const TextStyle(fontSize: 22)),
        label: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PLAY G${station.gameIndex}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13),
                ),
                if (station.isCompleted) ...[
                  const SizedBox(width: 4),
                  const Text('✓', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ],
            ),
            Text(
              station.title,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // QUICK CONTROLS PILL
  // --------------------------------------------------------------------------
  Widget _buildQuickControlsPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⌨️ WASD/Arrows • Tap or E to Enter', style: TextStyle(color: Colors.white54, fontSize: 9.5)),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              setState(() {
                _game.zoomScale = _game.zoomScale == 1.0 ? 0.65 : 1.0;
              });
            },
            child: Icon(
              _game.zoomScale == 1.0 ? Icons.zoom_out_map_rounded : Icons.center_focus_strong_rounded,
              color: const Color(0xFF38BDF8),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // WORLD MAP MODAL (FAST TRAVEL & PROGRESS)
  // --------------------------------------------------------------------------
  Widget _buildWorldMapModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Color(0xFF0B132B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Text('🗺️', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ENGLISH REALM WORLD MAP',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Fast travel to any region & view all 90 days',
                        style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: EnglishRealmManifest.regions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final r = EnglishRealmManifest.regions[i];
                final isCurrent = r.containsDay(_currentDay);

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131D33),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isCurrent ? r.primaryColor : Colors.white12,
                      width: isCurrent ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(r.icon, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.getLocalizedName(PocketLanguageService.currentLanguage),
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                  ),
                                ),
                                Text(
                                  'Days ${r.startDay}–${r.endDay} • ${r.landmark}',
                                  style: GoogleFonts.inter(color: r.primaryColor, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: r.primaryColor,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => _teleportTo(r.startDay),
                            child: Text(
                              'TELEPORT ➔',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 10.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Grid of Days in this region
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: List.generate(r.endDay - r.startDay + 1, (idx) {
                          final dayNum = r.startDay + idx;
                          final isSelected = dayNum == _currentDay;

                          return InkWell(
                            onTap: () => _teleportTo(dayNum),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 44,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSelected ? r.primaryColor : const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.white12,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'D$dayNum',
                                style: GoogleFonts.outfit(
                                  color: isSelected ? Colors.black : Colors.white70,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
