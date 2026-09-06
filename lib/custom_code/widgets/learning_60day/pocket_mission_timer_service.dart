import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ⏱️ Persistent Daily 60-Minute Practice Timer Service
/// Handles:
/// 1. Local persistence (SharedPreferences) per learning day.
/// 2. Automatic pause when the app is sent to the background (lifecycle observer).
/// 3. Clamping at 60 minutes (does not tick past 60:00 unless user extends).
/// 4. Extra hour / restart option if subtasks remain incomplete after 60 minutes.
/// 5. Global state broadcasting to keep in-app navigation connected to the timer.
class PocketMissionTimerService extends ChangeNotifier with WidgetsBindingObserver {
  static final PocketMissionTimerService _instance = PocketMissionTimerService._internal();
  static PocketMissionTimerService get instance => _instance;

  PocketMissionTimerService._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  static const int defaultTargetSeconds = 3600; // 60 minutes

  int _day = 1;
  int _elapsedSeconds = 0;
  int _targetSeconds = defaultTargetSeconds;
  bool _isRunning = false;
  bool _isInitialized = false;
  String _pauseReason = 'Paused';
  Timer? _ticker;

  int get day => _day;
  int get elapsedSeconds => _elapsedSeconds;
  int get targetSeconds => _targetSeconds;
  bool get isRunning => _isRunning;
  bool get isInitialized => _isInitialized;
  String get pauseReason => _pauseReason;
  bool get hasReachedTarget => _elapsedSeconds >= _targetSeconds;

  double get progress => _targetSeconds > 0
      ? (_elapsedSeconds / _targetSeconds).clamp(0.0, 1.0)
      : 0.0;

  int get remainingSeconds => (_targetSeconds - _elapsedSeconds).clamp(0, _targetSeconds);

  String formatTime([int? seconds]) {
    final s = seconds ?? _elapsedSeconds;
    final mins = s ~/ 60;
    final secs = s % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Initialize state for a specific learning day from local SharedPreferences
  Future<void> initForDay(int dayNumber) async {
    _day = dayNumber;
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefix = 'pocket_mission_day_$_day';
      _elapsedSeconds = prefs.getInt('${prefix}_elapsed_sec') ?? 0;
      _targetSeconds = prefs.getInt('${prefix}_target_sec') ?? defaultTargetSeconds;

      // Ensure elapsed does not exceed target on load
      if (_elapsedSeconds > _targetSeconds) {
        _elapsedSeconds = _targetSeconds;
      }

      if (_elapsedSeconds >= _targetSeconds) {
        _pauseReason = '60-Min Target Reached';
      } else {
        _pauseReason = 'Paused';
      }
    } catch (e) {
      debugPrint('[PocketMissionTimerService] Error loading state: $e');
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Persist current elapsed and target seconds locally
  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefix = 'pocket_mission_day_$_day';
      await prefs.setInt('${prefix}_elapsed_sec', _elapsedSeconds);
      await prefs.setInt('${prefix}_target_sec', _targetSeconds);
    } catch (e) {
      debugPrint('[PocketMissionTimerService] Error saving state: $e');
    }
  }

  /// Start or resume the practice timer
  void startTimer() {
    if (_isRunning) return;

    // If target is already achieved, prompt user to add an hour or restart
    if (hasReachedTarget) {
      _pauseReason = 'Target already reached! Add extra hour to continue.';
      notifyListeners();
      return;
    }

    _isRunning = true;
    _pauseReason = 'Active Practice';
    HapticFeedback.selectionClick();

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;

      // Auto-stop at 60:00 (or current target) as specified by user
      if (_elapsedSeconds >= _targetSeconds) {
        _elapsedSeconds = _targetSeconds;
        _ticker?.cancel();
        _ticker = null;
        _isRunning = false;
        _pauseReason = 'Daily 60-Min Practice Target Reached!';
        _saveState();
        HapticFeedback.heavyImpact();
        notifyListeners();
        return;
      }

      // Persist state periodically every 5 seconds
      if (_elapsedSeconds % 5 == 0) {
        _saveState();
      }

      notifyListeners();
    });

    notifyListeners();
  }

  /// Pause the practice timer with an explanation
  void pauseTimer({String reason = 'Paused by user'}) {
    if (!_isRunning && _ticker == null) {
      _pauseReason = reason;
      notifyListeners();
      return;
    }

    _ticker?.cancel();
    _ticker = null;
    _isRunning = false;
    _pauseReason = reason;
    _saveState();
    notifyListeners();
  }

  /// Toggle play/pause
  void toggleTimer() {
    if (_isRunning) {
      pauseTimer(reason: 'Paused by user');
    } else {
      startTimer();
    }
  }

  /// User wants an additional 1-hour practice block (+60 mins)
  void addAnotherHourPractice() {
    pauseTimer(reason: 'Extended practice target');
    _targetSeconds += defaultTargetSeconds; // Add +3600 seconds
    _saveState();
    startTimer();
    notifyListeners();
  }

  /// Restart 1-hour practice session from 0 (if subtasks were incomplete)
  void restartPracticeSession() {
    pauseTimer(reason: 'Session restarted');
    _elapsedSeconds = 0;
    _targetSeconds = defaultTargetSeconds;
    _saveState();
    startTimer();
    notifyListeners();
  }

  /// Reset to standard 60 minutes
  void resetToSixtyMinutes() {
    pauseTimer(reason: 'Reset to 60m');
    _elapsedSeconds = 0;
    _targetSeconds = defaultTargetSeconds;
    _saveState();
    notifyListeners();
  }

  /// Lifecycle observer: automatically pause when app is minimized or backgrounded
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      if (_isRunning) {
        pauseTimer(reason: 'Paused (App in background)');
      }
    }
  }
}
