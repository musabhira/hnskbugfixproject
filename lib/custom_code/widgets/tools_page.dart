import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import '/custom_code/widgets/drawing_app_home.dart';
import '/custom_code/widgets/teams/teams_home_widget.dart';
import '/custom_code/widgets/poster_designer/template_gallery_page.dart';
import '/custom_code/widgets/bulk_sender/bulk_sender_page.dart';
import '/custom_code/widgets/poki_games_page.dart';
import '/custom_code/widgets/nearby_users_page.dart';
import '/custom_code/widgets/chess_game_page.dart';
import '/custom_code/widgets/dynamic_web_view_page.dart';
import '/custom_code/widgets/password_generator_page.dart';
import '/custom_code/widgets/share_content_screen.dart';
import '/custom_code/widgets/crazy_games_page.dart';
import '/custom_code/widgets/test_feature_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '/custom_code/widgets/drawing_academy_home_page.dart';
import '/custom_code/widgets/ai_prompt_service.dart';
import '/custom_code/widgets/dual_video_recorder.dart';
import '/custom_code/widgets/courses_widget.dart';

class ToolsPage extends StatefulWidget {
  final double? width;
  final double? height;
  final VoidCallback? onFavoriteToggled;

  final int? initialTab;

  const ToolsPage({
    super.key,
    this.width,
    this.height,
    this.onFavoriteToggled,
    this.initialTab,
  });

