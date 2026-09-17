import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'dart:math' as math;
import 'pocket_fortress_defense_service.dart';
import 'learning_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/english_hub_level_group_service.dart';
import 'package:pocket_mates_app/services/push_notification_service.dart';

/// Core Service managing 90-Stage Progression, Pocket Score, Inactivity Decay & Profile UI sync
class Learning60DayService {
  static final Learning60DayService _instance = Learning60DayService._internal();
  factory Learning60DayService() => _instance;
  Learning60DayService._internal();

  final _supabase = SupaFlow.client;

  /// Curated Media Data for a given day (Supports dynamic Admin overrides)
  static Map<String, dynamic> getCuratedMediaForDay(int day) {
    final clamped = day.clamp(1, 90);
    
    // Curated educational video clips, podcasts and movie recommendations
    final Map<int, Map<String, dynamic>> curatedCatalog = {
      1: {
        'title': 'Daily Greetings & Social Small Talk',
        'youtubeUrl': 'https://www.youtube.com/watch?v=Fw0rdhmsrqA',
        'movie': 'The Terminal (2004) — Clear, simple English expressions and heartwarming conversational resilience.',
        'phrases': ['How is it going?', 'Nice to meet you in person!', 'Catch up with you later!'],
      },
      2: {
        'title': 'Ordering at a Cafe & Asking for Help',
        'youtubeUrl': 'https://www.youtube.com/watch?v=kC85m53Wj0M',
        'movie': 'Notting Hill (1999) — Charming British-American dialogue with natural cafe interactions.',
        'phrases': ['Could I get a latte, please?', 'Keep the change', 'Do you mind if I sit here?'],
      },
      3: {
        'title': 'Expressing Opinions & Agreeing/Disagreeing',
        'youtubeUrl': 'https://www.youtube.com/watch?v=0k2Zzkw4YwA',
        'movie': '12 Angry Men (1957) — The gold standard for respectful, persuasive debates and expressing opinions.',
        'phrases': ['From my perspective...', 'I see your point, but...', 'I couldn\'t agree more!'],
      },
      5: {
        'title': 'Mastering Connected Speech & Reductions',
        'youtubeUrl': 'https://www.youtube.com/watch?v=P2ZkWK0F0-0',
        'movie': 'Dead Poets Society (1989) — Beautiful articulation, expressive speech, and emotional storytelling.',
        'phrases': ['Wanna (want to)', 'Gonna (going to)', 'Gotcha (got you)'],
      },
      10: {
        'title': 'Job Interview Essentials & Self-Introduction',
        'youtubeUrl': 'https://www.youtube.com/watch?v=1mHjMNZZvFo',
        'movie': 'The Pursuit of Happyness (2006) — Inspiring professional communication and confident speaking.',
        'phrases': ['My core strength lies in...', 'I pride myself on...', 'Overcoming challenges'],
      },
      20: {
        'title': 'Natural Idioms Native Speakers Use Every Day',
        'youtubeUrl': 'https://www.youtube.com/watch?v=TI11370NqY0',
        'movie': 'The Social Network (2010) — Fast-paced contemporary English filled with modern idioms.',
        'phrases': ['Bite the bullet', 'Hit the nail on the head', 'Piece of cake'],
      },
      30: {
        'title': 'TED Talk: How to Speak so People Want to Listen',
        'youtubeUrl': 'https://www.youtube.com/watch?v=eIho2S0ZahI',
        'movie': 'The King\'s Speech (2010) — The definitive masterpiece on vocal confidence and overcoming speech anxiety.',
        'phrases': ['Vocal variety', 'Authenticity', 'Conveying passion through tone'],
      },
      60: {
        'title': 'Advanced English Podcast: Critical Thinking & Nuance',
        'youtubeUrl': 'https://www.youtube.com/watch?v=1x0tF1E2m_o',
        'movie': 'Inception (2010) — Sophisticated storytelling with complex sentence structures and varied accents.',
        'phrases': ['In essence...', 'Paradoxical situation', 'Underlying premise'],
      },
      90: {
        'title': 'Fluent Mastery: The Art of Storytelling in English',
        'youtubeUrl': 'https://www.youtube.com/watch?v=Nj-hdQMa3uA',
        'movie': 'Forrest Gump (1994) — Timeless narrative storytelling with emotional simplicity and rich vocabulary.',
        'phrases': ['To make a long story short', 'It turned out that...', 'Looking back on it'],
      },
    };

    if (curatedCatalog.containsKey(clamped)) {
      return curatedCatalog[clamped]!;
    }

    // Default fallback pattern across the 90-day journey
    final tier = clamped <= 30 ? 'Fundamental Everyday Dialogue' : (clamped <= 60 ? 'Intermediate Fluency & Movie Analysis' : 'Advanced Communication & Leadership Podcast');
    return {
      'title': 'Stage $clamped: $tier',
      'youtubeUrl': 'https://www.youtube.com/results?search_query=english+conversation+practice+stage+$clamped',
      'movie': clamped % 2 == 0 ? 'Cast Away (2000) — Clear, simple English storytelling.' : 'Catch Me If You Can (2002) — Confident, charismatic dialogue.',
      'phrases': ['Natural pauses', 'Clear enunciation', 'Contextual response'],
    };
  }

