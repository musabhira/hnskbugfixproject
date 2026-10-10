import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'english_realm/english_realm_localization_service.dart';
import 'pocket_20days_40games_spec.dart';
import '../pocket_90day_vocab_curriculum.dart';
import 'meadow_runner_game_page.dart';
import 'word_catcher_game_page.dart';
import 'word_catcher_models.dart';
import 'town_quest_dialogue_game_page.dart';
import 'english_realm/english_realm_manifest.dart';
import 'english_realm/english_realm_page.dart';
import 'english_realm/english_realm_game_session_page.dart';

/// 🎮 2D Open-World Daily Arcade Game Modal
///
/// User Audio Directive:
/// - "Games okke onnu professional aakka. Open-world aakka... dark aavaruthu mothathil,
///    kurachu pachappum aakashavum okke ulla pole... oru game kalikkunna feel venam.
///    Full screen aayittu kalikkaan pattanam... 2D best adipoli gamukalundu..."
///
/// Features:
/// - Provides access to the 2 dedicated 2D games registered for Day $day.
/// - Launches full-screen playable 2D Runner (Meadow Runner) or Catcher (Word Catcher)
///   populated with that day's real vocabulary and sentence targets.
class PocketDayArcadeGameModal extends StatelessWidget {
  final int day;
  final VoidCallback? onGameFinished;

  const PocketDayArcadeGameModal({
    super.key,
    required this.day,
    this.onGameFinished,
  });