  @override
  _TaskManagerScreenState createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<ToolsPage> {
  List<Task> tasks = [];
  List<Challenge> challenges = [];
  int completedToday = 0;
  final TextEditingController taskController = TextEditingController();
  final TextEditingController taskNotesController = TextEditingController();
  final TextEditingController challengeController = TextEditingController();
  final TextEditingController scheduleController = TextEditingController();
  final TextEditingController aiScheduleController = TextEditingController();
  final TextEditingController challengeDurationController = TextEditingController(text: '21');

  @override
  void dispose() {
    taskController.dispose();
    taskNotesController.dispose();
    challengeController.dispose();
    scheduleController.dispose();
    aiScheduleController.dispose();
    challengeDurationController.dispose();
    super.dispose();
  }

  TaskPriority selectedPriority = TaskPriority.medium;
  ChallengeType selectedChallengeType = ChallengeType.days;
  int challengeDuration = 21;
  bool _showAddTask = false;
  bool _showAddChallenge = false;
  bool _showAddSchedule = false;
  bool _showToolsList = true;
  bool _isWebSearchMode = false;
  int _selectedTab = 0;
  List<ScheduleItem> dailySchedule = [];
  DateTime selectedScheduleDate = DateTime.now();
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  bool _useAISchedule = false;
  bool _isGeneratingSchedule = false;
  String? _editingScheduleId;

  String _toolsSearchQuery = '';
  List<String> _favoritedTools = [];
  List<String> _restrictedTools = [];
  List<String> _allowedPrivateTools = [];
  Map<String, Map<String, dynamic>> _globalToolConfigs = {};
  bool _isLoadingTools = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTab != null) {
      _selectedTab = widget.initialTab!;
      _showToolsList = false;
    }
    _loadData();
    _loadFavoritedTools();
    _loadToolPermissions();
  }

  Future<void> _loadToolPermissions() async {
    setState(() => _isLoadingTools = true);
    try {
      final userId = SupaFlow.client.auth.currentUser?.id;
      
      // Fetch global configs
      final configRes = await SupaFlow.client.from('app_tool_configs').select('*');
      final configsMap = {
        for (var c in (configRes as List)) c['tool_name'] as String: c as Map<String, dynamic>
      };

      List<String> restricted = [];
      List<String> allowedPrivate = [];
      if (userId != null) {
        final accessRes = await SupaFlow.client
            .from('user_tool_permissions')
            .select('tool_name, is_blocked, has_private_access')
            .eq('user_id', userId);
        
        for (var row in (accessRes as List)) {
          if (row['is_blocked'] == true) {
            restricted.add(row['tool_name'] as String);
          }
          if (row['has_private_access'] == true) {
            allowedPrivate.add(row['tool_name'] as String);
          }
        }
      }

      setState(() {
        _globalToolConfigs = configsMap;
        _restrictedTools = restricted;
        _allowedPrivateTools = allowedPrivate;
        _isLoadingTools = false;
      });
    } catch (e) {
      debugPrint('Error loading tool permissions: $e');
      setState(() => _isLoadingTools = false);
    }
  }

  Future<void> _loadFavoritedTools() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = SupaFlow.client.auth.currentUser?.id ?? '';
    final favoritedToolsJson =
        prefs.getString('favorited_tools_$userId') ?? '[]';
    final favoritedToolsList = jsonDecode(favoritedToolsJson) as List;
    setState(() {
      _favoritedTools =
          favoritedToolsList.map((e) => e['title'] as String).toList();
    });
  }

  Future<void> _toggleFavoriteTool(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = SupaFlow.client.auth.currentUser?.id ?? '';

    final favoritedToolsJson =
        prefs.getString('favorited_tools_$userId') ?? '[]';
    final List<dynamic> favoritedToolsList = jsonDecode(favoritedToolsJson);

    if (_favoritedTools.contains(title)) {
      _favoritedTools.remove(title);
      favoritedToolsList.removeWhere((e) => e['title'] == title);
    } else {
      _favoritedTools.add(title);
      favoritedToolsList.add({
        'title': title,
        'timeAdded': DateTime.now().toIso8601String(),
      });
    }

    await prefs.setString(
        'favorited_tools_$userId', jsonEncode(favoritedToolsList));
    setState(() {});

    // Trigger callback to refresh home page if needed
    widget.onFavoriteToggled?.call();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = SupaFlow.client.auth.currentUser?.id ?? 'guest';

    final tasksJson = prefs.getString('tasks_$userId') ?? '[]';
    final tasksList = jsonDecode(tasksJson) as List;
    tasks = tasksList.map((task) => Task.fromJson(task)).toList();

    final challengesJson = prefs.getString('challenges_$userId') ?? '[]';
    final challengesList = jsonDecode(challengesJson) as List;
    challenges = challengesList
        .map((challenge) => Challenge.fromJson(challenge))
        .toList();

    final scheduleJson = prefs.getString('schedule_$userId') ?? '[]';
    final scheduleList = jsonDecode(scheduleJson) as List;
    final todaySchedule = scheduleList
        .map((item) => ScheduleItem.fromJson(item))
        .where((item) =>
            item.startTime.year == DateTime.now().year &&
            item.startTime.month == DateTime.now().month &&
            item.startTime.day == DateTime.now().day)
        .toList();

    dailySchedule = todaySchedule;

    _calculateStats();
    _updateChallengeStatus();
    setState(() {});
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = SupaFlow.client.auth.currentUser?.id ?? 'guest';
    final tasksJson = jsonEncode(tasks.map((task) => task.toJson()).toList());
    final challengesJson =
        jsonEncode(challenges.map((challenge) => challenge.toJson()).toList());
    final scheduleJson =
        jsonEncode(dailySchedule.map((item) => item.toJson()).toList());

    await prefs.setString('tasks_$userId', tasksJson);
    await prefs.setString('challenges_$userId', challengesJson);
    await prefs.setString('schedule_$userId', scheduleJson);
  }

  void _updateChallengeStatus() {
    final now = DateTime.now();
    for (var challenge in challenges) {
      if (challenge.isCompleted) continue;

      final daysPassed = now.difference(challenge.startDate).inDays;
      if (daysPassed >= challenge.totalDays) {
        challenge.isCompleted = true;
        challenge.completedDate = now;
      }
    }
  }

  void _generateAISchedule() async {
    if (aiScheduleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your schedule details'),
          backgroundColor: Color(0xFF2C2C2C),
        ),
      );
      return;
    }

    setState(() => _isGeneratingSchedule = true);

    try {
      final generatedItems = await ScheduleAIService.generateScheduleFromPrompt(
        aiScheduleController.text.trim(),
        selectedScheduleDate,
      );

      setState(() {
        if (generatedItems.isNotEmpty) {
          dailySchedule = generatedItems;
          _showAddSchedule = false;
          _useAISchedule = false;
          aiScheduleController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Schedule generated with ${generatedItems.length} items',
              ),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to generate schedule'),
              backgroundColor: Color(0xFFE57373),
            ),
          );
        }
        _isGeneratingSchedule = false;
      });

      _saveData();
    } catch (e) {
      print('Error in _generateAISchedule: $e');
      setState(() => _isGeneratingSchedule = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating schedule: $e'),
          backgroundColor: const Color(0xFFE57373),
        ),
      );
    }
  }

  void _addScheduleItem() {
    if (scheduleController.text.trim().isEmpty ||
        selectedStartTime == null ||
        selectedEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Color(0xFFE57373),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final startTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedStartTime!.hour,
      selectedStartTime!.minute,
    );
    final endTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedEndTime!.hour,
      selectedEndTime!.minute,
    );

    if (_editingScheduleId != null) {
      // Edit existing
      setState(() {
        final index =
            dailySchedule.indexWhere((item) => item.id == _editingScheduleId);
        if (index != -1) {
          dailySchedule[index].title = scheduleController.text.trim();
          dailySchedule[index].startTime = startTime;
          dailySchedule[index].endTime = endTime;
        }
        _editingScheduleId = null;
      });
    } else {
      // Add new
      final newItem = ScheduleItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: scheduleController.text.trim(),
        startTime: startTime,
        endTime: endTime,
        color: const Color(0xFF424242),
        source: ScheduleSource.manual,
      );

      setState(() {
        dailySchedule.add(newItem);
        dailySchedule.sort((a, b) => a.startTime.compareTo(b.startTime));
      });
    }

    scheduleController.clear();
    selectedStartTime = null;
    selectedEndTime = null;
    _showAddSchedule = false;
    _saveData();
  }

  void _editScheduleItem(ScheduleItem item) {
    setState(() {
      _editingScheduleId = item.id;
      scheduleController.text = item.title;
      selectedStartTime = TimeOfDay.fromDateTime(item.startTime);
      selectedEndTime = TimeOfDay.fromDateTime(item.endTime);
      _showAddSchedule = true;
      _useAISchedule = false;
    });
  }

  void _deleteScheduleItem(String itemId) {
    setState(() {
      dailySchedule.removeWhere((item) => item.id == itemId);
    });
    _saveData();
  }

  void _toggleScheduleItem(String itemId) {
    setState(() {
      final itemIndex = dailySchedule.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        dailySchedule[itemIndex].isCompleted =
            !dailySchedule[itemIndex].isCompleted;
      }
    });
    _saveData();
  }

  void _addTask() {
    if (taskController.text.isNotEmpty) {
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: taskController.text,
        notes: taskNotesController.text.isNotEmpty
            ? taskNotesController.text
            : null,
        priority: selectedPriority,
        createdDate: DateTime.now(),
      );

      setState(() {
        tasks.insert(0, newTask);
        taskController.clear();
        taskNotesController.clear();
        _showAddTask = false;
      });

      _saveData();
      _calculateStats();
    }
  }

  void _addChallenge() {
    if (challengeController.text.isNotEmpty) {
      int totalDays;
      switch (selectedChallengeType) {
        case ChallengeType.days:
          totalDays = challengeDuration;
          break;
        case ChallengeType.months:
          totalDays = challengeDuration * 30;
          break;
        case ChallengeType.years:
          totalDays = challengeDuration * 365;
          break;
      }

      final newChallenge = Challenge(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: challengeController.text,
        totalDays: totalDays,
        startDate: DateTime.now(),
        dailyTicks: {},
      );

      setState(() {
        challenges.insert(0, newChallenge);
        challengeController.clear();
        _showAddChallenge = false;
        challengeDuration = 21;
        challengeDurationController.text = '21';
      });

      _saveData();
    }
  }

  void _toggleTask(String taskId) {
    setState(() {
      final taskIndex = tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        tasks[taskIndex].isCompleted = !tasks[taskIndex].isCompleted;
        if (tasks[taskIndex].isCompleted) {
          tasks[taskIndex].completedDate = DateTime.now();
        } else {
          tasks[taskIndex].completedDate = null;
        }
      }
    });
    _saveData();
    _calculateStats();
  }

  void _toggleChallengeDay(String challengeId) {
    final today = DateTime.now();
    final todayKey = "${today.year}-${today.month}-${today.day}";

    setState(() {
      final challengeIndex =
          challenges.indexWhere((challenge) => challenge.id == challengeId);
      if (challengeIndex != -1) {
        final challenge = challenges[challengeIndex];
        if (challenge.dailyTicks.containsKey(todayKey)) {
          challenge.dailyTicks.remove(todayKey);
        } else {
          challenge.dailyTicks[todayKey] = true;
        }
      }
    });
    _saveData();
  }

  void _toggleChallengeDayIndex(String challengeId, String dayKey) {
    setState(() {
      final challengeIndex =
          challenges.indexWhere((challenge) => challenge.id == challengeId);
      if (challengeIndex != -1) {
        final challenge = challenges[challengeIndex];
        if (challenge.dailyTicks.containsKey(dayKey)) {
          challenge.dailyTicks[dayKey] = !challenge.dailyTicks[dayKey]!;
        } else {
          challenge.dailyTicks[dayKey] = true;
        }

        // Calculate if completed
        int completedCount = challenge.dailyTicks.values.where((v) => v == true).length;
        if (completedCount >= challenge.totalDays) {
          challenge.isCompleted = true;
          challenge.completedDate = DateTime.now();
        } else {
          challenge.isCompleted = false;
          challenge.completedDate = null;
        }
      }
    });
    _saveData();
  }

  void _calculateStats() {
    final today = DateTime.now();
    final todayTasks = tasks
        .where((task) =>
            task.createdDate.day == today.day &&
            task.createdDate.month == today.month &&
            task.createdDate.year == today.year)
        .toList();
    completedToday = todayTasks.where((task) => task.isCompleted).length;
  }

  void _deleteTask(String taskId) {
    setState(() {
      tasks.removeWhere((task) => task.id == taskId);
    });
    _saveData();
    _calculateStats();
  }

  void _deleteChallenge(String challengeId) {
    setState(() {
      challenges.removeWhere((challenge) => challenge.id == challengeId);
    });
    _saveData();
  }

  void _reorderTasks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final task = tasks.removeAt(oldIndex);
      tasks.insert(newIndex, task);
    });
    _saveData();
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return const Color(0xFFE57373);
      case TaskPriority.medium:
        return const Color(0xFFFFB74D);
      case TaskPriority.low:
        return const Color(0xFF81C784);
    }
  }

  String _getChallengeTypeText(ChallengeType type) {
    switch (type) {
      case ChallengeType.days:
        return 'Days';
      case ChallengeType.months:
        return 'Months';
      case ChallengeType.years:
        return 'Years';
    }
  }

  String _getToolTitle(int index) {
    switch (index) {
      case 0:
        return 'Schedule';
      case 1:
        return 'Tasks';
      case 2:
        return 'Challenges';
      case 3:
        return 'Diagrams';
      case 4:
        return 'Teams';
      case 5:
        return 'AI Tools';
      case 6:
        return 'Mini Apps';
      case 7:
        // Courses commented out
        return 'Tools';
      default:
        return 'Tools';
    }
  }

  void _showDynamicWebAppDialog() {
    final TextEditingController urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text('Dynamic Web App',
            style: GoogleFonts.outfit(color: Colors.white)),
        content: TextField(
          controller: urlController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter URL (e.g., https://example.com)',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              final url = urlController.text.trim();
              if (url.isNotEmpty) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DynamicWebViewPage(
                      title: 'Web App',
                      url: url,
                    ),
                  ),
                );
              }
            },
            child:
                const Text('Open', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  void _showQRCodeSimulation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text('QR & Barcode',
            style: GoogleFonts.outfit(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_2_rounded, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            Text('QR features are available in the mobile app build.',
                style: GoogleFonts.outfit(color: Colors.white70),
                textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showWebSearchDialog() {
    final TextEditingController searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text('Web Search', style: GoogleFonts.outfit(color: Colors.white)),
        content: TextField(
          controller: searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Ask anything...',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.yellowAccent)),
          ),
          onSubmitted: (query) {
             if (query.trim().isNotEmpty) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DynamicWebViewPage(
                      title: 'Browser',
                      url: 'https://www.google.com/search?q=${Uri.encodeComponent(query.trim())}',
                    ),
                  ),
                );
             }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              final query = searchController.text.trim();
              if (query.isNotEmpty) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DynamicWebViewPage(
                      title: 'Browser',
                      url: 'https://www.google.com/search?q=${Uri.encodeComponent(query)}',
                    ),
                  ),
                );
              }
            },
            child: const Text('Search', style: TextStyle(color: Colors.yellowAccent)),
          ),
        ],
      ),
    );
  }

  void _showWorldClockSimulation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title:
            Text('World Clock', style: GoogleFonts.outfit(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildClockItem('London', 'UTC +0'),
            _buildClockItem('New York', 'UTC -5'),
            _buildClockItem('Tokyo', 'UTC +9'),
            _buildClockItem('Dubai', 'UTC +4'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeYellow = isDark ? const Color(0xFFFFD600) : const Color(0xFFFFF500);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withOpacity(0.75) : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: themeYellow.withOpacity(0.25), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withOpacity(0.6) : Colors.grey.withOpacity(0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: themeYellow.withOpacity(0.08),
                    blurRadius: 45,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeYellow.withOpacity(0.15),
                          themeYellow.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: themeYellow.withOpacity(0.3), width: 1.5),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      color: themeYellow,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Coming Soon!',
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Handskill E-Learning Academy will be fully unlocked in the 2nd or 3rd build. Stay tuned for expert masterclasses, video tutorials, and interactive learning modules!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.8),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeYellow,
                          themeYellow.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: themeYellow.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Got It',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClockItem(String city, String offset) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(city, style: const TextStyle(color: Colors.white)),
          Text(offset, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildToolsList() {
    final List<Map<String, dynamic>> allTools = [
      {
        'title': 'Drawing Tool',
        'icon': Icons.brush,
        'color': const Color(0xFFFFD700),
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const DrawingAppHome())),
      },
      {
        'title': 'Dual Recorder',
        'subtitle': 'YouTube & Reels',
        'icon': Icons.duo_rounded,
        'color': const Color(0xFFFFB700),
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const DualVideoRecorderWidget())),
      },
      {
        'title': 'Schedule',
        'icon': Icons.calendar_today_rounded,
        'color': const Color(0xFFE8D3A7),
        'onTap': () => setState(() {
              _selectedTab = 0;
              _showToolsList = false;
            }),
      },
      {
        'title': 'Tasks',
        'icon': Icons.check_circle_outline_rounded,
        'color': const Color(0xFFCD7F32),
        'onTap': () => setState(() {
              _selectedTab = 1;
              _showToolsList = false;
            }),
      },
      {
        'title': 'Habit Tracker',
        'icon': Icons.emoji_events_outlined,
        'color': const Color(0xFFFFD700),
        'onTap': () => setState(() {
              _selectedTab = 2;
              _showToolsList = false;
            }),
      },
      {
        'title': 'Diagrams',
        'icon': Icons.schema_rounded,
        'color': const Color(0xFFFFB700),
        'onTap': () => setState(() {
              _selectedTab = 3;
              _showToolsList = false;
            }),
      },
      {
        'title': 'Teams',
        'icon': Icons.groups_rounded,
        'color': const Color(0xFFE8D3A7),
        'onTap': () => setState(() {
              _selectedTab = 4;
              _showToolsList = false;
            }),
      },
      // AI Tools removed as per request
      {
        'title': 'Poster Maker',
        'icon': Icons.photo_library_rounded,
        'color': const Color(0xFFCD7F32),
        'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const TemplateGalleryPage())),
      },
      {
        'title': 'Bulk Sender',
        'icon': Icons.send_rounded,
        'color': const Color(0xFFFFD700),
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const BulkSenderPage())),
      },
      {
        'title': 'Poki Games',
        'subtitle': 'poki.com',
        'icon': Icons.videogame_asset_rounded,
        'color': const Color(0xFFFFB700),
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const PokiGamesPage())),
      },
      {
        'title': 'Crazy Games',
        'subtitle': 'crazygames.com',
        'icon': Icons.sports_esports_rounded,
        'color': const Color(0xFFE8D3A7),
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CrazyGamesPage())),
      },
      {
        'title': 'Dynamic Web App',
        'subtitle': 'Any URL',
        'icon': Icons.public_rounded,
        'color': const Color(0xFFCD7F32),
        'onTap': () => _showDynamicWebAppDialog(),
      },
      {
        'title': 'Chess Match',
        'icon': Icons.casino_rounded,
        'color': const Color(0xFFFFD700),
        'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ChessMatchmakingPage())),
      },
      {
        'title': 'Travel Radar',
        'icon': Icons.radar,
        'color': const Color(0xFFFFB700),
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const NearbyUsersPage())),
      },
      // Diagram AI removed as per request
      {
        'title': 'Password Pro',
        'subtitle': 'Secure Generator',
        'icon': Icons.password_rounded,
        'color': const Color(0xFFE8D3A7),
        'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const PasswordGeneratorPage())),
      },
      // AI Studio removed as per request
      {
        'title': 'QR & Barcode',
        'subtitle': 'Scan & Generate',
        'icon': Icons.qr_code_scanner_rounded,
        'color': const Color(0xFFCD7F32),
        'onTap': () => _showQRCodeSimulation(),
      },
      {
        'title': 'World Clock',
        'subtitle': 'Global Times',
        'icon': Icons.public_rounded,
        'color': const Color(0xFFFFD700),
        'onTap': () => _showWorldClockSimulation(),
      },
      {
        'title': 'WhatsApp Web',
        'subtitle': 'Chat on Desktop',
        'icon': Icons.chat_rounded,
        'color': const Color(0xFFFFB700),
        'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const DynamicWebViewPage(
                      title: 'WhatsApp Web',
                      url: 'https://web.whatsapp.com',
                    ))),
      },
      {
        'title': 'Web Search',
        'subtitle': 'Search the Internet',
        'icon': Icons.travel_explore_rounded,
        'color': const Color(0xFFE8D3A7),
        'onTap': () => _showWebSearchDialog(),
      },
      {
        'title': 'Handskill Learn',
        'subtitle': 'Learning Academy',
        'icon': Icons.school_rounded,
        'color': const Color(0xFFCD7F32),
        'onTap': () {
          final isUnlocked = _globalToolConfigs['elearning_unlocked']?['android_active'] == true;
          if (isUnlocked) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CoursesWidget()),
            );
          } else {
            _showComingSoonDialog();
          }
        },
      },
      {
        'title': 'Test Feature',
        'subtitle': 'System Diagnostic',
        'icon': Icons.bug_report_rounded,
        'color': const Color(0xFFFFD700),
        'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const TestFeaturePage())),
      },
    ];

    final filteredTools = allTools.where((tool) {
      final title = tool['title'] as String;
      
      // 1. Search filter
      final matchesSearch = title.toLowerCase().contains(_toolsSearchQuery.toLowerCase()) || 
          (tool['subtitle']?.toString().toLowerCase().contains(_toolsSearchQuery.toLowerCase()) ?? false);
      if (!matchesSearch) return false;

      // 2. Platform Visibility Check
      final config = _globalToolConfigs[title] ?? {'android_active': true, 'ios_active': true};
      final androidActive = config['android_active'] ?? true;
      final iosActive = config['ios_active'] ?? true;
      
      final platform = Theme.of(context).platform;
      bool publicVisible = false;
      if (platform == TargetPlatform.android && androidActive) publicVisible = true;
      if (platform == TargetPlatform.iOS && iosActive) publicVisible = true;

      // 3. Permission Overrides
      final isBlocked = _restrictedTools.contains(title);
      final hasPrivateAccess = _allowedPrivateTools.contains(title);

      // Rule: Visible if (Publicly Active on platform OR User has private access) AND NOT blocked
      return (publicVisible || hasPrivateAccess) && !isBlocked;
    }).toList();

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.yellow.withValues(alpha: 0.05),
                      Colors.transparent
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tools for',
                                style: GoogleFonts.outfit(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w400,
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                    letterSpacing: 1.2)),
                            Text('Browser',
                                style: GoogleFonts.outfit(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellow)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryText.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.dashboard_rounded,
                              color: Colors.yellow),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: FlutterFlowTheme.of(context).alternate),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          if (!_isWebSearchMode) {
                            setState(() => _toolsSearchQuery = value);
                          }
                        },
                        onSubmitted: (query) {
                          if (_isWebSearchMode && query.trim().isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DynamicWebViewPage(
                                  title: 'Browser',
                                  url: 'https://www.google.com/search?q=${Uri.encodeComponent(query.trim())}',
                                ),
                              ),
                            );
                          }
                        },
                        style: GoogleFonts.outfit(color: FlutterFlowTheme.of(context).primaryText),
                        decoration: InputDecoration(
                          hintText: _isWebSearchMode ? 'Search Google...' : 'Search tools or features...',
                          hintStyle: GoogleFonts.outfit(color: _isWebSearchMode ? Colors.yellow.withValues(alpha: 0.5) : FlutterFlowTheme.of(context).secondaryText),
                          prefixIcon: Icon(
                            _isWebSearchMode ? Icons.travel_explore_rounded : Icons.search, 
                            color: _isWebSearchMode ? Colors.yellow : FlutterFlowTheme.of(context).secondaryText,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.public_rounded,
                              color: _isWebSearchMode ? Colors.yellow : FlutterFlowTheme.of(context).secondaryText,
                            ),
                            tooltip: 'Web Mode',
                            onPressed: () {
                              setState(() {
                                _isWebSearchMode = !_isWebSearchMode;
                                if (_isWebSearchMode) {
                                  _toolsSearchQuery = ''; 
                                }
                              });
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredTools.length,
                  itemBuilder: (context, index) {
                    final tool = filteredTools[index];
                    final isFav = _favoritedTools.contains(tool['title']);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isFav
                              ? (tool['color'] as Color).withValues(alpha: 0.5)
                              : FlutterFlowTheme.of(context).alternate,
                          width: 1.5,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: tool['onTap'] as VoidCallback,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: (tool['color'] as Color)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    tool['icon'] as IconData,
                                    color: tool['color'] as Color,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        tool['title'] as String,
                                        style: GoogleFonts.outfit(
                                          color: FlutterFlowTheme.of(context).primaryText,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (tool.containsKey('subtitle'))
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                            tool['subtitle'] as String,
                                            style: GoogleFonts.outfit(
                                              color: FlutterFlowTheme.of(context).secondaryText,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.share_rounded, color: Colors.yellow, size: 20),
                                      onPressed: () {
                                        final userId = SupaFlow.client.auth.currentUser?.id;
                                        if (userId != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ShareContentScreen(
                                                contentToShare:
                                                    "Check out this ${tool['title']} tool on Pocket Mates!",
                                                currentUserId: userId,
                                                contentType: 'tool',
                                                metadata: {
                                                  'title': tool['title'],
                                                  'description': tool.containsKey('subtitle') ? tool['subtitle'] : '',
                                                  'category': 'Tools',
                                                },
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: Icon(
                                        isFav
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                        color: isFav
                                            ? Colors.redAccent
                                            : Colors.white24,
                                      ),
                                      onPressed: () => _toggleFavoriteTool(
                                          tool['title'] as String),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.initialTab != null ? true : _showToolsList,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (widget.initialTab == null && !_showToolsList) {
          setState(() => _showToolsList = true);
        }
      },
      child: _showToolsList ? _buildToolsList() : _buildToolDetailView(),
    );
  }

  Widget _buildToolDetailView() {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            // Header with Back Button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: FlutterFlowTheme.of(context).primaryText, size: 20),
                    onPressed: () {
                      if (widget.initialTab != null) {
                        Navigator.pop(context);
                      } else {
                        setState(() => _showToolsList = true);
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _getToolTitle(_selectedTab),
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_rounded,
                        color: Colors.yellow, size: 22),
                    onPressed: () {
                      final userId = SupaFlow.client.auth.currentUser?.id;
                      if (userId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShareContentScreen(
                              contentToShare:
                                  "Check out this ${_getToolTitle(_selectedTab)} tool on Pocket Mates!",
                              currentUserId: userId,
                              contentType: 'text',
                              metadata: {
                                'tool_title': _getToolTitle(_selectedTab),
                                'category': 'Tools',
                              },
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.yellow, Colors.yellowAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      '$completedToday',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Add Button (FAB-like but inline for safety)
            if (_selectedTab < 3) // Only show add button for first 3 tabs
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedTab == 0) {
                      _showAddSchedule = !_showAddSchedule;
                      _showAddTask = false;
                      _showAddChallenge = false;
                      _useAISchedule = false;
                      _editingScheduleId = null;
                    } else if (_selectedTab == 1) {
                      _showAddTask = !_showAddTask;
                      _showAddSchedule = false;
                      _showAddChallenge = false;
                    } else {
                      _showAddChallenge = !_showAddChallenge;
                      _showAddTask = false;
                      _showAddSchedule = false;
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: (_selectedTab == 0 && _showAddSchedule) ||
                            (_selectedTab == 1 && _showAddTask) ||
                            (_selectedTab == 2 && _showAddChallenge)
                        ? const Color(0xFF2C2C2C)
                        : null,
                    gradient: (_selectedTab == 0 && _showAddSchedule) ||
                            (_selectedTab == 1 && _showAddTask) ||
                            (_selectedTab == 2 && _showAddChallenge)
                        ? null
                        : LinearGradient(
                            colors: [Colors.yellow.shade400, Colors.yellow.shade700],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: (_selectedTab == 0 && _showAddSchedule) ||
                            (_selectedTab == 1 && _showAddTask) ||
                            (_selectedTab == 2 && _showAddChallenge)
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.yellow.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                    border: Border.all(
                      color: (_selectedTab == 0 && _showAddSchedule) ||
                              (_selectedTab == 1 && _showAddTask) ||
                              (_selectedTab == 2 && _showAddChallenge)
                          ? const Color(0xFF424242)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        (_selectedTab == 0 && _showAddSchedule) ||
                                (_selectedTab == 1 && _showAddTask) ||
                                (_selectedTab == 2 && _showAddChallenge)
                            ? Icons.close
                            : Icons.add,
                        color: (_selectedTab == 0 && _showAddSchedule) ||
                                (_selectedTab == 1 && _showAddTask) ||
                                (_selectedTab == 2 && _showAddChallenge)
                            ? Colors.white70
                            : Colors.black87,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (_selectedTab == 0 && _showAddSchedule) ||
                                (_selectedTab == 1 && _showAddTask) ||
                                (_selectedTab == 2 && _showAddChallenge)
                            ? 'Cancel'
                            : _selectedTab == 0
                                ? 'Add Schedule Item'
                                : _selectedTab == 1
                                    ? 'Add New Task'
                                    : 'Start New Challenge',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: (_selectedTab == 0 && _showAddSchedule) ||
                                  (_selectedTab == 1 && _showAddTask) ||
                                  (_selectedTab == 2 && _showAddChallenge)
                              ? Colors.white70
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Add Forms
            if (_showAddSchedule && _selectedTab == 0) _buildAddScheduleForm(),
            if (_showAddTask && _selectedTab == 1) _buildAddTaskForm(),
            if (_showAddChallenge && _selectedTab == 2)
              _buildAddChallengeForm(),

            const SizedBox(height: 4),

            // Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const DiagramListScreen()),
      //     );
      //   },
      //   backgroundColor: const Color(0xFFFD814A), // your gradient color base
      //   child: const Icon(Icons.add),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAddTaskForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF424242)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: taskController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'What needs to be done?',
              hintStyle: const TextStyle(color: Color(0xFF757575)),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: taskNotesController,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Add notes (optional)',
              hintStyle: const TextStyle(color: Color(0xFF757575)),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Priority: ',
                  style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 14)),
              ...TaskPriority.values.map(
                (priority) => GestureDetector(
                  onTap: () => setState(() => selectedPriority = priority),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selectedPriority == priority
                          ? _getPriorityColor(priority)
                          : const Color(0xFF424242),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      priority.toString().split('.').last.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('Add Task'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddScheduleForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF424242)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle between Manual and AI
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _useAISchedule = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          !_useAISchedule ? Colors.yellow : const Color(0xFF424242),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Manual',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: !_useAISchedule ? Colors.black : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _useAISchedule = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _useAISchedule ? Colors.yellow : const Color(0xFF424242),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'AI Generate',
                          style: TextStyle(
                            color: _useAISchedule ? Colors.black : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (!_useAISchedule) ...[
            TextField(
              controller: scheduleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Activity name',
                hintStyle: const TextStyle(color: Color(0xFF757575)),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedStartTime ?? TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Color(0xFFFF6B9D),
                                surface: Color(0xFF2C2C2C),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (time != null) {
                        setState(() => selectedStartTime = time);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time,
                              color: Color(0xFFFF6B9D), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            selectedStartTime != null
                                ? selectedStartTime!.format(context)
                                : 'Start time',
                            style: TextStyle(
                              color: selectedStartTime != null
                                  ? Colors.white
                                  : const Color(0xFF757575),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedEndTime ?? TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Color(0xFFFF6B9D),
                                surface: Color(0xFF2C2C2C),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (time != null) {
                        setState(() => selectedEndTime = time);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time,
                              color: Color(0xFFFF6B9D), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            selectedEndTime != null
                                ? selectedEndTime!.format(context)
                                : 'End time',
                            style: TextStyle(
                              color: selectedEndTime != null
                                  ? Colors.white
                                  : const Color(0xFF757575),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addScheduleItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B9D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(_editingScheduleId != null
                    ? 'Update Schedule'
                    : 'Add Schedule'),
              ),
            ),
          ] else ...[
            TextField(
              controller: aiScheduleController,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Describe your day:\ne.g., "Wake at 6am, workout 30min, work 9-5, lunch at 1pm, sleep 11pm"',
                hintStyle: const TextStyle(color: Color(0xFF757575)),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isGeneratingSchedule ? null : _generateAISchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B9D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isGeneratingSchedule
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Generating...'),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, size: 18),
                          SizedBox(width: 8),
                          Text('Generate Schedule'),
                        ],
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddChallengeForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF424242)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create New Habit / Target',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: challengeController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'e.g., Chess Match Practice, Gym, Study',
              hintStyle: const TextStyle(color: Color(0xFF757575)),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Target Duration',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: challengeDurationController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) =>
                      challengeDuration = int.tryParse(value) ?? 21,
                  decoration: InputDecoration(
                    hintText: '21',
                    hintStyle: const TextStyle(color: Color(0xFF757575)),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ...ChallengeType.values.map(
                (type) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedChallengeType = type),
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedChallengeType == type
                            ? const Color(0xFFFFD700)
                            : const Color(0xFF424242),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getChallengeTypeText(type),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selectedChallengeType == type ? Colors.black : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Target Presets',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildPresetButton(21),
              const SizedBox(width: 8),
              _buildPresetButton(75),
              const SizedBox(width: 8),
              _buildPresetButton(100),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addChallenge,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Start Tracker',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton(int days) {
    final isSelected = challengeDuration == days && selectedChallengeType == ChallengeType.days;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            challengeDuration = days;
            selectedChallengeType = ChallengeType.days;
            challengeDurationController.text = '$days';
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFFD700)
                : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFFFFD700) : const Color(0xFF424242),
              width: 1,
            ),
          ),
          child: Text(
            '$days Days',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: isSelected ? Colors.black : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTasksList() {
    if (tasks.isEmpty) {
      return _buildEmptyState(
        'No tasks yet',
        'Add your first task to get started',
        Icons.task_alt_outlined,
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: tasks.length,
      onReorder: _reorderTasks,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task, index);
      },
    );
  }

  Widget _buildScheduleTab() {
    if (dailySchedule.isEmpty) {
      return _buildEmptyState(
        'No schedule yet',
        'Add schedule manually or use AI',
        Icons.schedule_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: dailySchedule.length,
      itemBuilder: (context, index) {
        return _buildScheduleCard(dailySchedule[index]);
      },
    );
  }

  Widget _buildChallengesList() {
    if (challenges.isEmpty) {
      return _buildEmptyState(
        'No habits tracked yet',
        'Create your first habit or 100-day target',
        Icons.emoji_events_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return _buildChallengeCard(challenge);
      },
    );
  }

  Widget _buildTaskCard(Task task, int index) {
    return Container(
      key: ValueKey(task.id),
      margin: const EdgeInsets.only(bottom: 12),
      child: Hero(
        tag: 'task_${task.id}',
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: task.isCompleted ? const Color(0xFF4CAF50) : const Color(0xFF424242),
                width: task.isCompleted ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleTask(task.id),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: task.isCompleted
                              ? const Color(0xFF4CAF50)
                              : Colors.transparent,
                          border: Border.all(
                            color: task.isCompleted
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFF757575),
                            width: 2,
                          ),
                        ),
                        child: task.isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _getPriorityColor(task.priority),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _deleteTask(task.id),
                      child:
                          const Icon(Icons.close, color: Color(0xFF757575), size: 20),
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
                if (task.notes != null && task.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    task.notes!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleItem item) {
    final startHour = item.startTime.hour;
    final startMin = item.startTime.minute;
    final endHour = item.endTime.hour;
    final endMin = item.endTime.minute;

    final startPeriod = startHour >= 12 ? 'PM' : 'AM';
    final endPeriod = endHour >= 12 ? 'PM' : 'AM';

    final startHour12 =
        startHour > 12 ? startHour - 12 : (startHour == 0 ? 12 : startHour);
    final endHour12 =
        endHour > 12 ? endHour - 12 : (endHour == 0 ? 12 : endHour);

    final startStr =
        '${startHour12.toString().padLeft(2, '0')}:${startMin.toString().padLeft(2, '0')} $startPeriod';
    final endStr =
        '${endHour12.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')} $endPeriod';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isCompleted ? const Color(0xFF4CAF50) : const Color(0xFF424242),
          width: item.isCompleted ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Time column
          Container(
            width: 80,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  startStr,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 2,
                  height: 20,
                  color: const Color(0xFFFF6B9D),
                ),
                const SizedBox(height: 4),
                Text(
                  endStr,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 80,
            color: const Color(0xFF424242),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            decoration: item.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      if (item.source == ScheduleSource.aiGenerated)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B9D),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.auto_awesome,
                                  color: Colors.white, size: 10),
                              SizedBox(width: 2),
                              Text(
                                'AI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (item.description != null &&
                      item.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9E9E9E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _toggleScheduleItem(item.id),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.isCompleted
                          ? const Color(0xFF4CAF50)
                          : Colors.transparent,
                      border: Border.all(
                        color: item.isCompleted
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFF757575),
                        width: 2,
                      ),
                    ),
                    child: item.isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _editScheduleItem(item),
                  child: const Icon(Icons.edit, color: Color(0xFF757575), size: 18),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _deleteScheduleItem(item.id),
                  child: const Icon(Icons.delete, color: Color(0xFF757575), size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeYellow = isDark ? const Color(0xFFFFD600) : const Color(0xFFFFF500);
    final completedDays = challenge.dailyTicks.values.where((v) => v == true).length;
    final percentage =
        (completedDays / challenge.totalDays * 100).clamp(0.0, 100.0);
    final remainingDays = challenge.totalDays - completedDays;
    final isCompleted = completedDays >= challenge.totalDays || challenge.isCompleted;

    // Calculate grid height dynamically based on row count (7 columns per row)
    final int rowsCount = (challenge.totalDays / 7).ceil();
    final double gridHeight = (rowsCount * 44.0).clamp(60.0, 320.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCompleted ? const Color(0xFFFFD700) : const Color(0xFF424242),
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  blurRadius: 15,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFFFD700).withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: isCompleted ? const Color(0xFFFFD700) : themeYellow,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      isCompleted ? 'Goal Completed!' : 'Tap blocks to mark complete',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: isCompleted ? const Color(0xFFFFD700) : Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _deleteChallenge(challenge.id),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white60, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Statistics Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildChallengeStat('Total Days', '${challenge.totalDays}', Colors.white70),
              _buildChallengeStat('Completed', '$completedDays', const Color(0xFF4CAF50)),
              _buildChallengeStat('Remaining', '$remainingDays Left', const Color(0xFFFF6B9D), isBold: true),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar with percentage
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFF9E00)],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${percentage.toInt()}%',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Habit Grid View
          Text(
            'Daily Checkpoints',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: gridHeight,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: challenge.totalDays,
                itemBuilder: (context, index) {
                  final dayNumber = index + 1;
                  final dayKey = 'day_$dayNumber';
                  final isTicked = challenge.dailyTicks[dayKey] ?? false;

                  return GestureDetector(
                    onTap: () => _toggleChallengeDayIndex(challenge.id, dayKey),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isTicked
                            ? const Color(0xFFFFD700) // Gold ticked
                            : Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isTicked
                              ? const Color(0xFFFFD700)
                              : Colors.white.withValues(alpha: 0.08),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$dayNumber',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isTicked ? Colors.black : Colors.white70,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeStat(String label, String value, Color color, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B9D) : const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF6B9D).withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
          border: Border.all(
            color:
                isSelected ? const Color(0xFFFF6B9D) : const Color(0xFF424242),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedTab) {
      case 0:
        return _buildScheduleTab();
      case 1:
        return _buildTasksList();
      case 2:
        return _buildChallengesList();
      case 3:
        return _buildDiagramsTab();
      case 4:
        return const TeamsHomeWidget();
      case 5:
        return _buildMiniAppsTab(); // Shift tabs up or show something else
      case 6:
        return _buildMiniAppsTab();
      case 7:
        // DrawingAcademyHomePage commented out
        return Container();
      default:
        return _buildScheduleTab();
    }
  }

  Widget _buildMiniAppsTab() {
    return GridView.count(
      padding: const EdgeInsets.all(24),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildToolCard(
          title: 'Drawing Tool',
          icon: Icons.brush,
          color: Colors.orange,
          onTap: () {
            Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const DrawingAppHome()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildToolCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isFavorited = false,
    VoidCallback? onToggleFavorite,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (onToggleFavorite != null)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onToggleFavorite,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isFavorited
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: isFavorited ? Colors.redAccent : Colors.white54,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagramsTab() {
    return const DiagramListScreen();
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF6B9D),
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: const Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }
}

// Enums
enum TaskPriority { high, medium, low }

enum ChallengeType { days, months, years }

enum ScheduleSource { manual, aiGenerated }

// Models
class Task {
  String id;
  String title;
  String? notes;
  TaskPriority priority;
  bool isCompleted;
  DateTime createdDate;
  DateTime? completedDate;

  Task({
    required this.id,
    required this.title,
    this.notes,
    required this.priority,
    this.isCompleted = false,
    required this.createdDate,
    this.completedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'priority': priority.index,
      'isCompleted': isCompleted,
      'createdDate': createdDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      notes: json['notes'],
      priority: TaskPriority.values[json['priority']],
      isCompleted: json['isCompleted'],
      createdDate: DateTime.parse(json['createdDate']),
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
    );
  }
}

class Challenge {
  String id;
  String title;
  int totalDays;
  DateTime startDate;
  DateTime? completedDate;
  bool isCompleted;
  Map<String, bool> dailyTicks;

  Challenge({
    required this.id,
    required this.title,
    required this.totalDays,
    required this.startDate,
    this.completedDate,
    this.isCompleted = false,
    required this.dailyTicks,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'totalDays': totalDays,
      'startDate': startDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'dailyTicks': dailyTicks,
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      totalDays: json['totalDays'],
      startDate: DateTime.parse(json['startDate']),
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
      isCompleted: json['isCompleted'] ?? false,
      dailyTicks: Map<String, bool>.from(json['dailyTicks'] ?? {}),
    );
  }
}

class ScheduleItem {
  String id;
  String title;
  DateTime startTime;
  DateTime endTime;
  String? description;
  Color color;
  ScheduleSource source;
  bool isCompleted;

  ScheduleItem({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.description,
    required this.color,
    this.source = ScheduleSource.manual,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'description': description,
      'color': color.value,
      'source': source.index,
      'isCompleted': isCompleted,
    };
  }

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id'],
      title: json['title'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      description: json['description'],
      color: Color(json['color']),
      source: ScheduleSource.values[json['source'] ?? 0],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

// AI Service (placeholder - implement with your AI service)
class ScheduleAIService {
  static final AIService _aiService = AIService();

  static Future<List<ScheduleItem>> generateScheduleFromPrompt(
    String userPrompt,
    DateTime selectedDate,
  ) async {
    const systemPrompt =
        '''Generate a detailed daily schedule based on the user's request. 
    Return a JSON array of schedule items with this format:
    [
      {
        "title": "Activity name",
        "startTime": "HH:mm",
        "endTime": "HH:mm",
        "description": "Brief description"
      }
    ]
    Only return valid JSON, no other text.''';

    final fullPrompt =
        '$systemPrompt\n\nUser request: $userPrompt\n\nDate: ${selectedDate.toString()}\n\nCreate a realistic schedule for wake up to sleep.';

    try {
      final response = await _aiService.generateText(
        prompt: fullPrompt,
        maxTokens: 1000,
        temperature: 0.7,
      );

      if (response.isSuccess && response.data != null) {
        return _parseScheduleResponse(response.data!, selectedDate);
      } else {
        print('AI Error: ${response.error}');
      }
    } catch (e) {
      print('Error generating schedule: $e');
    }
    return [];
  }

  static List<ScheduleItem> _parseScheduleResponse(
    String response,
    DateTime selectedDate,
  ) {
    try {
      final List<Color> scheduleColors = [
        const Color(0xFFFFE082),
        const Color(0xFFFFB74D),
        const Color(0xFF81C784),
        const Color(0xFFE3F2FD),
        const Color(0xFFF3E5F5),
      ];

      final jsonList = jsonDecode(response) as List;
      final items = <ScheduleItem>[];
      int colorIndex = 0;

      for (var item in jsonList) {
        final startTime = _parseTime(item['startTime'], selectedDate);
        final endTime = _parseTime(item['endTime'], selectedDate);

        items.add(ScheduleItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() +
              items.length.toString(),
          title: item['title'],
          startTime: startTime,
          endTime: endTime,
          description: item['description'],
          color: scheduleColors[colorIndex % scheduleColors.length],
          source: ScheduleSource.aiGenerated,
        ));
        colorIndex++;
      }
      return items;
    } catch (e) {
      print('Error parsing schedule: $e');
      return [];
    }
  }

  static DateTime _parseTime(String timeStr, DateTime date) {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (e) {
      return date;
    }
  }

  static Future<List<FlowNode>> generatePlanFromPrompt(
    String userPrompt,
    String diagramName,
  ) async {
    const systemPrompt =
        '''You are an expert Project Manager and Workflow Architect.
    Generate a comprehensive, professional project plan based on the user's request.
    
    Return a JSON array of objects with exactly this format:
    [
      {
        "title": "Clear Task Name",
        "description": "Detailed action-oriented description of what needs to be done."
      }
    ]
    
    Requirements:
    1. Break down the project into 5-8 logical, sequential steps.
    2. Ensure each description is practical and specific.
    3. Return ONLY valid JSON. No markdown, no commentary, no additional text.''';

    final fullPrompt =
        '$systemPrompt\n\nProject Goal: $diagramName\nUser Context: $userPrompt\n\nCreate a realistic execution plan:';

    try {
      final response = await _aiService.generateText(
        prompt: fullPrompt,
        maxTokens: 1000,
        temperature: 0.7,
      );

      if (response.isSuccess && response.data != null) {
        return _parseAIPlanResponse(response.data!);
      } else {
        print('AI Error: ${response.error}');
      }
    } catch (e) {
      print('Error generating plan: $e');
    }
    return [];
  }

  static List<FlowNode> _parseAIPlanResponse(String response) {
    try {
      const colors = [
        Color(0xFF6366F1),
        Color(0xFF8B5CF6),
        Color(0xFFEC4899),
        Color(0xFFEF4444),
        Color(0xFFF97316),
        Color(0xFFFB923C),
        Color(0xFFFCD34D),
        Color(0xFF06B6D4),
      ];

      // Clean response - remove extra text and extract JSON
      String cleanedResponse = response.trim();

      // Find JSON array start and end
      final jsonStart = cleanedResponse.indexOf('[');
      final jsonEnd = cleanedResponse.lastIndexOf(']');

      if (jsonStart == -1 || jsonEnd == -1 || jsonStart >= jsonEnd) {
        print('No valid JSON array found in response');
        return [];
      }

      cleanedResponse = cleanedResponse.substring(jsonStart, jsonEnd + 1);

      final jsonList = jsonDecode(cleanedResponse) as List;
      final nodes = <FlowNode>[];

      for (int i = 0; i < jsonList.length; i++) {
        final item = jsonList[i];
        nodes.add(FlowNode(
          id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
          title: item['title'] ?? 'Task',
          description: item['description'] ?? '',
          position: Offset(50.0 + (i * 160), 100.0),
          color: colors[i % colors.length],
          sequenceOrder: i,
        ));
      }
      return nodes;
    } catch (e) {
      print('Error parsing plan: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> generateReelContent({
    required int duration,
    required String language,
    required String contentType,
    String? customPrompt,
  }) async {
    final prompt =
        '''Generate a $duration-second $contentType content in $language.
${customPrompt != null ? 'Additional requirements: $customPrompt' : ''}
Return ONLY valid JSON (no markdown):
{
  "title": "Title here",
  "hook": "Opening hook",
  "mainContent": "Main content",
  "cta": "Call to action",
  "hashtags": ["tag1", "tag2"],
  "caption": "Caption here"
}''';

    try {
      final response = await _aiService.generateText(
        prompt: prompt,
        maxTokens: 800,
        temperature: 0.7,
      );

      if (response.isSuccess && response.data != null) {
        final cleaned = _cleanJsonResponse(response.data!);
        return jsonDecode(cleaned);
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
    return {};
  }

  static Future<Map<String, dynamic>> generateContentPlan({
    required String niche,
    required int daysCount,
    required int postsPerDay,
  }) async {
    final prompt =
        '''Create a $daysCount-day $niche content plan with $postsPerDay posts per day.
Return ONLY valid JSON (no markdown):
{
  "plan": [
    {
      "day": 1,
      "posts": [
        {
          "time": "09:00",
          "topic": "Content topic",
          "type": "Educational"
        }
      ]
    }
  ]
}''';

    try {
      final response = await _aiService.generateText(
        prompt: prompt,
        maxTokens: 1000,
        temperature: 0.7,
      );

      if (response.isSuccess && response.data != null) {
        final cleaned = _cleanJsonResponse(response.data!);
        return jsonDecode(cleaned);
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
    return {};
  }

  static Future<Map<String, dynamic>> generateTargetStrategy({
    required int targetFollowers,
    required int targetViews,
    required int days,
  }) async {
    final prompt =
        '''Create a strategy to reach $targetFollowers followers and $targetViews views in $days days.
Return ONLY valid JSON (no markdown):
{
  "dailyGoals": {
    "postsPerDay": 2,
    "reelsPerDay": 1,
    "storiesPerDay": 3
  },
  "strategy": ["Point 1", "Point 2"],
  "timeline": [
    {
      "week": 1,
      "focus": "Focus area",
      "expectedGrowth": "10%"
    }
  ]
}''';

    try {
      final response = await _aiService.generateText(
        prompt: prompt,
        maxTokens: 1000,
        temperature: 0.7,
      );

      if (response.isSuccess && response.data != null) {
        final cleaned = _cleanJsonResponse(response.data!);
        return jsonDecode(cleaned);
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
    return {};
  }

  static String _cleanJsonResponse(String response) {
    String cleaned = response.trim();
    cleaned = cleaned.replaceAll(RegExp(r'^```json\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'^```\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s*```$'), '');
    return cleaned.trim();
  }
}

class FlowDiagram {
  final String id;
  final String name;
  final List<FlowNode> nodes;
  final DateTime createdAt;

  FlowDiagram({
    required this.id,
    required this.name,
    required this.nodes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nodes': nodes.map((n) => n.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory FlowDiagram.fromJson(Map<String, dynamic> json) => FlowDiagram(
        id: json['id'],
        name: json['name'],
        nodes:
            (json['nodes'] as List).map((n) => FlowNode.fromJson(n)).toList(),
        createdAt: DateTime.parse(json['createdAt']),
      );
}

class FlowNode {
  final String id;
  String title;
  String description;
  Offset position;
  final Color color;
  int sequenceOrder;

  FlowNode({
    required this.id,
    required this.title,
    required this.description,
    required this.position,
    required this.color,
    required this.sequenceOrder,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'positionX': position.dx,
        'positionY': position.dy,
        'colorValue': color.value,
        'sequenceOrder': sequenceOrder,
      };

  factory FlowNode.fromJson(Map<String, dynamic> json) => FlowNode(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        position: Offset(json['positionX'] ?? 0, json['positionY'] ?? 0),
        color: Color(json['colorValue'] ?? 0xFF6366F1),
        sequenceOrder: json['sequenceOrder'] ?? 0,
      );
}
////////
///

class AIResponse {
  final bool isSuccess;
  final String? data;
  final String? error;
  AIResponse({required this.isSuccess, this.data, this.error});
}

class PlanCard {
  final String id;
  String title;
  String description;
  Offset position;
  final Color color;

  PlanCard({
    required this.id,
    required this.title,
    required this.description,
    required this.position,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'positionX': position.dx,
        'positionY': position.dy,
        'colorValue': color.value,
      };

  factory PlanCard.fromJson(Map<String, dynamic> json) => PlanCard(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        position: Offset(json['positionX'] ?? 0, json['positionY'] ?? 0),
        color: Color(json['colorValue'] ?? 0xFF6366F1),
      );
}

class Diagram {
  final String id;
  final String name;
  final List<PlanCard> cards;
  final DateTime createdAt;

  Diagram({
    required this.id,
    required this.name,
    required this.cards,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cards': cards.map((c) => c.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Diagram.fromJson(Map<String, dynamic> json) => Diagram(
        id: json['id'],
        name: json['name'],
        cards:
            (json['cards'] as List).map((c) => PlanCard.fromJson(c)).toList(),
        createdAt: DateTime.parse(json['createdAt']),
      );
}

class DiagramListScreen extends StatefulWidget {
  const DiagramListScreen({super.key});

  @override
  State<DiagramListScreen> createState() => _DiagramListScreenState();
}

class _DiagramListScreenState extends State<DiagramListScreen> {
  List<FlowDiagram> diagrams = [];
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDiagrams();
  }

  Future<void> _loadDiagrams() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = SupaFlow.client.auth.currentUser?.id ?? 'guest';
    final data = prefs.getString('flow_diagrams_$userId');
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      setState(() {
        diagrams = jsonList.map((d) => FlowDiagram.fromJson(d)).toList();
      });
    }
  }

  Future<void> _saveDiagrams() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = SupaFlow.client.auth.currentUser?.id ?? 'guest';
    await prefs.setString(
      'flow_diagrams_$userId',
      jsonEncode(diagrams.map((d) => d.toJson()).toList()),
    );
  }

  void _createNewDiagram() {
    _nameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text('New Project', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Project name (e.g., App Marking, Research)',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFFF6B9D), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                setState(() {
                  diagrams.add(FlowDiagram(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    nodes: [],
                    createdAt: DateTime.now(),
                  ));
                });
                _saveDiagrams();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              foregroundColor: Colors.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createNewAIProject() {
    String prompt = '';
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFFFF6B9D), size: 24),
              SizedBox(width: 8),
              Text('AI Project Planner',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Describe what you want to plan, and AI will generate a step-by-step diagram for you.',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                onChanged: (v) => prompt = v,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g., Marketing plan for a new sneaker brand...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFFFF6B9D), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (isLoading) ...[
                const SizedBox(height: 20),
                const LinearProgressIndicator(
                    color: Color(0xFFFF6B9D), backgroundColor: Color(0xFF1E1E1E)),
                const SizedBox(height: 8),
                const Text('Generating your plan...',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: isLoading || prompt.isEmpty
                  ? null
                  : () async {
                      setDialogState(() => isLoading = true);
                      try {
                        final nodes =
                            await ScheduleAIService.generatePlanFromPrompt(
                                prompt, prompt);
                        if (nodes.isNotEmpty) {
                          setState(() {
                            diagrams.add(FlowDiagram(
                              id: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              name: prompt.length > 30
                                  ? '${prompt.substring(0, 27)}...'
                                  : prompt,
                              nodes: nodes,
                              createdAt: DateTime.now(),
                            ));
                          });
                          _saveDiagrams();
                          if (mounted) Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'AI failed to generate a plan. Please try again.')),
                          );
                          setDialogState(() => isLoading = false);
                        }
                      } catch (e) {
                        setDialogState(() => isLoading = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B9D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Text('Planning Hub',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: diagrams.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.dashboard_customize,
                      size: 64, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  const Text('No Projects Yet',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _createNewDiagram,
                        icon: const Icon(Icons.add),
                        label: const Text('Manual'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C2C2C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFF424242)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _createNewAIProject,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('AI Plan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B9D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: diagrams.length,
              itemBuilder: (context, index) {
                final diagram = diagrams[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FlowCanvasScreen(
                          diagram: diagram,
                          onUpdate: () {
                            _saveDiagrams();
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF2C2C2C),
                        title: const Text('Delete Project?',
                            style: TextStyle(color: Colors.white)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel',
                                style: TextStyle(color: Colors.white70)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() => diagrams.removeAt(index));
                              _saveDiagrams();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF424242),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFF6B9D).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.architecture,
                              size: 32, color: Color(0xFFFF6B9D)),
                        ),
                        const SizedBox(height: 12),
                        Text(diagram.name,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            )),
                        const SizedBox(height: 4),
                        Text('${diagram.nodes.length} steps',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF6B9D),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: const Color(0xFF2C2C2C),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.add, color: Colors.white),
                  title: const Text('Create Manual Project',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _createNewDiagram();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.auto_awesome,
                      color: Color(0xFFFF6B9D)),
                  title: const Text('Generate with AI',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _createNewAIProject();
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ============ Flow Canvas Screen ============

class FlowCanvasScreen extends StatefulWidget {
  final FlowDiagram diagram;
  final VoidCallback onUpdate;

  const FlowCanvasScreen({
    required this.diagram,
    required this.onUpdate,
    super.key,
  });

  @override
  State<FlowCanvasScreen> createState() => _FlowCanvasScreenState();
}

class _FlowCanvasScreenState extends State<FlowCanvasScreen> {
  late FlowDiagram diagram;
  double zoomLevel = 1.0;
  Offset canvasOffset = Offset.zero;
  bool isGenerating = false;
  final double minZoom = 0.5;
  final double maxZoom = 3.0;

  // For smooth pinch-to-zoom and panning
  double _initialZoom = 1.0;
  Offset _initialFocalPoint = Offset.zero;
  Offset _initialOffset = Offset.zero;
  int _pointerCount = 0;

  @override
  void initState() {
    super.initState();
    diagram = widget.diagram;
  }

  void _addNodeManually() {
    String title = '';
    String description = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text('Add Step', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (v) => title = v,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Step title',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFFFF6B9D), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => description = v,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Description',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFFFF6B9D), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () {
              if (title.isNotEmpty) {
                setState(() {
                  const colors = [
                    Color(0xFFFF6B9D),
                    Color(0xFF8B5CF6),
                    Color(0xFFEC4899),
                    Color(0xFF00D4FF),
                    Color(0xFFF97316),
                  ];
                  diagram.nodes.add(FlowNode(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: title,
                    description: description,
                    position: Offset(50.0 + (diagram.nodes.length * 160), 100),
                    color: colors[diagram.nodes.length % colors.length],
                    sequenceOrder: diagram.nodes.length,
                  ));
                });
                widget.onUpdate();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }


  void _editNode(FlowNode node) {
    String title = node.title;
    String description = node.description;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Edit Step', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: node.title),
                onChanged: (v) => title = v,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Title',
                  filled: true,
                  fillColor: const Color(0xFF374151),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: TextEditingController(text: node.description),
                onChanged: (v) => description = v,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Description',
                  filled: true,
                  fillColor: const Color(0xFF374151),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteNode(node.id);
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete Step'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                node.title = title;
                node.description = description;
              });
              widget.onUpdate();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteNode(String nodeId) {
    setState(() => diagram.nodes.removeWhere((n) => n.id == nodeId));
    widget.onUpdate();
  }

  void _showTimeline() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2937),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Timeline View',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: diagram.nodes.length,
                itemBuilder: (context, index) {
                  final node = diagram.nodes[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: node.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Text('${index + 1}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(node.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              Text(node.description,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Zoom in button handler
  void _zoomIn() {
    setState(() {
      zoomLevel = (zoomLevel + 0.2).clamp(minZoom, maxZoom);
    });
  }

  // Zoom out button handler
  void _zoomOut() {
    setState(() {
      zoomLevel = (zoomLevel - 0.2).clamp(minZoom, maxZoom);
    });
  }

  // Reset zoom and position
  void _resetZoom() {
    setState(() {
      zoomLevel = 1.0;
      canvasOffset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    double maxX = 0;
    double maxY = 0;
    for (var node in diagram.nodes) {
      if (node.position.dx + 140 > maxX) maxX = node.position.dx + 140;
      if (node.position.dy + 120 > maxY) maxY = node.position.dy + 120;
    }
    // Ensure minimum canvas size and add padding
    final canvasWidth = (maxX + 200).clamp(2000.0, double.infinity);
    final canvasHeight = (maxY + 200).clamp(1500.0, double.infinity);
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        elevation: 0,
        title: Text(diagram.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text('${(zoomLevel * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.timeline),
              onPressed: _showTimeline,
              tooltip: 'Timeline',
            ),
          ),
        ],
      ),
      body: Listener(
        onPointerDown: (_) => _pointerCount++,
        onPointerUp: (_) => _pointerCount--,
        child: GestureDetector(
          onScaleStart: (details) {
            _initialZoom = zoomLevel;
            _initialFocalPoint = details.focalPoint;
            _initialOffset = canvasOffset;
          },
          onScaleUpdate: (details) {
            setState(() {
              // Only zoom if two fingers are detected (pinch gesture)
              if (_pointerCount > 1) {
                // Calculate new zoom level
                double newZoom =
                    (_initialZoom * details.scale).clamp(minZoom, maxZoom);

                // Calculate the point under the focal point before zoom
                final Offset focalPointOnCanvas =
                    (_initialFocalPoint - _initialOffset) / _initialZoom;

                // Update zoom
                zoomLevel = newZoom;

                // Adjust offset to keep the focal point stationary
                canvasOffset =
                    details.focalPoint - (focalPointOnCanvas * zoomLevel);
              } else {
                // Single finger - just pan
                canvasOffset =
                    _initialOffset + (details.focalPoint - _initialFocalPoint);
              }
            });
          },
          onDoubleTap: _resetZoom,
          child: Container(
            color: const Color(0xFF111827),
            child: Stack(
              children: [
                // Canvas content with zoom and pan
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Transform(
                      transform: Matrix4.diagonal3Values(zoomLevel, zoomLevel, 1.0)
                        ..translate(canvasOffset.dx, canvasOffset.dy),
                      child: SizedBox(
                        width: canvasWidth,
                        height: canvasHeight,
                        child: Stack(
                          children: [
                            // Draw arrows between nodes
                            for (int i = 0; i < diagram.nodes.length - 1; i++)
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: ArrowPainter(
                                    start: Offset(
                                      diagram.nodes[i].position.dx + 70,
                                      diagram.nodes[i].position.dy + 60,
                                    ),
                                    end: Offset(
                                      diagram.nodes[i + 1].position.dx + 70,
                                      diagram.nodes[i + 1].position.dy + 60,
                                    ),
                                  ),
                                ),
                              ),
                            // Draw nodes
                            ...diagram.nodes.map((node) {
                              return Positioned(
                                left: node.position.dx,
                                top: node.position.dy,
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    setState(() {
                                      node.position = node.position +
                                          (details.delta / zoomLevel);
                                    });
                                    widget.onUpdate();
                                  },
                                  onTap: () => _editNode(node),
                                  child: Container(
                                    width: 140,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: node.color,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              node.color.withValues(alpha: 0.4),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          node.title,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          node.description,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Zoom controls overlay (top-right corner)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        mini: true,
                        heroTag: 'zoom_in',
                        backgroundColor: const Color(0xFF1F2937),
                        onPressed: _zoomIn,
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        mini: true,
                        heroTag: 'zoom_out',
                        backgroundColor: const Color(0xFF1F2937),
                        onPressed: _zoomOut,
                        child: const Icon(Icons.remove, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        mini: true,
                        heroTag: 'zoom_reset',
                        backgroundColor: const Color(0xFF1F2937),
                        onPressed: _resetZoom,
                        child: const Icon(Icons.center_focus_strong,
                            color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            backgroundColor: const Color(0xFF10B981),
            onPressed: _addNodeManually,
            tooltip: 'Add step manually',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  final Offset start;
  final Offset end;

  ArrowPainter({required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    const arrowSize = 15.0;
    final paint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, paint);

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = sqrt(dx * dx + dy * dy);

    if (distance == 0) return;

    final angle = atan2(dy, dx);

    final arrowPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      end,
      Offset(end.dx - arrowSize * cos(angle - pi / 6),
          end.dy - arrowSize * sin(angle - pi / 6)),
      arrowPaint,
    );
    canvas.drawLine(
      end,
      Offset(end.dx - arrowSize * cos(angle + pi / 6),
          end.dy - arrowSize * sin(angle + pi / 6)),
      arrowPaint,
    );
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) => true;
}

// Removed GrowthDashboard and Content AI features

// Mock AI Service - Replace with your actual implementation