  /// Daily practical tasks template (Includes YouTube & Podcast Listening)
  List<DailyEnglishTask> generateTodayTasks(int day) {
    final media = getCuratedMediaForDay(day);
    final String ytUrl = media['youtubeUrl'] ?? '';
    final String movie = media['movie'] ?? '';
    final List<String> phrases = List<String>.from(media['phrases'] ?? []);

    return [
      DailyEnglishTask(
        id: 'listen_absorb_$day',
        title: '🎧 Listen & Absorb: ${media['title']}',
        description: 'Watch the curated YouTube video/podcast snippet and catch native pronunciations.',
        emoji: '🎧',
        points: 25,
        targetMinutes: 15,
        mediaType: 'youtube',
        mediaUrl: ytUrl,
        recommendedMovie: movie,
        keyListeningPhrases: phrases,
      ),
      DailyEnglishTask(
        id: 'speaking_drill_$day',
        title: '🎙️ Master Day $day Speaking Drill',
        description: 'Shadow native pronunciation: record 30 seconds repeating your favorite line from today\'s clip.',
        emoji: '🎙️',
        points: 30,
        targetMinutes: 25,
      ),
      DailyEnglishTask(
        id: 'grammar_mechanics_$day',
        title: '🧠 Core Thought Mechanics & Phrases',
        description: 'Understand and apply today\'s structural phrase rule without translating word-for-word.',
        emoji: '🧠',
        points: 25,
        targetMinutes: 20,
      ),
      const DailyEnglishTask(
        id: 'peer_chat_4_mates',
        title: '💬 Talk with Mates in Anonymous Chat',
        description: 'Engage in 20–25 mins of real-time peer practice (English only)',
        emoji: '💬',
        points: 20,
        targetMinutes: 25,
      ),
    ];
  }