  static Future<void> show(
    BuildContext context, {
    required int day,
    VoidCallback? onGameFinished,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PocketDayArcadeGameModal(
        day: day,
        onGameFinished: onGameFinished,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final realmGames = EnglishRealmManifest.getGamesForDay(day);

    final dayGames = Pocket20Days40GamesRegistry.allGames
        .where((g) => g.day == day)
        .toList();

    final game1 = realmGames.isNotEmpty
        ? DayGameSpec(
            day: day,
            gameIndex: 1,
            title: realmGames[0].title,
            emoji: realmGames[0].icon,
            genre: GameGenre.runner,
            englishTarget: realmGames[0].subtitle,
            descriptionEn: realmGames[0].descriptionEn,
            descriptionMl: realmGames[0].descriptionMl,
            controlMechanism: 'Interactive 2D game challenges with audio guidance',
          )
        : (dayGames.isNotEmpty
            ? dayGames[0]
            : DayGameSpec(
                day: day,
                gameIndex: 1,
                title: 'Meadow Runner',
                emoji: '🏃',
                genre: GameGenre.runner,
                englishTarget: 'Speed & Vocabulary Recognition',
                descriptionEn: 'Sprint through lush green meadows collecting target words!',
                descriptionMl: 'പച്ചപ്പുല്ല് നിറഞ്ഞ പുൽമേടിലൂടെ ഓടി വാക്കുകൾ ചാടിപ്പിടിക്കുക!',
                controlMechanism: 'Swipe Left/Right to change lanes, Up to jump',
              ));

    final game2 = realmGames.length > 1
        ? DayGameSpec(
            day: day,
            gameIndex: 2,
            title: realmGames[1].title,
            emoji: realmGames[1].icon,
            genre: GameGenre.fallingBlocks,
            englishTarget: realmGames[1].subtitle,
            descriptionEn: realmGames[1].descriptionEn,
            descriptionMl: realmGames[1].descriptionMl,
            controlMechanism: 'Interactive 2D game challenges with audio guidance',
          )
        : (dayGames.length > 1
            ? dayGames[1]
            : DayGameSpec(
                day: day,
                gameIndex: 2,
                title: 'Sky Word Catcher',
                emoji: '🧺',
                genre: GameGenre.fallingBlocks,
                englishTarget: 'Letter & Sentence Catching',
                descriptionEn: 'Catch falling letter blocks and words from sunny clouds!',
                descriptionMl: 'മേഘങ്ങളിൽ നിന്ന് താഴേക്ക് വീഴുന്ന ശരിയായ വാക്കുകൾ ബാസ്കറ്റിൽ പിടിക്കുക!',
                controlMechanism: 'Drag basket or tap falling bubbles before they hit ground',
              ));

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Banner
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0284C7), Color(0xFF10B981)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🎮', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAY $day • 2D OPEN-WORLD ARCADE',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Text(
                        EnglishRealmLocalizationService.t('play_to_learn_subtitle', PocketLanguageService.currentLanguage),
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
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
            const SizedBox(height: 18),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🌍 2D OPEN WORLD REALM PORTAL
                    _buildOpenWorldBanner(context),

                    // GAME 1 CARD
                    _buildGameCard(
                      context,
                      spec: game1,
                      isFirst: true,
                      accentColor: const Color(0xFF38BDF8),
                      onPlay: () => _launchGame1(context),
                    ),
                    const SizedBox(height: 12),

                    // GAME 2 CARD
                    _buildGameCard(
                      context,
                      spec: game2,
                      isFirst: false,
                      accentColor: const Color(0xFF10B981),
                      onPlay: () => _launchGame2(context),
                    ),
                    const SizedBox(height: 12),

                    // GAME 3: TOWN QUEST RPG
                    _buildTownQuestCard(
                      context,
                      accentColor: const Color(0xFFFFB703),
                      onPlay: () => _launchTownQuest(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required DayGameSpec spec,
    required bool isFirst,
    required Color accentColor,
    required VoidCallback onPlay,
  }) {
    final locDesc = spec.getLocalizedDescription(PocketLanguageService.currentLanguage);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B132B).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(spec.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'GAME ${spec.gameIndex}: ${spec.title.toUpperCase()}',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            spec.genre.name.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: accentColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      spec.englishTarget,
                      style: GoogleFonts.inter(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (locDesc.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              locDesc,
              style: GoogleFonts.inter(
                color: const Color(0xFFE2E8F0),
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: onPlay,
              icon: const Icon(Icons.sports_esports_rounded, size: 18),
              label: Text(
                'PLAY FULLSCREEN 2D ARCADE ➔',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenWorldBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF10B981)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            EnglishRealmPage.launch(context, day: day);
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Text('🌍', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ENTER 2D OPEN-WORLD: ENGLISH REALM',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Explore 9 connected regions & play all 180 games in 2D Flame!',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _launchGame1(BuildContext context) {
    HapticFeedback.heavyImpact();
    Navigator.pop(context);

    final realmGames = EnglishRealmManifest.getGamesForDay(day);
    if (realmGames.isNotEmpty) {
      EnglishRealmGameSessionPage.launch(
        context,
        spec: realmGames[0],
        onCompleted: onGameFinished,
      );
      return;
    }

    final currentLang = PocketLanguageService.currentLanguage;
    final vocab = Pocket90DayVocabCurriculum.getVocabForDay(day);
    final rounds = vocab.take(6).map((item) {
      final meaning = item.getMeaning(currentLang);
      return {
        'targetLetter': item.word.isNotEmpty ? item.word[0].toUpperCase() : 'A',
        'targetWord': item.word,
        'meaning': meaning,
        'prompt': 'Catch "${item.word}" ($meaning)',
        'options': [item.word, 'Book', 'Water', 'Tree'],
        'correct': item.word,
      };
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MeadowRunnerGamePage(
          rounds: rounds,
          initialRound: 0,
          isFullscreen: true,
          nativeLanguage: currentLang,
          onAllCompleted: onGameFinished,
        ),
      ),
    );
  }

  void _launchGame2(BuildContext context) {
    HapticFeedback.heavyImpact();
    Navigator.pop(context);

    final realmGames = EnglishRealmManifest.getGamesForDay(day);
    if (realmGames.length > 1) {
      EnglishRealmGameSessionPage.launch(
        context,
        spec: realmGames[1],
        onCompleted: onGameFinished,
      );
      return;
    }

    final vocab = Pocket90DayVocabCurriculum.getVocabForDay(day);
    final items = <WordCatcherItem>[];
    for (int i = 0; i < vocab.length; i++) {
      final v = vocab[i];
      items.add(
        WordCatcherItem(
          id: i + 1,
          word: v.word,
          emoji: '⭐',
          category: v.partOfSpeech,
          phonetics: '/${v.word.toLowerCase()}/',
          definition: v.definition,
          exampleSentence: v.exampleSentence,
          nativeTranslations: {
            'Malayalam': v.malayalamMeaning,
            'Tamil': v.tamilMeaning,
            'Hindi': v.hindiMeaning,
            'Telugu': v.teluguMeaning,
            'Kannada': v.kannadaMeaning,
          },
        ),
      );
    }

    final levelData = WordCatcherLevelData(
      levelNumber: day,
      title: 'Day $day Word Catcher',
      subtitle: 'Catch the falling words into the basket!',
      guideIntro: 'Move your basket to catch target words falling from the sky.',
      introExamples: items.take(2).toList(),
      targetWords: items.isNotEmpty ? items : kWordCatcherLevel1Data.targetWords,
      environmentTheme: 'park',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WordCatcherGamePage(
          levelData: levelData,
          preferredLanguage: PocketLanguageService.currentLanguage,
          onCompleted: (_) => onGameFinished?.call(),
        ),
      ),
    );
  }

  Widget _buildTownQuestCard(
    BuildContext context, {
    required Color accentColor,
    required VoidCallback onPlay,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B132B).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏙️', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'GAME 3: TOWN QUEST RPG',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'NEW 🌟',
                            style: GoogleFonts.outfit(
                              color: accentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Open-World 2D Dialogue Quest',
                      style: GoogleFonts.inter(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            EnglishRealmLocalizationService.t('town_quest_desc', PocketLanguageService.currentLanguage),
            style: GoogleFonts.inter(
              color: const Color(0xFFE2E8F0),
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: onPlay,
              icon: const Icon(Icons.explore_rounded, size: 18),
              label: Text(
                'EXPLORE TOWN QUEST ➔',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchTownQuest(BuildContext context) {
    HapticFeedback.heavyImpact();
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TownQuestDialogueGamePage(
          day: day,
          nativeLanguage: PocketLanguageService.currentLanguage,
          onGameFinished: onGameFinished,
        ),
      ),
    );
  }
}
