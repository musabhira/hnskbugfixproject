import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'dart:math' as math;
import 'pocket_fortress_defense_service.dart';
import 'learning_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/english_hub_level_group_service.dart';

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
        id: 'speaking_drill_$day',
        title: '🎙️ Master Day $day Speaking Drill',
        description: 'Record and practice pronunciation for today\'s target phrase',
        emoji: '🎙️',
        points: 30,
        targetMinutes: 25,
      ),
      DailyEnglishTask(
        id: 'grammar_mechanics_$day',
        title: '🧠 Core Thought Mechanics & Grammar',
        description: 'Understand and apply today\'s structural sentence rule',
        emoji: '🧠',
        points: 30,
        targetMinutes: 30,
      ),
    ];
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
      final localStage = prefs.getInt('pocket_learning_user_stage') ?? prefs.getInt('learning_day_$userId') ?? 1;
      if (localStage > day) {
        day = localStage;
      }

      // Midnight Progression: Check if previous day was completed and midnight has passed
      final lastCompletedDay = prefs.getInt('learning_last_completed_day') ?? 0;
      if (lastCompletedDay > 0 && lastCompletedDay < 90) {
        final completedDateStr = prefs.getString('learning_day_${lastCompletedDay}_completed_date');
        final todayDateStr = '${now.year}-${now.month}-${now.day}';
        // If completed date is earlier than today, midnight has passed -> enter next day!
        if (completedDateStr != null && completedDateStr != todayDateStr) {
          if (day <= lastCompletedDay) {
            day = lastCompletedDay + 1;
            await prefs.setInt('learning_day_$userId', day);
            await prefs.setInt('pocket_learning_user_stage', day);
            await prefs.setBool('pocket_day_${day}_unlocked', true);
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

  /// Completes a day's mission, records 200 pts / score, unlocks next day, and syncs
  Future<UserLearningProgress> completeDailyMission({
    required String userId,
    required int day,
    required int earnedPoints, // Up to 200 points
    bool advanceToNextDay = true,
  }) async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final todayStr = '${now.year}-${now.month}-${now.day}';

    // 1. Mark current day completed
    await prefs.setBool('pocket_day_${day}_completed', true);
    await prefs.setString('learning_day_${day}_completed_date', todayStr);
    await prefs.setInt('learning_day_${day}_completed_timestamp', now.millisecondsSinceEpoch);
    await prefs.setInt('learning_last_completed_day', day);

    // 2. Unlock next day
    final nextDay = (day < 90) ? day + 1 : 90;
    await prefs.setBool('pocket_day_${nextDay}_unlocked', true);

    // 3. Fetch progress & increment points
    await PocketFortressDefenseService.awardPoints(earnedPoints);
    var progress = await fetchProgress(userId);
    final newPoints = progress.totalPoints;
    final newStreak = progress.streakDays + 1;
    final targetDay = advanceToNextDay ? nextDay : progress.currentDay;
    final stage = LearningMilestoneStage.getStageForDay(targetDay);

    await prefs.setInt('learning_day_$userId', targetDay);
    await prefs.setInt('pocket_learning_user_stage', targetDay);
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
    await prefs.setInt('pocket_learning_user_stage', clamped);
    await prefs.setBool('pocket_day_${clamped}_unlocked', true);
    await prefs.setBool('pocket_world_rules_accepted_v1', true);
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