  /// Save dynamic admin override for a specific day's listening task
  static Future<void> saveMediaOverride({
    required int day,
    required String youtubeUrl,
    required String recommendedMovie,
    required List<String> keyPhrases,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_learning_media_${day}_youtube', youtubeUrl);
    await prefs.setString('admin_learning_media_${day}_movie', recommendedMovie);
    await prefs.setStringList('admin_learning_media_${day}_phrases', keyPhrases);

    // Also sync to Supabase app_tool_configs for global distribution across devices
    try {
      final supabase = SupaFlow.client;
      await supabase.from('app_tool_configs').upsert({
        'config_key': 'learning_task_day_$day',
        'config_value': {
          'day': day,
          'youtube_url': youtubeUrl,
          'recommended_movie': recommendedMovie,
          'key_phrases': keyPhrases,
          'updated_at': DateTime.now().toIso8601String(),
        },
      }, onConflict: 'config_key');
    } catch (e) {
      debugPrint('Syncing learning task media to Supabase: $e');
    }
  }

  /// Fetches real-time user progress from Supabase & SharedPreferences
  Future<UserLearningProgress> fetchProgress(String userId) async {
    final now = DateTime.now();
    try {
      final res = await _supabase
          .from('profile')
          .select('learning_day, learning_stage, learning_points, learning_streak, last_learning_date, bg_color_code, button_color_code')
          .eq('user_id', userId)
          .maybeSingle();

      int day = 1;
      int pocketScore = await PocketFortressDefenseService.getUnifiedScore(userId);
      int streak = 1;
      DateTime lastDate = now;

      if (res != null) {
        day = (res['learning_day'] as num?)?.toInt() ?? 1;
        streak = (res['learning_streak'] as num?)?.toInt() ?? 1;
        if (res['last_learning_date'] != null) {
          lastDate = DateTime.tryParse(res['last_learning_date'].toString()) ?? now;
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        day = prefs.getInt('learning_day_$userId') ?? 1;
        streak = prefs.getInt('learning_streak_$userId') ?? 1;
      }

      final prefs = await SharedPreferences.getInstance();
      final localStage = prefs.getInt('pocket_learning_user_stage_$userId') ?? prefs.getInt('learning_day_$userId') ?? day;
      if (localStage > day && res == null) {
        day = localStage;
      }

      // Midnight Progression: Check if previous day was completed and midnight has passed
      final lastCompletedDay = prefs.getInt('learning_last_completed_day_$userId') ?? 0;
      if (lastCompletedDay > 0 && lastCompletedDay < 90) {
        final completedDateStr = prefs.getString('learning_day_${userId}_${lastCompletedDay}_completed_date');
        final todayDateStr = '${now.year}-${now.month}-${now.day}';
        // If completed date is earlier than today, midnight has passed -> enter next day!
        if (completedDateStr != null && completedDateStr != todayDateStr) {
          if (day <= lastCompletedDay) {
            day = lastCompletedDay + 1;
            await prefs.setInt('learning_day_$userId', day);
            await prefs.setInt('pocket_learning_user_stage_$userId', day);
            await prefs.setBool('pocket_day_${userId}_${day}_unlocked', true);
            PushNotificationService.showMissionUnlockedNotification(day: day);
          }
        }
      }

      // ----------------------------------------------------
      // Pocket Score & Inactivity Decay Engine
      // ----------------------------------------------------
      bool hasInactivityPenalty = false;
      int missedDays = 0;

      if (res != null && res['last_learning_date'] != null) {
        final differenceInDays = DateTime(now.year, now.month, now.day)
            .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
            .inDays;

        if (differenceInDays > 1 && day > 1) {
          missedDays = differenceInDays - 1;
          hasInactivityPenalty = true;

          // Reset streak
          streak = 1;
          // Deduct Pocket Score for missed days
          pocketScore = (pocketScore - (missedDays * 30)).clamp(0, 999999);
          await PocketFortressDefenseService.setUnifiedScore(pocketScore, userId);

          // Never decay below localStage if user unlocked it in current session
          day = math.max(localStage, (day - missedDays).clamp(1, 90));

          // Persist decayed values
          await prefs.setInt('learning_day_$userId', day);
          await prefs.setInt('learning_streak_$userId', streak);

          try {
            await _supabase.from('profile').update({
              'learning_day': day,
              'learning_stage': day,
              'learning_points': pocketScore,
              'learning_streak': streak,
              'last_learning_date': now.toIso8601String(),
            }).eq('user_id', userId);
          } catch (_) {}
        }
      }

      final currentStage = LearningMilestoneStage.getStageForDay(day);

      // Load today's tasks
      final todayKey = 'tasks_${userId}_${now.year}_${now.month}_${now.day}';
      final completedTaskIds = prefs.getStringList(todayKey) ?? [];

      int minutesToday = 0;
      final tasks = generateTodayTasks(day).map((t) {
        final isDone = completedTaskIds.contains(t.id);
        if (isDone) minutesToday += t.targetMinutes;
        return t.copyWith(isCompleted: isDone);
      }).toList();

      return UserLearningProgress(
        currentDay: day.clamp(1, 90),
        currentStage: currentStage.stageNumber,
        streakDays: streak,
        totalPoints: pocketScore,
        minutesPracticedToday: minutesToday,
        targetDailyMinutes: 90,
        missedDaysCount: missedDays,
        hasInactivityWarning: hasInactivityPenalty,
        lastActiveDate: lastDate,
        todayTasks: tasks,
      );
    } catch (e) {
      debugPrint('Learning60DayService.fetchProgress error: $e');
      return UserLearningProgress(
        currentDay: 1,
        currentStage: 1,
        streakDays: 1,
        totalPoints: 0,
        lastActiveDate: now,
        todayTasks: generateTodayTasks(1),
      );
    }
  }

  /// Marks task as completed, increases Pocket Score, advances Day/Stage, and updates profile colors
  Future<UserLearningProgress> completeTask({
    required String userId,
    required String taskId,
  }) async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final todayKey = 'tasks_${userId}_${now.year}_${now.month}_${now.day}';
    final completedTaskIds = prefs.getStringList(todayKey) ?? [];

    if (!completedTaskIds.contains(taskId)) {
      completedTaskIds.add(taskId);
      await prefs.setStringList(todayKey, completedTaskIds);
    }

    var progress = await fetchProgress(userId);
    final task = progress.todayTasks.firstWhere((t) => t.id == taskId, orElse: () => progress.todayTasks.first);
    final earnedPoints = task.points;

    int newPoints = progress.totalPoints + earnedPoints;
    int newDay = progress.currentDay;
    int newStreak = progress.streakDays;

    final allCompleted = completedTaskIds.length >= progress.todayTasks.length;
    if (allCompleted) {
      final lastAdvanceKey = 'last_advance_$userId';
      final lastAdvanceStr = prefs.getString(lastAdvanceKey);
      final todayDateStr = '${now.year}-${now.month}-${now.day}';

      if (lastAdvanceStr != todayDateStr) {
        newDay = (newDay + 1).clamp(1, 90);
        newStreak = newStreak + 1;
        await prefs.setString(lastAdvanceKey, todayDateStr);
      }
    }

    final newStage = LearningMilestoneStage.getStageForDay(newDay);

    await prefs.setInt('learning_day_$userId', newDay);
    await prefs.setInt('learning_points_$userId', newPoints);
    await prefs.setInt('learning_streak_$userId', newStreak);

    try {
      await _supabase.from('profile').update({
        'learning_day': newDay,
        'learning_stage': newStage.stageNumber,
        'learning_points': newPoints,
        'learning_streak': newStreak,
        'last_learning_date': now.toIso8601String(),
      }).eq('user_id', userId);
    } catch (e) {
      debugPrint('Learning60DayService sync error: $e');
    }

    return fetchProgress(userId);
  }

  /// Returns the remaining Duration until next midnight (12:00 AM / 00:00)
  static Duration getRemainingTimeUntilMidnight() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now);
  }

  /// Formats remaining time as "04h : 22m : 15s"
  static String formatRemainingCountdown(Duration duration) {
    if (duration.isNegative) return '00h : 00m : 00s';
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '${hours}h : ${minutes}m : ${seconds}s';
  }

  /// Checks if day is waiting for midnight unlock (completed previous day today, next day not yet unlocked)
  static Future<bool> isDayWaitingForMidnightUnlock(int day, {String? userId}) async {
    final uid = userId ?? SupaFlow.client.auth.currentUser?.id;
    if (uid == null) return false;
    final prefs = await SharedPreferences.getInstance();
    final lastCompletedDay = prefs.getInt('learning_last_completed_day_$uid') ?? 0;
    if (day != lastCompletedDay + 1) return false;
    final completedDateStr = prefs.getString('learning_day_${uid}_${lastCompletedDay}_completed_date');
    if (completedDateStr == null) return false;
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';
    return completedDateStr == todayStr;
  }

  /// Completes a day's mission, records earned points, records completion,
  /// locks the next day until midnight (12:00 AM), and schedules morning notification.
  Future<UserLearningProgress> completeDailyMission({
    required String userId,
    required int day,
    required int earnedPoints, // Up to 200 points
    bool advanceToNextDay = false, // Next day unlocks at midnight per user specification
  }) async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final todayStr = '${now.year}-${now.month}-${now.day}';

    // 1. Mark current day completed for this user
    await prefs.setBool('pocket_day_${userId}_${day}_completed', true);
    await prefs.setString('learning_day_${userId}_${day}_completed_date', todayStr);
    await prefs.setInt('learning_day_${userId}_${day}_completed_timestamp', now.millisecondsSinceEpoch);
    await prefs.setInt('learning_last_completed_day_$userId', day);

    // 2. Schedule morning notification for next day (at 8:30 AM)
    final nextDay = (day < 90) ? day + 1 : 90;
    PushNotificationService.scheduleMorningMissionNotification(day: nextDay);

    // If advanceToNextDay is explicitly true (e.g. in developer test / fast forward), unlock nextDay immediately
    if (advanceToNextDay) {
      await prefs.setBool('pocket_day_${userId}_${nextDay}_unlocked', true);
    }

    // 3. Fetch progress & increment points
    await PocketFortressDefenseService.awardPoints(earnedPoints);
    var progress = await fetchProgress(userId);
    final newPoints = progress.totalPoints;
    final newStreak = progress.streakDays + 1;
    final targetDay = advanceToNextDay ? nextDay : day;
    final stage = LearningMilestoneStage.getStageForDay(targetDay);

    await prefs.setInt('learning_day_$userId', targetDay);
    await prefs.setInt('pocket_learning_user_stage_$userId', targetDay);
    await prefs.setInt('learning_points_$userId', newPoints);
    await prefs.setInt('learning_streak_$userId', newStreak);

    try {
      await _supabase.from('profile').update({
        'learning_day': targetDay,
        'learning_stage': stage.stageNumber,
        'learning_points': newPoints,
        'learning_streak': newStreak,
        'last_learning_date': now.toIso8601String(),
      }).eq('user_id', userId);

      await EnglishHubLevelGroupService.ensureUserInLevelGroup(
        userLevel: targetDay,
        userId: userId,
        forceLevelMatch: true,
      );
    } catch (e) {
      debugPrint('completeDailyMission sync error: $e');
    }

    return fetchProgress(userId);
  }

  /// Sets a specific day for testing / fast-forwarding
  Future<void> jumpToDay(String userId, int targetDay) async {
    final prefs = await SharedPreferences.getInstance();
    final clamped = targetDay.clamp(1, 90);
    final stage = LearningMilestoneStage.getStageForDay(clamped);

    await prefs.setInt('learning_day_$userId', clamped);
    await prefs.setInt('pocket_learning_user_stage_$userId', clamped);
    await prefs.setBool('pocket_day_${userId}_${clamped}_unlocked', true);
    await prefs.setBool('pocket_world_rules_accepted_${userId}_v1', true);
    await prefs.setString('last_learning_date', DateTime.now().toIso8601String());

    try {
      await _supabase.from('profile').update({
        'learning_day': clamped,
        'learning_stage': stage.stageNumber,
        'last_learning_date': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      await EnglishHubLevelGroupService.ensureUserInLevelGroup(
        userLevel: clamped,
        userId: userId,
        forceLevelMatch: true,
      );
    } catch (e) {
      debugPrint('jumpToDay error: $e');
    }
  }

  /// Sets a specific stage for testing / fast-forwarding
  Future<void> applyStagePaletteToProfile(String userId, int stageNumber) async {
    final stage = LearningMilestoneStage.getStageForDay(stageNumber);

    try {
      await _supabase.from('profile').update({
        'learning_day': stage.stageNumber,
        'learning_stage': stage.stageNumber,
        'bg_color_code': stage.bgHex,
        'bg_text_color': stage.textHex,
        'button_color_code': stage.buttonHex,
        'button_text_color': stage.buttonTextHex,
      }).eq('user_id', userId);
    } catch (e) {
      debugPrint('applyStagePaletteToProfile error: $e');
    }
  }
}
