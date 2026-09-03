import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'learning_models.dart';

/// Core Service managing 90-Stage Progression, Pocket Score, Inactivity Decay & Profile UI sync
class Learning60DayService {
  static final Learning60DayService _instance = Learning60DayService._internal();
  factory Learning60DayService() => _instance;
  Learning60DayService._internal();

  final _supabase = SupaFlow.client;

  /// Daily practical tasks template (Target: ~90 mins / 1.5 hours)
  List<DailyEnglishTask> generateTodayTasks(int day) {
    return [
      const DailyEnglishTask(
        id: 'peer_chat_4_mates',
        title: '💬 Talk with 4 Mates in Anonymous Chat',
        description: 'Engage in 30–35 mins of real-time peer practice (English only)',
        emoji: '💬',
        points: 40,
        targetMinutes: 35,
      ),
      DailyEnglishTask(
        id: 'speech_interview_sprint',
        title: day <= 15
            ? '🎙️ Self-Introduction & Vocal Confidence'
            : (day <= 30
                ? '🎙️ 20-Min Fluency & Pronunciation Sprint'
                : (day <= 45
                    ? '🎙️ Mock Interview & Professional Pitch'
                    : '🎙️ Impromptu Monologue & Debate Sprint')),
        description: 'Record continuous spoken English without hesitation or native lag',
        emoji: '🎙️',
        points: 30,
        targetMinutes: 20,
      ),
      const DailyEnglishTask(
        id: 'pocket_library_reading',
        title: '📖 Pocket Library Word & Audio Reading',
        description: 'Read 1 classic story or news article aloud with audio reader',
        emoji: '📖',
        points: 20,
        targetMinutes: 15,
      ),
      const DailyEnglishTask(
        id: 'grammar_and_vocab_boost',
        title: '🧠 Grammar & 5 Smart Vocabulary Words',
        description: 'Master practical sentence structures and active idioms',
        emoji: '🧠',
        points: 15,
        targetMinutes: 20,
      ),
    ];
  }

  /// Fetches the user's current 90-Stage progress & evaluates Pocket Score Inactivity Decay
  Future<UserLearningProgress> fetchProgress(String userId) async {
    final now = DateTime.now();
    try {
      final res = await _supabase
          .from('profile')
          .select('learning_day, learning_stage, learning_points, learning_streak, last_learning_date, bg_color_code, button_color_code')
          .eq('user_id', userId)
          .maybeSingle();

      int day = 1;
      int pocketScore = 0;
      int streak = 1;
      DateTime lastDate = now;

      if (res != null) {
        day = (res['learning_day'] as num?)?.toInt() ?? 1;
        pocketScore = (res['learning_points'] as num?)?.toInt() ?? 0;
        streak = (res['learning_streak'] as num?)?.toInt() ?? 1;
        if (res['last_learning_date'] != null) {
          lastDate = DateTime.tryParse(res['last_learning_date'].toString()) ?? now;
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        day = prefs.getInt('learning_day_$userId') ?? 1;
        pocketScore = prefs.getInt('learning_points_$userId') ?? 0;
        streak = prefs.getInt('learning_streak_$userId') ?? 1;
      }

      // ----------------------------------------------------
      // Pocket Score & Inactivity Decay Engine
      // ----------------------------------------------------
      final differenceInDays = DateTime(now.year, now.month, now.day)
          .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
          .inDays;

      bool hasInactivityPenalty = false;
      int missedDays = 0;

      if (differenceInDays > 1) {
        missedDays = differenceInDays - 1;
        hasInactivityPenalty = true;

        // Reset streak
        streak = 1;
        // Deduct Pocket Score for missed days
        pocketScore = (pocketScore - (missedDays * 30)).clamp(0, 999999);
        
        // If inactive, step back stages/days proportionally (1 day per missed day, minimum 1)
        day = (day - missedDays).clamp(1, 90);

        // Persist decayed values
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('learning_day_$userId', day);
        await prefs.setInt('learning_points_$userId', pocketScore);
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

      final currentStage = LearningMilestoneStage.getStageForDay(day);

      // Load today's tasks
      final prefs = await SharedPreferences.getInstance();
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
