import 'package:pocket_mates_app/custom_code/widgets/ai_prompt_service.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/drawing_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/teams_home_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/poster_designer/template_gallery_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/bulk_sender/bulk_sender_page.dart';
import 'package:flutter/services.dart';
import 'package:pocket_mates_app/custom_code/widgets/poki_games_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/nearby_users_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/chess_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/dynamic_web_view_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/diagram_ai_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/password_generator_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/share_content_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'package:pocket_mates_app/custom_code/widgets/drawing_academy_home_page.dart';

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

  List<ScheduleItem> _schedules = [];

  List<String> _completedTasks = [];
  List<String> _completedChallenges = [];

  String _toolsSearchQuery = '';
  List<String> _favoritedTools = [];

  void initState() {
    super.initState();
    if (widget.initialTab != null) {
      _selectedTab = widget.initialTab!;
      _showToolsList = false;
    }
    _loadData();
    _loadFavoritedTools();
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

    final tasksJson = prefs.getString('tasks') ?? '[]';
    final tasksList = jsonDecode(tasksJson) as List;
    tasks = tasksList.map((task) => Task.fromJson(task)).toList();

    final challengesJson = prefs.getString('challenges') ?? '[]';
    final challengesList = jsonDecode(challengesJson) as List;
    challenges = challengesList
        .map((challenge) => Challenge.fromJson(challenge))
        .toList();

    final scheduleJson = prefs.getString('schedule') ?? '[]';
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
    final tasksJson = jsonEncode(tasks.map((task) => task.toJson()).toList());
    final challengesJson =
        jsonEncode(challenges.map((challenge) => challenge.toJson()).toList());
    final scheduleJson =
        jsonEncode(dailySchedule.map((item) => item.toJson()).toList());

    await prefs.setString('tasks', tasksJson);
    await prefs.setString('challenges', challengesJson);
    await prefs.setString('schedule', scheduleJson);
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
        SnackBar(
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
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
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
          backgroundColor: Color(0xFFE57373),
        ),
      );
    }
  }

  void _addScheduleItem() {
    if (scheduleController.text.trim().isEmpty ||
        selectedStartTime == null ||
        selectedEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
        color: Color(0xFF424242),
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
        return Color(0xFFE57373);
      case TaskPriority.medium:
        return Color(0xFFFFB74D);
      case TaskPriority.low:
        return Color(0xFF81C784);
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
        return 'Courses';
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
        'color': Colors.purpleAccent,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const DrawingPage())),
      },
      {
        'title': 'Schedule',
        'icon': Icons.calendar_today_rounded,
        'color': Colors.blueAccent,
        'onTap': () => setState(() {
              _selectedTab = 0;
              _showToolsList = false;
            }),
      },
      {
        'title': 'Tasks',
        'icon': Icons.check_circle_outline_rounded,
        'color': Colors.greenAccent,
        'onTap': () => setState(() {
              _selectedTab = 1;
              _showToolsList = false;
            }),
      },
      {
        'title': 'Challenges',
        'icon': Icons.emoji_events_outlined,
        'color': Colors.orangeAccent,
        'onTap': () => setState(() {
              _selectedTab = 2;
              _showToolsList = false;
            }),
      },
      {
        'title': 'Diagrams',
        'icon': Icons.schema_rounded,
        'color': Colors.tealAccent,
        'onTap': () => setState(() {
              _selectedTab = 3;
              _showToolsList = false;
            }),
      },
      {
        'title': 'Teams',
        'icon': Icons.groups_rounded,
        'color': Colors.pinkAccent,
        'onTap': () => setState(() {
              _selectedTab = 4;
              _showToolsList = false;
            }),
      },
      {
        'title': 'AI Tools',
        'icon': Icons.auto_awesome,
        'color': Colors.cyanAccent,
        'onTap': () => setState(() {
              _selectedTab = 5;
              _showToolsList = false;
            }),
      },
      {
        'title': 'Poster Maker',
        'icon': Icons.photo_library_rounded,
        'color': Colors.orangeAccent,
        'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const TemplateGalleryPage())),
      },
      {
        'title': 'Bulk Sender',
        'icon': Icons.send_rounded,
        'color': Colors.greenAccent,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const BulkSenderPage())),
      },
      {
        'title': 'Poki Games',
        'subtitle': 'poki.com',
        'icon': Icons.videogame_asset_rounded,
        'color': Colors.redAccent,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const PokiGamesPage())),
      },
      {
        'title': 'Crazy Games',
        'subtitle': 'crazygames.com',
        'icon': Icons.sports_esports_rounded,
        'color': Colors.deepOrangeAccent,
        'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const DynamicWebViewPage(
                      title: 'Crazy Games',
                      url: 'https://crazygames.com',
                    ))),
      },
      {
        'title': 'Dynamic Web App',
        'subtitle': 'Any URL',
        'icon': Icons.public_rounded,
        'color': Colors.lightBlueAccent,
        'onTap': () => _showDynamicWebAppDialog(),
      },
      {
        'title': 'Chess Match',
        'icon': Icons.casino_rounded,
        'color': Colors.amberAccent,
        'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ChessMatchmakingPage())),
      },
      {
        'title': 'Travel Radar',
        'icon': Icons.radar,
        'color': Colors.cyanAccent,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const NearbyUsersPage())),
      },
      {
        'title': 'Diagram AI',
        'subtitle': 'Architect with AI',
        'icon': Icons.account_tree_rounded,
        'color': Colors.blueAccent,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const DiagramAiPage())),
      },
      {
        'title': 'Password Pro',
        'subtitle': 'Secure Generator',
        'icon': Icons.password_rounded,
        'color': Colors.greenAccent,
        'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const PasswordGeneratorPage())),
      },
      {
        'title': 'AI Studio',
        'subtitle': 'Creative Engine',
        'icon': Icons.auto_awesome,
        'color': Colors.purpleAccent,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AiPromptGenerator())),
      },
      {
        'title': 'QR & Barcode',
        'subtitle': 'Scan & Generate',
        'icon': Icons.qr_code_scanner_rounded,
        'color': Colors.orangeAccent,
        'onTap': () => _showQRCodeSimulation(),
      },
      {
        'title': 'World Clock',
        'subtitle': 'Global Times',
        'icon': Icons.public_rounded,
        'color': Colors.lightBlueAccent,
        'onTap': () => _showWorldClockSimulation(),
      },
      {
        'title': 'WhatsApp Web',
        'subtitle': 'Chat on Desktop',
        'icon': Icons.chat_rounded,
        'color': Colors.greenAccent,
        'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const DynamicWebViewPage(
                      title: 'WhatsApp Web',
                      url: 'https://web.whatsapp.com',
                    ))),
      },
      {
        'title': 'Gallery Sharing',
        'subtitle': 'Share from Gallery',
        'icon': Icons.share_rounded,
        'color': Colors.blueAccent,
        'onTap': () {
          final userId = SupaFlow.client.auth.currentUser?.id ?? '';
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ShareContentScreen(
                        contentToShare: 'Sharing from Gallery',
                        currentUserId: userId,
                        contentType: 'gallery',
                      )));
        },
      },
      {
        'title': 'Web Search',
        'subtitle': 'Search the Internet',
        'icon': Icons.travel_explore_rounded,
        'color': Colors.orangeAccent,
        'onTap': () => _showWebSearchDialog(),
      },
      {
        'title': 'Courses',
        'subtitle': 'Learning Academy',
        'icon': Icons.school_rounded,
        'color': Colors.blue,
        'onTap': () => setState(() {
              _selectedTab = 7;
              _showToolsList = false;
            }),
      },
    ];

    final filteredTools = allTools
        .where((tool) => (tool['title'] as String)
            .toLowerCase()
            .contains(_toolsSearchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF161618),
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
                                    color: Colors.white70,
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
                            color: Colors.white.withValues(alpha: 0.05),
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
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
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
                        style: GoogleFonts.outfit(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: _isWebSearchMode ? 'Search Google...' : 'Search tools or features...',
                          hintStyle: GoogleFonts.outfit(color: _isWebSearchMode ? Colors.yellow.withValues(alpha: 0.5) : Colors.white38),
                          prefixIcon: Icon(
                            _isWebSearchMode ? Icons.travel_explore_rounded : Icons.search, 
                            color: _isWebSearchMode ? Colors.yellow : Colors.white54,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.public_rounded,
                              color: _isWebSearchMode ? Colors.yellow : Colors.white38,
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
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isFav
                              ? (tool['color'] as Color).withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.05),
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
                                          color: Colors.white,
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
                                              color: Colors.white54,
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
      backgroundColor: Color(0xFF121212),
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
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
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
                        color: Colors.white,
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
                        : Colors.yellow.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (_selectedTab == 0 && _showAddSchedule) ||
                              (_selectedTab == 1 && _showAddTask) ||
                              (_selectedTab == 2 && _showAddChallenge)
                          ? const Color(0xFF424242)
                          : Colors.yellow.withValues(alpha: 0.5),
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
                            : Colors.yellow,
                        size: 20,
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
                              : Colors.yellow,
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF424242)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: taskController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'What needs to be done?',
              hintStyle: TextStyle(color: Color(0xFF757575)),
              filled: true,
              fillColor: Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: taskNotesController,
            style: TextStyle(color: Colors.white),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Add notes (optional)',
              hintStyle: TextStyle(color: Color(0xFF757575)),
              filled: true,
              fillColor: Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text('Priority: ',
                  style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 14)),
              ...TaskPriority.values.map(
                (priority) => GestureDetector(
                  onTap: () => setState(() => selectedPriority = priority),
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selectedPriority == priority
                          ? _getPriorityColor(priority)
                          : Color(0xFF424242),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      priority.toString().split('.').last.toUpperCase(),
                      style: TextStyle(
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
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addTask,
              child: Text('Add Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddScheduleForm() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF424242)),
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
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          !_useAISchedule ? Colors.yellow : Color(0xFF424242),
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
              SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _useAISchedule = true),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _useAISchedule ? Colors.yellow : Color(0xFF424242),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                        SizedBox(width: 4),
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
          SizedBox(height: 16),

          if (!_useAISchedule) ...[
            TextField(
              controller: scheduleController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Activity name',
                hintStyle: TextStyle(color: Color(0xFF757575)),
                filled: true,
                fillColor: Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12),
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
                              colorScheme: ColorScheme.dark(
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
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time,
                              color: Color(0xFFFF6B9D), size: 20),
                          SizedBox(width: 8),
                          Text(
                            selectedStartTime != null
                                ? selectedStartTime!.format(context)
                                : 'Start time',
                            style: TextStyle(
                              color: selectedStartTime != null
                                  ? Colors.white
                                  : Color(0xFF757575),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedEndTime ?? TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: ColorScheme.dark(
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
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time,
                              color: Color(0xFFFF6B9D), size: 20),
                          SizedBox(width: 8),
                          Text(
                            selectedEndTime != null
                                ? selectedEndTime!.format(context)
                                : 'End time',
                            style: TextStyle(
                              color: selectedEndTime != null
                                  ? Colors.white
                                  : Color(0xFF757575),
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
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addScheduleItem,
                child: Text(_editingScheduleId != null
                    ? 'Update Schedule'
                    : 'Add Schedule'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF6B9D),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ] else ...[
            TextField(
              controller: aiScheduleController,
              style: TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Describe your day:\ne.g., "Wake at 6am, workout 30min, work 9-5, lunch at 1pm, sleep 11pm"',
                hintStyle: TextStyle(color: Color(0xFF757575)),
                filled: true,
                fillColor: Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isGeneratingSchedule ? null : _generateAISchedule,
                child: _isGeneratingSchedule
                    ? Row(
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
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, size: 18),
                          SizedBox(width: 8),
                          Text('Generate Schedule'),
                        ],
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF6B9D),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
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
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF424242)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: challengeController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Challenge name',
              hintStyle: TextStyle(color: Color(0xFF757575)),
              filled: true,
              fillColor: Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) =>
                      challengeDuration = int.tryParse(value) ?? 21,
                  decoration: InputDecoration(
                    hintText: '21',
                    hintStyle: TextStyle(color: Color(0xFF757575)),
                    filled: true,
                    fillColor: Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              ...ChallengeType.values.map(
                (type) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedChallengeType = type),
                    child: Container(
                      margin: EdgeInsets.only(left: 4),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedChallengeType == type
                            ? Color(0xFF4CAF50)
                            : Color(0xFF424242),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getChallengeTypeText(type),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addChallenge,
              child: Text('Create Challenge'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
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
      padding: EdgeInsets.symmetric(horizontal: 24),
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
      padding: EdgeInsets.symmetric(horizontal: 24),
      itemCount: dailySchedule.length,
      itemBuilder: (context, index) {
        return _buildScheduleCard(dailySchedule[index]);
      },
    );
  }

  Widget _buildChallengesList() {
    if (challenges.isEmpty) {
      return _buildEmptyState(
        'No challenges yet',
        'Create your first challenge',
        Icons.emoji_events_outlined,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24),
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
      margin: EdgeInsets.only(bottom: 12),
      child: Hero(
        tag: 'task_${task.id}',
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: task.isCompleted ? Color(0xFF4CAF50) : Color(0xFF424242),
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
                              ? Color(0xFF4CAF50)
                              : Colors.transparent,
                          border: Border.all(
                            color: task.isCompleted
                                ? Color(0xFF4CAF50)
                                : Color(0xFF757575),
                            width: 2,
                          ),
                        ),
                        child: task.isCompleted
                            ? Icon(Icons.check, color: Colors.white, size: 14)
                            : null,
                      ),
                    ),
                    SizedBox(width: 12),
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
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _deleteTask(task.id),
                      child:
                          Icon(Icons.close, color: Color(0xFF757575), size: 20),
                    ),
                    SizedBox(width: 14),
                  ],
                ),
                if (task.notes != null && task.notes!.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text(
                    task.notes!,
                    style: TextStyle(
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
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isCompleted ? Color(0xFF4CAF50) : Color(0xFF424242),
          width: item.isCompleted ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Time column
          Container(
            width: 80,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  startStr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  width: 2,
                  height: 20,
                  color: Color(0xFFFF6B9D),
                ),
                SizedBox(height: 4),
                Text(
                  endStr,
                  style: TextStyle(
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
            color: Color(0xFF424242),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
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
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF6B9D),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
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
                    SizedBox(height: 4),
                    Text(
                      item.description!,
                      style: TextStyle(
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
            padding: EdgeInsets.all(16),
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
                          ? Color(0xFF4CAF50)
                          : Colors.transparent,
                      border: Border.all(
                        color: item.isCompleted
                            ? Color(0xFF4CAF50)
                            : Color(0xFF757575),
                        width: 2,
                      ),
                    ),
                    child: item.isCompleted
                        ? Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _editScheduleItem(item),
                  child: Icon(Icons.edit, color: Color(0xFF757575), size: 18),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _deleteScheduleItem(item.id),
                  child: Icon(Icons.delete, color: Color(0xFF757575), size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    final now = DateTime.now();
    final daysPassed = now.difference(challenge.startDate).inDays + 1;
    final completedDays = challenge.dailyTicks.length;
    final percentage =
        (completedDays / challenge.totalDays * 100).clamp(0, 100);
    final isCompleted =
        daysPassed >= challenge.totalDays || challenge.isCompleted;

    final today = DateTime.now();
    final todayKey = "${today.year}-${today.month}-${today.day}";
    final isTodayCompleted = challenge.dailyTicks.containsKey(todayKey);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? Color(0xFF4CAF50) : Color(0xFF424242),
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  challenge.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isCompleted)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'COMPLETED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () => _deleteChallenge(challenge.id),
                child: Icon(Icons.close, color: Color(0xFF757575), size: 20),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Progress bar
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Color(0xFF424242),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedDays / ${challenge.totalDays} days',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              Text(
                '${percentage.toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          if (!isCompleted) ...[
            SizedBox(height: 12),
            GestureDetector(
              onTap: () => _toggleChallengeDay(challenge.id),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isTodayCompleted ? Color(0xFF4CAF50) : Color(0xFF424242),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isTodayCompleted
                        ? Color(0xFF4CAF50)
                        : Color(0xFF757575),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isTodayCompleted ? Icons.check : Icons.add,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      isTodayCompleted
                          ? 'Completed Today'
                          : 'Mark Today Complete',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
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
        return _buildAIToolsTab();
      case 6:
        return _buildMiniAppsTab();
      case 7:
        return const DrawingAcademyHomePage();
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
              MaterialPageRoute(builder: (context) => const DrawingPage()),
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

  Widget _buildAIToolsTab() {
    return const GrowthDashboard();
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
    final systemPrompt =
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
        Color(0xFFFFE082),
        Color(0xFFFFB74D),
        Color(0xFF81C784),
        Color(0xFFE3F2FD),
        Color(0xFFF3E5F5),
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
    final systemPrompt =
        '''Generate a detailed workflow plan based on the user's request.
    Return a JSON array of plan items with this format:
    [{"title": "Task name", "description": "Brief description"}]
    Only return valid JSON, no other text.''';

    final fullPrompt =
        '$systemPrompt\n\nUser request: $userPrompt\n\nDiagram: $diagramName';

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
        '''Generate a ${duration}-second ${contentType} content in ${language}.
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
        '''Create a ${daysCount}-day ${niche} content plan with ${postsPerDay} posts per day.
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
        '''Create a strategy to reach ${targetFollowers} followers and ${targetViews} views in ${days} days.
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
  const DiagramListScreen({Key? key}) : super(key: key);

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
    final data = prefs.getString('flow_diagrams');
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      setState(() {
        diagrams = jsonList.map((d) => FlowDiagram.fromJson(d)).toList();
      });
    }
  }

  Future<void> _saveDiagrams() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'flow_diagrams',
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
    // Show dialog for AI Project creation
    // For now just create empty
    _createNewDiagram();
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
                  ElevatedButton.icon(
                    onPressed: _createNewDiagram,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Project'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B9D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
                          child: Icon(Icons.architecture,
                              size: 32, color: const Color(0xFFFF6B9D)),
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
        onPressed: _createNewDiagram,
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
    Key? key,
  }) : super(key: key);

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

  Future<void> _generateWithAI() async {
    final promptController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title:
            const Text('AI Generation', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: promptController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Describe your workflow or plan...',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF374151),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              _showLoadingDialog();

              try {
                final nodes = await ScheduleAIService.generatePlanFromPrompt(
                  promptController.text,
                  diagram.name,
                );
                if (mounted) {
                  Navigator.pop(context);
                  setState(() => diagram.nodes.addAll(nodes));
                  widget.onUpdate();
                }
              } catch (e) {
                if (mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6)),
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.black54,
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF10B981)),
              SizedBox(height: 20),
              Text('Generating workflow...',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
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
                      transform: Matrix4.identity()
                        ..translate(canvasOffset.dx, canvasOffset.dy)
                        ..scale(zoomLevel),
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
                            }).toList(),
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
            heroTag: 'ai',
            backgroundColor: const Color(0xFF8B5CF6),
            onPressed: _generateWithAI,
            tooltip: 'Generate with AI',
            child: const Icon(Icons.auto_awesome),
          ),
          const SizedBox(height: 12),
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

////
// Content ai

// AI Service Response Model
class AICResponse {
  final bool isSuccess;
  final String? data;
  final String? error;

  AICResponse({
    required this.isSuccess,
    this.data,
    this.error,
  });
}

// Mock AI Service - Replace with your actual implementation

class GrowthDashboard extends StatefulWidget {
  const GrowthDashboard({super.key});

  @override
  State<GrowthDashboard> createState() => _GrowthDashboardState();
}

class _GrowthDashboardState extends State<GrowthDashboard> {
  final AIService _aiService = AIService();
  int _currentTab = 0;
  bool _isLoading = false;

  // Account Setup
  TextEditingController accountNameController = TextEditingController();
  TextEditingController currentFollowersController = TextEditingController();
  TextEditingController currentViewsController = TextEditingController();

  int currentFollowers = 0;
  int currentViews = 0;
  String accountName = '';

  // Growth Plan
  int targetFollowers = 100000;
  int planDays = 30;
  String planNiche = 'Tech';
  Map<String, dynamic>? growthPlan;

  // Content Generation
  String contentType = 'Reel';
  int duration = 30;
  String language = 'English';
  String customPrompt = '';
  Map<String, dynamic>? generatedContent;

  // Daily Tracking
  List<DailyMetric> dailyMetrics = [];

  // Target Goals
  int dailyPostTarget = 2;
  int dailyViewsTarget = 5000;
  int dailyFollowerTarget = 50;
  // Short Film Generation
// Short Film Generation
  int shortFilmDuration = 60;
  String shortFilmLanguage = 'English';
  String shortFilmGenre = 'Emotional Drama';
  String shortFilmMessage = '';
  String shortFilmCharacters = '2';
  Map<String, dynamic>? generatedShortFilm;

  final List<String> filmDurations = ['30', '60', '90', '120', '180', '300'];
  final List<String> filmGenres = [
    'Emotional Drama',
    'Love Story',
    'Friendship',
    'Family Bonding',
    'Life Lesson',
    'Motivational',
    'Comedy',
    'Suspense',
    'Social Message',
    'Inspiration'
  ];
  final List<String> characterCounts = ['2', '3', '4', '5'];
  final List<String> niches = [
    'Tech',
    'Lifestyle',
    'Beauty',
    'Fitness',
    'Food',
    'Education',
    'Entertainment',
    'Travel',
    'Business',
    'Art',
    'Health & Wellness',
    'Fashion',
    'Gaming',
    'Finance',
    'Photography',
    'Music',
    'Sports',
    'Parenting',
    'Environment',
    'Self-Improvement',
    'Mental Health',
    'DIY & Crafts',
    'Pets',
    'Automotive',
    'Real Estate',
    'Politics',
    'Personal Development',
    'Home Decor',
    'Science',
    'Technology Trends',
    'E-commerce',
    'Marketing',
    'Social Media',
    'Food & Drink',
    'Culture',
    'Philanthropy',
    'Spirituality',
    'Luxury',
  ];

  final List<String> contentTypes = ['Reel', 'Carousel', 'Story', 'Post'];
  final List<int> durations = [15, 30, 60, 90];

  @override
  void initState() {
    super.initState();
    accountNameController.text = 'My Account';
    currentFollowersController.text = '1250';
    currentViewsController.text = '45000';
    _updateInitialValues();
  }

  void _updateInitialValues() {
    setState(() {
      accountName = accountNameController.text;
      currentFollowers = int.tryParse(currentFollowersController.text) ?? 0;
      currentViews = int.tryParse(currentViewsController.text) ?? 0;
    });
  }

  @override
  void dispose() {
    accountNameController.dispose();
    currentFollowersController.dispose();
    currentViewsController.dispose();
    super.dispose();
  }

  String _cleanJsonResponse(String response) {
    String cleaned = response.trim();
    cleaned = cleaned.replaceAll(RegExp(r'^```json\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'^```\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s*```$'), '');
    return cleaned.trim();
  }

  Future<void> _generateContentAI() async {
    setState(() => _isLoading = true);
    try {
      final prompt =
          '''Generate a $duration-second $contentType content for $planNiche niche in $language language.
${customPrompt.isNotEmpty ? 'Additional requirements: $customPrompt' : ''}

Return ONLY valid JSON (no markdown, no extra text):
{
  "title": "Engaging title for the content",
  "hook": "Attention-grabbing opening hook",
  "mainContent": "Main valuable content body",
  "cta": "Clear call to action",
  "hashtags": ["tag1", "tag2", "tag3", "tag4", "tag5"],
  "caption": "Full engaging caption with emojis",
  "bestTimeToPost": "HH:MM",
  "estimatedReach": "number"
}''';

      final response = await _aiService.generateText(
        prompt: prompt,
        maxTokens: 800,
        temperature: 0.7,
      );

      if (response.isSuccess && response.data != null) {
        final cleaned = _cleanJsonResponse(response.data!);
        final content = jsonDecode(cleaned);
        setState(() {
          generatedContent = content;
          _isLoading = false;
        });
        _showSnackBar('✓ Content generated successfully!', Colors.green);
      } else {
        setState(() => _isLoading = false);
        _showSnackBar('✗ Error: ${response.error}', Colors.red);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('✗ Error: $e', Colors.red);
    }
  }

  Future<void> _generateGrowthPlan() async {
    setState(() => _isLoading = true);
    try {
      final followersNeeded = targetFollowers - currentFollowers;
      final dailyFollowerGrowth = (followersNeeded / planDays).ceil();

      final prompt =
          '''You are an Instagram growth expert. Create a detailed growth strategy.

Account Details:
- Account Name: $accountName
- Current Followers: $currentFollowers
- Current Views: $currentViews
- Target Followers: $targetFollowers
- Time Frame: $planDays days
- Niche: $planNiche

Create specific, actionable growth strategies.

Return ONLY valid JSON (no markdown):
{
  "accountName": "$accountName",
  "currentFollowers": $currentFollowers,
  "targetFollowers": $targetFollowers,
  "planDays": $planDays,
  "dailyFollowerTarget": $dailyFollowerGrowth,
  "strategy": ["strategy point 1", "strategy point 2", "strategy point 3", "strategy point 4", "strategy point 5"],
  "weekly": [
    {"week": 1, "targetFollowers": ${currentFollowers + (dailyFollowerGrowth * 7)}, "expectedEngagementRate": "3.5%"},
    {"week": 2, "targetFollowers": ${currentFollowers + (dailyFollowerGrowth * 14)}, "expectedEngagementRate": "4.2%"},
    {"week": 3, "targetFollowers": ${currentFollowers + (dailyFollowerGrowth * 21)}, "expectedEngagementRate": "5.1%"},
    {"week": 4, "targetFollowers": ${currentFollowers + (dailyFollowerGrowth * 28)}, "expectedEngagementRate": "5.8%"}
  ]
}''';

      final response = await _aiService.generateText(
        prompt: prompt,
        maxTokens: 1500,
        temperature: 0.7,
      );

      if (response.isSuccess && response.data != null) {
        final cleaned = _cleanJsonResponse(response.data!);
        final plan = jsonDecode(cleaned);
        setState(() {
          growthPlan = plan;
          _isLoading = false;
        });
        _showSnackBar('✓ Growth plan created!', Colors.green);
      } else {
        setState(() => _isLoading = false);
        _showSnackBar('✗ Error: ${response.error}', Colors.red);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('✗ Error: $e', Colors.red);
    }
  }

  void _recordDailyMetric() {
    if (dailyMetrics.isNotEmpty && dailyMetrics[0].date == 'Today') {
      dailyMetrics[0] = DailyMetric(
          'Today', dailyPostTarget, dailyViewsTarget, dailyFollowerTarget);
    } else {
      final today = DateTime.now().toString().split(' ')[0];
      dailyMetrics.insert(
          0,
          DailyMetric(
              today, dailyPostTarget, dailyViewsTarget, dailyFollowerTarget));
    }
    setState(() {
      currentFollowers += dailyFollowerTarget;
      currentViews += dailyViewsTarget;
    });
    _showSnackBar('✓ Daily metrics recorded!', Colors.green);
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('✓ Copied to clipboard!', const Color(0xFF2196F3));
  }

  Future<void> _generateShortFilm() async {
    setState(() => _isLoading = true);
    try {
      final prompt =
          '''You are a professional $shortFilmLanguage language screenwriter. 

CRITICAL INSTRUCTION: You MUST write EVERYTHING in $shortFilmLanguage language ONLY. 
- Every single word must be in $shortFilmLanguage
- All dialogues must be in $shortFilmLanguage
- All descriptions must be in $shortFilmLanguage  
- All character names can be in $shortFilmLanguage style
- All locations must be described in $shortFilmLanguage
- DO NOT use English or any other language
- Use native $shortFilmLanguage expressions and cultural context

If language is Malayalam: Write everything in Malayalam script (മലയാളം)
If language is Tamil: Write everything in Tamil script (தமிழ்)
If language is Hindi: Write everything in Hindi script (हिंदी)
If language is Telugu: Write everything in Telugu script (తెలుగు)

Film Details:
- Duration: $shortFilmDuration seconds
- Genre: $shortFilmGenre
- Language: $shortFilmLanguage (USE THIS LANGUAGE FOR EVERYTHING)
- Number of Characters: $shortFilmCharacters
- Core Message: ${shortFilmMessage.isNotEmpty ? shortFilmMessage : 'Create an impactful, emotional story'}

Create a DIALOGUE-HEAVY script with:
1. Powerful, meaningful conversations in $shortFilmLanguage that touch hearts
2. Natural, realistic $shortFilmLanguage dialogues people can relate to
3. Emotional depth through character interactions in $shortFilmLanguage
4. Clear beginning, middle, and powerful ending in $shortFilmLanguage
5. Strong message delivered through $shortFilmLanguage dialogues
6. Cultural context appropriate for $shortFilmLanguage speakers

REMEMBER: Write the ENTIRE response in $shortFilmLanguage language. Not a single word should be in English except the JSON structure keys.

Return ONLY valid JSON (keys in English, all values in $shortFilmLanguage):
{
  "title": "Film title in $shortFilmLanguage",
  "logline": "One-line summary in $shortFilmLanguage",
  "coreMessage": "The deep message/moral in $shortFilmLanguage",
  "genre": "$shortFilmGenre in $shortFilmLanguage",
  "targetAudience": "Who will connect with this story in $shortFilmLanguage",
  "emotionalTone": "The feeling this creates in $shortFilmLanguage",
  "characters": [
    {
      "name": "Character name in $shortFilmLanguage style",
      "age": "Age range in $shortFilmLanguage",
      "role": "Their role in story in $shortFilmLanguage",
      "personality": "Brief personality in $shortFilmLanguage"
    }
  ],
  "completeScript": [
    {
      "scene": 1,
      "duration": "15 seconds in $shortFilmLanguage",
      "location": "Location description in $shortFilmLanguage",
      "timeOfDay": "Day/Night/Evening in $shortFilmLanguage",
      "visualDescription": "What we see on screen in $shortFilmLanguage",
      "dialogues": [
        {
          "character": "Character Name in $shortFilmLanguage",
          "dialogue": "Complete dialogue line in pure $shortFilmLanguage",
          "emotion": "How they say it in $shortFilmLanguage",
          "action": "What they do while speaking in $shortFilmLanguage"
        }
      ],
      "cameraDirection": "Shot type in $shortFilmLanguage",
      "audioCue": "Background sound/music mood in $shortFilmLanguage"
    }
  ],
  "storyBreakdown": {
    "opening": "How story starts in $shortFilmLanguage",
    "conflict": "The problem/tension in $shortFilmLanguage",
    "climax": "The turning point in $shortFilmLanguage",
    "resolution": "How it ends in $shortFilmLanguage"
  },
  "keyDialogues": [
    "Most powerful dialogue line 1 in pure $shortFilmLanguage",
    "Most powerful dialogue line 2 in pure $shortFilmLanguage",
    "Most powerful dialogue line 3 in pure $shortFilmLanguage"
  ],
  "directorNotes": "Tips for shooting and acting in $shortFilmLanguage",
  "musicMood": "What kind of background score in $shortFilmLanguage",
  "captionIdea": "Instagram caption in $shortFilmLanguage",
  "hashtags": ["#tag1", "#tag2", "#tag3", "#tag4", "#tag5"]
}

FINAL REMINDER: Every value in this JSON must be written in $shortFilmLanguage language. The AI must understand and write fluently in $shortFilmLanguage.''';

      final response = await _aiService.generateText(
        prompt: prompt,
        maxTokens: 2000, // Increased for more content
        temperature: 0.9, // Increased for more creativity
      );

      if (response.isSuccess && response.data != null) {
        final cleaned = _cleanJsonResponse(response.data!);
        final film = jsonDecode(cleaned);
        setState(() {
          generatedShortFilm = film;
          _isLoading = false;
        });
        _showSnackBar('✓ $shortFilmLanguage script created!', Colors.green);
      } else {
        setState(() => _isLoading = false);
        _showSnackBar('✗ Error: ${response.error}', Colors.red);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('✗ Error: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F0F0F),
        title: const Text(
          'Content Ai Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Generating content...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(color: Color(0xFFE1306C)),
                ],
              ),
            )
          : IndexedStack(
              index: _currentTab,
              children: [
                _buildOverviewTab(),
                _buildPlannerTab(),
                _buildContentTab(),
                _buildTrackingTab(),
                _buildShortFilmTab(),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (i) => setState(() => _currentTab = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1F1F1F),
        selectedItemColor: const Color(0xFFE1306C),
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Overview'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Planner'),
          BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome), label: 'Content'),
          BottomNavigationBarItem(
              icon: Icon(Icons.show_chart), label: 'Tracking'),
          BottomNavigationBarItem(
              icon: Icon(Icons.movie_creation), label: 'Short Film'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAccountSetup(),
          const SizedBox(height: 20),
          _buildAccountCard(),
          const SizedBox(height: 20),
          _buildStatsRow(),
          const SizedBox(height: 20),
          _buildGrowthMetrics(),
          const SizedBox(height: 20),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildShortFilmTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('🎬 Short Film Script Generator'),
          const SizedBox(height: 8),
          Text(
            'Create dialogue-rich stories with powerful messages',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),

          // Genre Selection
          _buildDropdownField(
            'Story Type',
            filmGenres,
            shortFilmGenre,
            (v) => setState(() => shortFilmGenre = v),
          ),
          const SizedBox(height: 12),

          // Duration and Language Row
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  'Duration',
                  filmDurations.map((d) => '${d}sec').toList(),
                  '${shortFilmDuration}sec',
                  (v) => setState(() =>
                      shortFilmDuration = int.parse(v.replaceAll('sec', ''))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  'Characters',
                  characterCounts,
                  shortFilmCharacters,
                  (v) => setState(() => shortFilmCharacters = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Language Selection
          _buildDropdownField(
            'Script Language (All dialogues will be in this language)',
            [
              'English',
              'Malayalam',
              'Hindi',
              'Tamil',
              'Telugu',
              'Kannada',
              'Bengali',
              'Marathi',
              'Gujarati',
              'Punjabi',
              'Urdu',
              'Spanish',
              'French',
              'German',
              'Arabic'
            ],
            shortFilmLanguage,
            (v) => setState(() => shortFilmLanguage = v),
          ),
          const SizedBox(height: 12),

          // Message/Theme Input
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Story Message/Theme',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB0BEC5),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                style: const TextStyle(color: Colors.white, fontSize: 13),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Example:\n"A father realizes the importance of spending time with his daughter before it\'s too late"\n\n"Two friends discover true friendship during a crisis"',
                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFF2a2a2a),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF9C27B0), width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: (v) => shortFilmMessage = v,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Generate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateShortFilm,
              icon: const Icon(Icons.auto_awesome, size: 20),
              label: const Text(
                'Generate Complete Script with Dialogues',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey[700]!,
              ),
            ),
          ),

          if (generatedShortFilm != null) ...[
            const SizedBox(height: 24),
            _buildShortFilmPreview(generatedShortFilm!),
          ],
        ],
      ),
    );
  }

  Widget _buildShortFilmPreview(Map<String, dynamic> film) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF9C27B0), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎬 Your Script is Ready!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9C27B0),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      film['title'] ?? 'Untitled',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _copyToClipboard(jsonEncode(film)),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.copy,
                      color: Color(0xFF9C27B0), size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Core Message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.message, color: Color(0xFF9C27B0), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Story Message',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9C27B0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  film['coreMessage'] ?? film['logline'] ?? 'N/A',
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Characters
          if (film['characters'] != null) ...[
            const Text(
              '👥 Characters',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            ...(film['characters'] as List).map((c) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a2a2a),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            c['name']
                                    ?.toString()
                                    .substring(0, 1)
                                    .toUpperCase() ??
                                '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c['name'] ?? 'Character',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${c['age'] ?? ''} • ${c['role'] ?? ''}',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[500]),
                            ),
                            if (c['personality'] != null)
                              Text(
                                c['personality'],
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[400]),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
          ],

          // Complete Script with Dialogues
          if (film['completeScript'] != null) ...[
            const Text(
              '📝 Complete Script with Dialogues',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ...(film['completeScript'] as List).map((scene) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a2a2a),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFF9C27B0).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Scene Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9C27B0).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Scene ${scene['scene']}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9C27B0),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              scene['duration'] ?? '',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Location & Time
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 6),
                          Text(
                            '${scene['location']} • ${scene['timeOfDay']}',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Visual Description
                      if (scene['visualDescription'] != null) ...[
                        Text(
                          scene['visualDescription'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[300],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Dialogues - THE MAIN FOCUS
                      if (scene['dialogues'] != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F1F1F),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.record_voice_over,
                                      size: 14, color: Color(0xFF9C27B0)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Dialogues',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF9C27B0),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...(scene['dialogues'] as List).map((d) =>
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF9C27B0)
                                                    .withValues(alpha: 0.3),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                d['character']
                                                        ?.toString()
                                                        .toUpperCase() ??
                                                    '',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (d['emotion'] != null)
                                              Text(
                                                '(${d['emotion']})',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey[500],
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '"${d['dialogue']}"',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                            height: 1.4,
                                          ),
                                        ),
                                        if (d['action'] != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            '[${d['action']}]',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],

                      // Camera & Audio
                      const SizedBox(height: 10),
                      if (scene['cameraDirection'] != null)
                        Row(
                          children: [
                            Icon(Icons.videocam,
                                size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Text(
                              scene['cameraDirection'],
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      if (scene['audioCue'] != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.music_note,
                                size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Text(
                              scene['audioCue'],
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                )),
            const SizedBox(height: 16),
          ],

          // Key Dialogues Highlight
          if (film['keyDialogues'] != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF9C27B0).withValues(alpha: 0.2),
                    const Color(0xFF9C27B0).withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.star, color: Color(0xFF9C27B0), size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Most Powerful Dialogues',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...(film['keyDialogues'] as List).map((dialogue) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💬 ', style: TextStyle(fontSize: 14)),
                            Expanded(
                              child: Text(
                                dialogue.toString(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Story Breakdown
          if (film['storyBreakdown'] != null) ...[
            const Text(
              '📖 Story Structure',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            _buildStorySection('Opening', film['storyBreakdown']['opening']),
            _buildStorySection('Conflict', film['storyBreakdown']['conflict']),
            _buildStorySection('Climax', film['storyBreakdown']['climax']),
            _buildStorySection(
                'Resolution', film['storyBreakdown']['resolution']),
            const SizedBox(height: 16),
          ],

          // Director Notes
          if (film['directorNotes'] != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2a2a2a),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.directions,
                          color: Color(0xFF9C27B0), size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Director Notes',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    film['directorNotes'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Caption & Hashtags
          if (film['captionIdea'] != null)
            _buildContentField('📱 Caption', film['captionIdea']),
          if (film['hashtags'] != null)
            _buildContentField(
                '🏷️ Hashtags', (film['hashtags'] as List).join(' ')),
        ],
      ),
    );
  }

  Widget _buildStorySection(String title, dynamic content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9C27B0),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content?.toString() ?? 'N/A',
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSetup() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2a2a2a)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Setup',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          _buildInputField('Account Name', accountNameController,
              'Enter account name', false),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                    'Current Followers', currentFollowersController, '0', true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                    'Current Views', currentViewsController, '0', true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _updateInitialValues,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE1306C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Update Account Info',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      String hint, bool isNumeric) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB0BEC5)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
            filled: true,
            fillColor: const Color(0xFF2a2a2a),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE1306C), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE1306C), Color(0xFFFD1D1D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
                  Text(
                    accountName.isEmpty ? 'My Account' : accountName,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Instagram Growth Journey',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.verified, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('Followers', '$currentFollowers'),
              _buildStatColumn(
                  'Views', '${(currentViews / 1000).toStringAsFixed(1)}K'),
              _buildStatColumn(
                  'Posts', '${dailyMetrics.length * dailyPostTarget}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
              fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
              'Daily Posts', '$dailyPostTarget', const Color(0xFFE1306C)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Views/Day', '${dailyViewsTarget ~/ 1000}K',
              const Color(0xFFFD1D1D)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
              'Followers +', '+$dailyFollowerTarget', const Color(0xFF00D4FF)),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2a2a2a)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          dailyMetrics.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No activity recorded yet',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                )
              : Column(
                  children: dailyMetrics.take(3).map((m) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.date,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${m.posts} posts • ${m.views} views • +${m.followers} followers',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE1306C)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '✓ Complete',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFE1306C),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton('Generate Plan', Icons.trending_up,
              _generateGrowthPlan, const Color(0xFFE1306C)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton('Record Today', Icons.check_circle,
              _recordDailyMetric, const Color(0xFF00D4FF)),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlannerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('🎯 Growth Planning'),
          const SizedBox(height: 16),
          _buildDropdownField(
              'Niche', niches, planNiche, (v) => setState(() => planNiche = v)),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Plan Duration (Days)',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB0BEC5)),
              ),
              const SizedBox(height: 8),
              Slider(
                value: planDays.toDouble(),
                min: 7,
                max: 365,
                divisions: 50,
                activeColor: const Color(0xFFE1306C),
                inactiveColor: Colors.grey[800],
                label: '$planDays days',
                onChanged: (v) => setState(() => planDays = v.toInt()),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInputField(
              'Target Followers',
              TextEditingController(text: targetFollowers.toString()),
              '100000',
              true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateGrowthPlan,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Growth Plan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE1306C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                disabledBackgroundColor: Colors.grey[700]!,
              ),
            ),
          ),
          if (growthPlan != null) ...[
            const SizedBox(height: 24),
            _buildPlanCard(growthPlan!),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2a2a2a)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Growth Plan',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              GestureDetector(
                onTap: () => _copyToClipboard(jsonEncode(plan)),
                child:
                    const Icon(Icons.copy, color: Color(0xFFE1306C), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Target: ${plan['targetFollowers'] ?? 'N/A'} followers in ${plan['planDays'] ?? 'N/A'} days',
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 12),
          Text(
            'Daily Target: +${plan['dailyFollowerTarget'] ?? 'N/A'} followers/day',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE1306C)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Strategy:',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE1306C)),
          ),
          const SizedBox(height: 8),
          ...(plan['strategy'] as List? ?? []).map((s) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(top: 7),
                    decoration: const BoxDecoration(
                        color: Color(0xFFE1306C), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.toString(),
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('✨ AI Content Generator'),
          const SizedBox(height: 16),
          _buildDropdownField('Content Type', contentTypes, contentType,
              (v) => setState(() => contentType = v)),
          const SizedBox(height: 12),
          _buildDropdownField(
              'Niche', niches, planNiche, (v) => setState(() => planNiche = v)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  'Duration',
                  durations.map((d) => '${d}s').toList(),
                  '${duration}s',
                  (v) => setState(
                      () => duration = int.parse(v.replaceAll('s', ''))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  'Language',
                  [
                    'English',
                    'Malayalam',
                    'Hindi',
                    'Spanish',
                    'French',
                    'German',
                    'Tamil',
                    'Telugu',
                    'Kannada',
                    'Gujarati',
                    'Punjabi',
                    'Bengali',
                    'Marathi',
                    'Urdu',
                    'Odia',
                    'Assamese',
                    'Maithili',
                    'Bhojpuri',
                    'Konkani',
                    'Sanskrit',
                    'Rajasthani',
                    'Haryanvi',
                    'Sindhi',
                    'Dogri',
                    'Kashmiri',
                    'Manipuri',
                    'Nepali',
                    'Tulu',
                    'Santali',
                    'Meitei'
                  ],
                  language,
                  (v) => setState(() => language = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            style: const TextStyle(color: Colors.white, fontSize: 13),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Custom Prompt (Optional)',
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
              filled: true,
              fillColor: const Color(0xFF2a2a2a),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFFE1306C), width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (v) => customPrompt = v,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateContentAI,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Content',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFD1D1D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                disabledBackgroundColor: Colors.grey[700]!,
              ),
            ),
          ),
          if (generatedContent != null) ...[
            const SizedBox(height: 24),
            _buildContentPreview(generatedContent!),
          ],
        ],
      ),
    );
  }

  Widget _buildContentPreview(Map<String, dynamic> content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2a2a2a)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Generated Content',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              GestureDetector(
                onTap: () => _copyToClipboard(jsonEncode(content)),
                child:
                    const Icon(Icons.copy, color: Color(0xFFE1306C), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContentField('Title', content['title'] ?? 'N/A'),
          _buildContentField('Hook', content['hook'] ?? 'N/A'),
          _buildContentField('Main Content', content['mainContent'] ?? 'N/A'),
          _buildContentField('CTA', content['cta'] ?? 'N/A'),
          _buildContentField('Caption', content['caption'] ?? 'N/A'),
          _buildContentField(
              'Best Time to Post', content['bestTimeToPost'] ?? 'N/A'),
          if (content['hashtags'] != null)
            _buildContentField(
                'Hashtags', (content['hashtags'] as List).join(' ')),
        ],
      ),
    );
  }

  Widget _buildContentField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE1306C)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('📊 Daily Tracking'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2a2a2a)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Set Daily Targets',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                const SizedBox(height: 16),
                _buildSlider('Posts per Day', dailyPostTarget.toDouble(), 1, 10,
                    (v) => setState(() => dailyPostTarget = v.toInt())),
                _buildSlider('Views Target', dailyViewsTarget.toDouble(), 100,
                    50000, (v) => setState(() => dailyViewsTarget = v.toInt())),
                _buildSlider(
                    'Followers Target',
                    dailyFollowerTarget.toDouble(),
                    10,
                    500,
                    (v) => setState(() => dailyFollowerTarget = v.toInt())),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _recordDailyMetric,
              icon: const Icon(Icons.check_circle),
              label: const Text('Record Today\'s Metrics',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('📈 Metrics History'),
          const SizedBox(height: 12),
          dailyMetrics.isEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  alignment: Alignment.center,
                  child: Text(
                    'No metrics recorded yet\nStart tracking to see history',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: dailyMetrics.map((m) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F1F1F),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2a2a2a)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.date,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Posts: ${m.posts} | Views: ${m.views} | +${m.followers}✨',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE1306C)
                                  .withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.trending_up,
                                  color: Color(0xFFE1306C), size: 20),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max,
      Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
              Text(
                value.toStringAsFixed(0),
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE1306C)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8,
              ),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              activeColor: const Color(0xFFE1306C),
              inactiveColor: Colors.grey[800],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String value,
      Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB0BEC5)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2a2a2a),
            border: Border.all(color: Colors.grey.shade700),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              dropdownColor: const Color(0xFF1F1F1F),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item,
                            style: const TextStyle(color: Colors.white)),
                      ))
                  .toList(),
              onChanged: (v) => onChanged(v ?? value),
            ),
          ),
        ),
      ],
    );
  }
}

class DailyMetric {
  final String date;
  final int posts;
  final int views;
  final int followers;

  DailyMetric(this.date, this.posts, this.views, this.followers);
}
