import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/subscription_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:flutter_tts/flutter_tts.dart';

class _SpendTheme {
  final String name;
  final bool isDark;
  final List<Color> bgGradient;
  final Color cardColor;
  final Color accent;
  final Color secondaryAccent;
  final Color textColor;
  final Color subTextColor;

  const _SpendTheme({
    required this.name,
    required this.isDark,
    required this.bgGradient,
    required this.cardColor,
    required this.accent,
    required this.secondaryAccent,
    required this.textColor,
    required this.subTextColor,
  });

  Color get onAccentTextColor =>
      accent.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

class PocketSpendCoupleTheme {
  final String name;
  final bool isDark;
  final List<Color> bgGradient;
  final Color cardColor;
  final Color accent;
  final Color secondaryAccent;
  final Color textColor;
  final Color subTextColor;

  const PocketSpendCoupleTheme({
    required this.name,
    required this.isDark,
    required this.bgGradient,
    required this.cardColor,
    required this.accent,
    required this.secondaryAccent,
    required this.textColor,
    required this.subTextColor,
  });

  Color get onAccentTextColor =>
      accent.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  Color get surfaceAltColor => isDark ? bgGradient.first : bgGradient.last;

  Color get borderColor => accent.withValues(alpha: isDark ? 0.24 : 0.2);
}

/// 💰 Pocket Spend: Story-Style Expense Tracker (Couple Mode & Me Mode)
class PocketSpendPage extends StatefulWidget {
  final String? groupId;
  final String? groupName;
  final bool embeddedInGroup;

  static final ValueNotifier<int> coupleThemeNotifier = ValueNotifier<int>(0);
  static final Map<String, ValueNotifier<int>> _groupThemeNotifiers = {};

  static const List<PocketSpendCoupleTheme> groupThemes = [
    PocketSpendCoupleTheme(
      name: 'Midnight Classic',
      isDark: true,
      bgGradient: [Color(0xFF0B1015), Color(0xFF070B0E)],
      cardColor: Color(0xFF121B22),
      accent: Color(0xFFFFD600),
      secondaryAccent: Color(0xFF38BDF8),
      textColor: Colors.white,
      subTextColor: Colors.white70,
    ),
    PocketSpendCoupleTheme(
      name: 'Ocean Sky',
      isDark: true,
      bgGradient: [Color(0xFF082032), Color(0xFF0F172A)],
      cardColor: Color(0xFF132A40),
      accent: Color(0xFF38BDF8),
      secondaryAccent: Color(0xFF22D3EE),
      textColor: Colors.white,
      subTextColor: Color(0xFFBAE6FD),
    ),
    PocketSpendCoupleTheme(
      name: 'Emerald Forest',
      isDark: true,
      bgGradient: [Color(0xFF06211A), Color(0xFF0A1916)],
      cardColor: Color(0xFF0E2B22),
      accent: Color(0xFF34D399),
      secondaryAccent: Color(0xFF10B981),
      textColor: Colors.white,
      subTextColor: Color(0xFFA7F3D0),
    ),
    PocketSpendCoupleTheme(
      name: 'Cosmic Violet',
      isDark: true,
      bgGradient: [Color(0xFF130B29), Color(0xFF231347)],
      cardColor: Color(0xFF1E133D),
      accent: Color(0xFFA855F7),
      secondaryAccent: Color(0xFF22D3EE),
      textColor: Colors.white,
      subTextColor: Color(0xFFE9D5FF),
    ),
    PocketSpendCoupleTheme(
      name: 'Blush Light',
      isDark: false,
      bgGradient: [Color(0xFFFFF1F5), Color(0xFFFCE7F3)],
      cardColor: Colors.white,
      accent: Color(0xFFE11D48),
      secondaryAccent: Color(0xFFF43F5E),
      textColor: Color(0xFF4C0519),
      subTextColor: Color(0xFF9F1239),
    ),
    PocketSpendCoupleTheme(
      name: 'Daylight Mint',
      isDark: false,
      bgGradient: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
      cardColor: Colors.white,
      accent: Color(0xFF059669),
      secondaryAccent: Color(0xFF10B981),
      textColor: Color(0xFF064E3B),
      subTextColor: Color(0xFF047857),
    ),
  ];

  static ValueNotifier<int> getGroupThemeNotifier(String groupId,
      {int defaultIndex = 0}) {
    final existing = _groupThemeNotifiers[groupId];
    if (existing != null) return existing;
    final notifier = ValueNotifier<int>(defaultIndex);
    _groupThemeNotifiers[groupId] = notifier;
    SharedPreferences.getInstance().then((prefs) {
      final saved = prefs.getInt('group_theme_idx_$groupId');
      if (saved != null && saved >= 0) {
        notifier.value = saved % groupThemes.length;
      }
    });
    return notifier;
  }

  static Future<void> setGroupTheme(String groupId, int idx) async {
    final safeIdx = idx % groupThemes.length;
    getGroupThemeNotifier(groupId).value = safeIdx;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('group_theme_idx_$groupId', safeIdx);
  }

  static PocketSpendCoupleTheme getGroupTheme(int idx) {
    return groupThemes[idx % groupThemes.length];
  }

  static List<PocketSpendCoupleTheme> get allCoupleThemes =>
      List.generate(_PocketSpendPageState._coupleThemes.length, getCoupleTheme);

  static Future<void> setCoupleTheme(int idx) async {
    final safeIdx = idx % _PocketSpendPageState._coupleThemes.length;
    coupleThemeNotifier.value = safeIdx;
    _PocketSpendPageState._cachedCoupleThemeIdx = safeIdx;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pocket_spend_couple_theme_idx', safeIdx);
  }

  static PocketSpendCoupleTheme getCoupleTheme(int idx) {
    final themes = _PocketSpendPageState._coupleThemes;
    final t = themes[idx % themes.length];
    return PocketSpendCoupleTheme(
      name: t.name,
      isDark: t.isDark,
      bgGradient: t.bgGradient,
      cardColor: t.cardColor,
      accent: t.accent,
      secondaryAccent: t.secondaryAccent,
      textColor: t.textColor,
      subTextColor: t.subTextColor,
    );
  }

  static List<Color> getCoupleColors(int idx) {
    final t = getCoupleTheme(idx);
    return [t.bgGradient.first, t.cardColor, t.accent];
  }

  const PocketSpendPage({
    super.key,
    this.groupId,
    this.groupName,
    this.embeddedInGroup = false,
  });

  @override
  State<PocketSpendPage> createState() => _PocketSpendPageState();
}

class _PocketSpendPageState extends State<PocketSpendPage> {
  static const int kFreeEntryLimit = 5;

  final _supabase = Supabase.instance.client;

  static int _cachedMeThemeIdx = 0;
  static int _cachedCoupleThemeIdx = 0;

  int _tabIndex = 0; // 0: Home, 1: Budget, 2: History, 3: Tasks
  bool _isCoupleMode = true; // Couple Mode first, Me Mode second
  bool _isVip = false;
  int _meThemeIdx = _cachedMeThemeIdx;
  int _coupleThemeIdx = _cachedCoupleThemeIdx;
  String _currencySymbol = '₹';
  final TextEditingController _quickAddCtrl = TextEditingController();
  List<Map<String, dynamic>> _customCategories = [];

  static const List<Map<String, String>> _currencyCatalog = [
    {'symbol': '₹', 'code': 'INR', 'name': 'Indian Rupee'},
    {'symbol': r'$', 'code': 'USD', 'name': 'US Dollar'},
    {'symbol': '€', 'code': 'EUR', 'name': 'Euro'},
    {'symbol': '£', 'code': 'GBP', 'name': 'British Pound'},
    {'symbol': 'د.إ', 'code': 'AED', 'name': 'UAE Dirham'},
    {'symbol': '﷼', 'code': 'SAR', 'name': 'Saudi Riyal'},
    {'symbol': 'S\$', 'code': 'SGD', 'name': 'Singapore Dollar'},
    {'symbol': 'RM', 'code': 'MYR', 'name': 'Malaysian Ringgit'},
    {'symbol': 'A\$', 'code': 'AUD', 'name': 'Australian Dollar'},
    {'symbol': 'C\$', 'code': 'CAD', 'name': 'Canadian Dollar'},
    {'symbol': '¥', 'code': 'JPY', 'name': 'Japanese Yen'},
  ];

  double _monthlyBudget = 15000.0;
  double _partnerBudget = 15000.0;
  double _mySalary = 0.0;
  double _partnerSalary = 0.0;
  String _historyFilter = 'All';
  String _historyQuery = '';

  List<Map<String, dynamic>> _entries = [];
  List<Map<String, dynamic>> _billTasks = [];
  List<Map<String, dynamic>> _goals = [];
  List<Map<String, dynamic>> _milestones = [];
  List<Map<String, dynamic>> _bucketList = [];
  List<Map<String, dynamic>> _coupleMessages = [];
  String _myMood = 'Missing you ❤️';
  String _partnerMood = '';
  final TextEditingController _coupleChatCtrl = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  int _myStage = 1;
  int _partnerStage = 1;
  List<Map<String, dynamic>> _whispers = [];

  // Couple Partner State
  String _myName = 'You';
  String? _myAvatar;
  String? _partnerId;
  String? _partnerName;
  String? _partnerAvatar;
  String? _coupleGroupId;

  static const List<_SpendTheme> _meThemes = [
    _SpendTheme(
      name: 'Obsidian Gold',
      isDark: true,
      bgGradient: [Color(0xFF0A0E17), Color(0xFF131B2E)],
      cardColor: Color(0xFF171F33),
      accent: Color(0xFFFFD700),
      secondaryAccent: Color(0xFF38BDF8),
      textColor: Colors.white,
      subTextColor: Colors.white60,
    ),
    _SpendTheme(
      name: 'Clean Light',
      isDark: false,
      bgGradient: [Color(0xFFF8FAFC), Color(0xFFEEF2FF)],
      cardColor: Colors.white,
      accent: Color(0xFF0F172A),
      secondaryAccent: Color(0xFF10B981),
      textColor: Color(0xFF0F172A),
      subTextColor: Color(0xFF64748B),
    ),
    _SpendTheme(
      name: 'Emerald Mint',
      isDark: true,
      bgGradient: [Color(0xFF042F2E), Color(0xFF064E3B)],
      cardColor: Color(0xFF0B3B36),
      accent: Color(0xFF34D399),
      secondaryAccent: Color(0xFFA7F3D0),
      textColor: Colors.white,
      subTextColor: Colors.white70,
    ),
    _SpendTheme(
      name: 'Cosmic Violet',
      isDark: true,
      bgGradient: [Color(0xFF130B29), Color(0xFF231347)],
      cardColor: Color(0xFF1E133D),
      accent: Color(0xFFA855F7),
      secondaryAccent: Color(0xFF22D3EE),
      textColor: Colors.white,
      subTextColor: Colors.white70,
    ),
  ];

  static const List<_SpendTheme> _coupleThemes = [
    _SpendTheme(
      name: 'Romantic Rose',
      isDark: true,
      bgGradient: [Color(0xFF240919), Color(0xFF450A2A)],
      cardColor: Color(0xFF350D24),
      accent: Color(0xFFFF4D8D),
      secondaryAccent: Color(0xFFFFB3C6),
      textColor: Colors.white,
      subTextColor: Color(0xFFFBCFE8),
    ),
    _SpendTheme(
      name: 'Blush Light',
      isDark: false,
      bgGradient: [Color(0xFFFFF1F5), Color(0xFFFCE7F3)],
      cardColor: Colors.white,
      accent: Color(0xFFE11D48),
      secondaryAccent: Color(0xFFF43F5E),
      textColor: Color(0xFF4C0519),
      subTextColor: Color(0xFF9F1239),
    ),
    _SpendTheme(
      name: 'Midnight Wine',
      isDark: true,
      bgGradient: [Color(0xFF1A0712), Color(0xFF3B0722)],
      cardColor: Color(0xFF2D0A1B),
      accent: Color(0xFFFBBF24),
      secondaryAccent: Color(0xFFFB7185),
      textColor: Colors.white,
      subTextColor: Colors.white70,
    ),
    _SpendTheme(
      name: 'Starry Lavender',
      isDark: true,
      bgGradient: [Color(0xFF1B1035), Color(0xFF3B154A)],
      cardColor: Color(0xFF291440),
      accent: Color(0xFFF472B6),
      secondaryAccent: Color(0xFFC084FC),
      textColor: Colors.white,
      subTextColor: Colors.white70,
    ),
  ];

  static const List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': '🍔', 'color': 0xFFF59E0B},
    {'name': 'Travel', 'icon': '🚕', 'color': 0xFF38BDF8},
    {'name': 'Bills', 'icon': '⚡', 'color': 0xFFEF4444},
    {'name': 'Shopping', 'icon': '🛍️', 'color': 0xFFEC4899},
    {'name': 'Groceries', 'icon': '🛒', 'color': 0xFF22C55E},
    {'name': 'Dates', 'icon': '💐', 'color': 0xFFF43F5E},
    {'name': 'Rent', 'icon': '🏠', 'color': 0xFF6366F1},
    {'name': 'Health', 'icon': '💊', 'color': 0xFF10B981},
    {'name': 'Other', 'icon': '📦', 'color': 0xFF8B5CF6},
  ];

  _SpendTheme get _theme => _isCoupleMode
      ? _coupleThemes[_coupleThemeIdx % _coupleThemes.length]
      : _meThemes[_meThemeIdx % _meThemes.length];

  String get _uid => _supabase.auth.currentUser?.id ?? 'guest';

  String get _storageScope =>
      widget.groupId != null && widget.groupId!.isNotEmpty
          ? 'group_${widget.groupId}'
          : (_isCoupleMode ? 'couple_$_uid' : 'me_$_uid');

  List<Map<String, dynamic>> get _allCategories => [
        ..._categories,
        ..._customCategories,
      ];

  @override
  void dispose() {
    _quickAddCtrl.dispose();
    _coupleChatCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    final prefs = await SharedPreferences.getInstance();
    final meIdx = prefs.getInt('pocket_spend_me_theme') ?? 0;
    final coupleIdx = prefs.getInt('pocket_spend_couple_theme') ?? 0;
    final curr = prefs.getString('pocket_spend_currency') ?? '₹';
    final customCatsRaw = prefs.getString('pocket_spend_custom_cats_$_uid');
    List<Map<String, dynamic>> customCats = [];
    if (customCatsRaw != null && customCatsRaw.isNotEmpty) {
      try {
        customCats = List<Map<String, dynamic>>.from(jsonDecode(customCatsRaw));
      } catch (_) {}
    }

    _cachedMeThemeIdx = meIdx;
    _cachedCoupleThemeIdx = coupleIdx;
    PocketSpendPage.coupleThemeNotifier.value = coupleIdx;
    if (mounted) {
      setState(() {
        _meThemeIdx = meIdx;
        _coupleThemeIdx = coupleIdx;
        _currencySymbol = curr;
        _customCategories = customCats;
      });
    }

    final vip = await PocketAdMobService.instance.isUserVip();
    if (mounted && vip != _isVip) {
      setState(() => _isVip = vip);
    }

    await _loadMyProfileAndCoupleState();
    await _loadScopedData();
  }

  Future<void> _loadMyProfileAndCoupleState() async {
    final uid = _supabase.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();

    _partnerId = prefs.getString('pocket_spend_partner_id_$_uid');
    _partnerName = prefs.getString('pocket_spend_partner_name_$_uid');
    _partnerAvatar = prefs.getString('pocket_spend_partner_avatar_$_uid');
    _coupleGroupId = prefs.getString('pocket_spend_couple_group_$_uid');

    if (uid != null) {
      try {
        final prof = await _supabase
            .from('profile')
            .select('name, profile_image_url, learning_stage, stage')
            .eq('user_id', uid)
            .maybeSingle();
        if (prof != null) {
          _myName = prof['name']?.toString() ?? 'You';
          _myAvatar = prof['profile_image_url']?.toString();
          _myStage = ((prof['learning_stage'] ?? prof['stage']) as num?)?.toInt() ?? 1;
        }

        // Sync couple_spend_accepted / couple_spend_removed notifications from Supabase
        final notifs = await _supabase
            .from('notifications')
            .select('type, sender_id, source_id, message, created_at')
            .eq('user_id', uid)
            .inFilter('type', ['couple_spend_accepted', 'couple_spend_removed'])
            .order('created_at', ascending: false)
            .limit(5);

        for (final n in (notifs as List)) {
          final type = n['type']?.toString() ?? '';
          final peerId =
              (n['sender_id'] ?? n['source_id'])?.toString() ?? '';
          if (type == 'couple_spend_removed') {
            if (_partnerId == peerId) {
              _partnerId = null;
              _partnerName = null;
              _partnerAvatar = null;
              _coupleGroupId = null;
              await prefs.remove('pocket_spend_partner_id_$_uid');
              await prefs.remove('pocket_spend_partner_name_$_uid');
              await prefs.remove('pocket_spend_partner_avatar_$_uid');
              await prefs.remove('pocket_spend_couple_group_$_uid');
            }
            break;
          } else if (type == 'couple_spend_accepted' && peerId.isNotEmpty) {
            _partnerId = peerId;
            try {
              final partnerProf = await _supabase
                  .from('profile')
                  .select('display_name, name, profile_image_url')
                  .eq('user_id', peerId)
                  .maybeSingle();
              if (partnerProf != null) {
                final dn =
                    partnerProf['display_name'] ?? partnerProf['name'];
                if (dn != null && dn.toString().trim().isNotEmpty) {
                  _partnerName = dn.toString().trim();
                }
                _partnerAvatar =
                    partnerProf['profile_image_url']?.toString();
              }
            } catch (_) {}
            _partnerName ??= 'Partner';

            try {
              final myGroups = await _supabase
                  .from('group_members')
                  .select('group_id, groups(id, name)')
                  .eq('user_id', uid)
                  .eq('is_active', true);
              for (final mg in (myGroups as List)) {
                final g = mg['groups'];
                final gName = (g is Map ? g['name']?.toString() : null) ?? '';
                final gId = mg['group_id']?.toString() ?? '';
                if (gId.isNotEmpty && gName.startsWith('💑 ')) {
                  final peerMembership = await _supabase
                      .from('group_members')
                      .select('user_id')
                      .eq('group_id', gId)
                      .eq('user_id', peerId)
                      .eq('is_active', true)
                      .maybeSingle();
                  if (peerMembership != null) {
                    _coupleGroupId = gId;
                    break;
                  }
                }
              }
            } catch (_) {}

            await prefs.setString('pocket_spend_partner_id_$_uid', _partnerId!);
            await prefs.setString(
                'pocket_spend_partner_name_$_uid', _partnerName ?? 'Partner');
            if (_partnerAvatar != null && _partnerAvatar!.isNotEmpty) {
              await prefs.setString(
                  'pocket_spend_partner_avatar_$_uid', _partnerAvatar!);
            }
            if (_coupleGroupId != null && _coupleGroupId!.isNotEmpty) {
              await prefs.setString(
                  'pocket_spend_couple_group_$_uid', _coupleGroupId!);
            }
            break;
          }
        }
      } catch (_) {}
    }

    if (mounted) setState(() {});
  }

  Future<void> _loadScopedData() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesRaw = prefs.getString('pocket_spend_entries_$_storageScope');
    final tasksRaw = prefs.getString('pocket_spend_tasks_$_storageScope');
    final goalsRaw = prefs.getString('pocket_spend_goals_$_storageScope');
    var budget =
        prefs.getDouble('pocket_spend_budget_$_storageScope') ?? 15000.0;
    final pBudget =
        prefs.getDouble('pocket_spend_partner_budget_$_storageScope') ??
            15000.0;
    final mySal =
        prefs.getDouble('pocket_spend_my_salary_$_storageScope') ?? 0.0;
    final pSal =
        prefs.getDouble('pocket_spend_partner_salary_$_storageScope') ?? 0.0;

    List<Map<String, dynamic>> loadedEntries = [];
    if (entriesRaw != null && entriesRaw.isNotEmpty) {
      try {
        loadedEntries = List<Map<String, dynamic>>.from(jsonDecode(entriesRaw));
      } catch (_) {}
    }

    List<Map<String, dynamic>> loadedTasks = [];
    if (tasksRaw != null && tasksRaw.isNotEmpty) {
      try {
        loadedTasks = List<Map<String, dynamic>>.from(jsonDecode(tasksRaw));
      } catch (_) {}
    }

    List<Map<String, dynamic>> loadedGoals = [];
    if (goalsRaw != null && goalsRaw.isNotEmpty) {
      try {
        loadedGoals = List<Map<String, dynamic>>.from(jsonDecode(goalsRaw));
      } catch (_) {}
    }

    // Real-time cloud replay for Couple Mode via Supabase group_activities
    if (_isCoupleMode && _coupleGroupId != null && _coupleGroupId!.isNotEmpty) {
      try {
        final cloudRows = await _supabase
            .from('group_activities')
            .select('title, data, created_at')
            .eq('group_id', _coupleGroupId!)
            .eq('activity_type', 'pocket_spend_sync')
            .order('created_at', ascending: true);

        for (final row in (cloudRows as List)) {
          final action = row['title']?.toString() ?? '';
          final data = row['data'] is Map
              ? Map<String, dynamic>.from(row['data'])
              : <String, dynamic>{};
          if (action == 'add_entry' && data['id'] != null) {
            loadedEntries.removeWhere((e) => e['id'] == data['id']);
            loadedEntries.insert(0, data);
          } else if (action == 'delete_entry' && data['id'] != null) {
            loadedEntries.removeWhere((e) => e['id'] == data['id']);
          } else if (action == 'set_budget' && data['budget'] != null) {
            budget = (data['budget'] as num).toDouble();
          } else if (action == 'upsert_task' && data['id'] != null) {
            final idx = loadedTasks.indexWhere((t) => t['id'] == data['id']);
            if (idx >= 0) {
              loadedTasks[idx] = data;
            } else {
              loadedTasks.add(data);
            }
          } else if (action == 'upsert_goal' && data['id'] != null) {
            final idx = loadedGoals.indexWhere((g) => g['id'] == data['id']);
            if (idx >= 0) {
              loadedGoals[idx] = data;
            } else {
              loadedGoals.add(data);
            }
          } else if (action == 'upsert_milestone' && data['id'] != null) {
            _milestones.removeWhere((m) => m['id'] == data['id']);
            _milestones.add(data);
          } else if (action == 'upsert_bucket' && data['id'] != null) {
            final idx = _bucketList.indexWhere((b) => b['id'] == data['id']);
            if (idx >= 0) {
              _bucketList[idx] = data;
            } else {
              _bucketList.add(data);
            }
          } else if (action == 'set_mood') {
            if (data['uid'] == _uid) {
              _myMood = data['mood']?.toString() ?? _myMood;
            } else {
              _partnerMood = data['mood']?.toString() ?? _partnerMood;
            }
          } else if (action == 'add_whisper' && data['id'] != null) {
            _whispers.removeWhere((w) => w['id'] == data['id']);
            _whispers.insert(0, data);
          } else if (action == 'mark_whisper_seen' && data['id'] != null) {
            _whispers.removeWhere((w) => w['id'] == data['id']);
          }
        }
      } catch (_) {}

      try {
        final chatRows = await _supabase
            .from('group_messages')
            .select('id, sender_id, message_text, created_at')
            .eq('group_id', _coupleGroupId!)
            .order('created_at', ascending: false)
            .limit(30);
        _coupleMessages = List<Map<String, dynamic>>.from(chatRows as List);
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _entries = loadedEntries;
        _billTasks = loadedTasks;
        _goals = loadedGoals;
        _monthlyBudget = budget;
        _partnerBudget = pBudget;
        _mySalary = mySal;
        _partnerSalary = pSal;
      });
    }
  }

  Future<void> _syncCoupleEvent(String action, Map<String, dynamic> payload) async {
    if (!_isCoupleMode || _coupleGroupId == null || _coupleGroupId!.isEmpty) {
      return;
    }
    try {
      await _supabase.from('group_activities').insert({
        'group_id': _coupleGroupId,
        'activity_type': 'pocket_spend_sync',
        'title': action,
        'data': payload,
      });
    } catch (_) {}
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'pocket_spend_entries_$_storageScope',
      jsonEncode(_entries),
    );
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'pocket_spend_tasks_$_storageScope',
      jsonEncode(_billTasks),
    );
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'pocket_spend_goals_$_storageScope',
      jsonEncode(_goals),
    );
  }

  Future<void> _saveBudget(double val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('pocket_spend_budget_$_storageScope', val);
    await _syncCoupleEvent('set_budget', {'budget': val});
  }

  Future<void> _saveSalaryAndPartnerBudget({
    double? mySalary,
    double? partnerSalary,
    double? partnerBudget,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (mySalary != null) {
      await prefs.setDouble('pocket_spend_my_salary_$_storageScope', mySalary);
    }
    if (partnerSalary != null) {
      await prefs.setDouble(
          'pocket_spend_partner_salary_$_storageScope', partnerSalary);
    }
    if (partnerBudget != null) {
      await prefs.setDouble(
          'pocket_spend_partner_budget_$_storageScope', partnerBudget);
    }
  }

  Future<void> _showCurrencyPickerSheet() async {
    final t = _theme;
    await showModalBottomSheet(
      context: context,
      backgroundColor: t.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.4,
          expand: false,
          builder: (ctx, scrollCtrl) => Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 14),
                decoration: BoxDecoration(
                  color: t.subTextColor.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Icon(Icons.currency_exchange_rounded,
                        color: t.accent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Select Currency',
                      style: GoogleFonts.outfit(
                        color: t.textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  itemCount: _currencyCatalog.length,
                  itemBuilder: (_, idx) {
                    final c = _currencyCatalog[idx];
                    final sym = c['symbol']!;
                    final isSelected = _currencySymbol == sym;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? t.accent
                            : t.accent.withValues(alpha: 0.14),
                        child: Text(
                          sym,
                          style: TextStyle(
                            color: isSelected ? t.onAccentTextColor : t.accent,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      title: Text(
                        '${c['name']} (${c['code']})',
                        style: GoogleFonts.outfit(
                          color: t.textColor,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle_rounded, color: t.accent)
                          : null,
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('pocket_spend_currency', sym);
                        if (mounted) setState(() => _currencySymbol = sym);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
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

  String _inferCategory(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('tea') ||
        lower.contains('coffee') ||
        lower.contains('lunch') ||
        lower.contains('dinner') ||
        lower.contains('food') ||
        lower.contains('biryani') ||
        lower.contains('snack')) return 'Food';
    if (lower.contains('auto') ||
        lower.contains('uber') ||
        lower.contains('bus') ||
        lower.contains('fuel') ||
        lower.contains('petrol') ||
        lower.contains('train') ||
        lower.contains('travel')) return 'Travel';
    if (lower.contains('bill') ||
        lower.contains('electric') ||
        lower.contains('wifi') ||
        lower.contains('recharge') ||
        lower.contains('water')) return 'Bills';
    if (lower.contains('grocer') ||
        lower.contains('milk') ||
        lower.contains('veg') ||
        lower.contains('fruit')) return 'Groceries';
    if (lower.contains('med') ||
        lower.contains('doctor') ||
        lower.contains('hospital') ||
        lower.contains('pharma')) return 'Health';
    if (lower.contains('rent') || lower.contains('room')) return 'Rent';
    if (lower.contains('date') || lower.contains('gift') || lower.contains('movie')) {
      return 'Dates';
    }
    if (lower.contains('shop') || lower.contains('dress') || lower.contains('shoe')) {
      return 'Shopping';
    }
    return 'Other';
  }

  Future<void> _handleQuickSmartAdd() async {
    final raw = _quickAddCtrl.text.trim();
    if (raw.isEmpty) return;
    if (!_isVip && _entries.length >= kFreeEntryLimit) {
      _showVipUpgradeDialog();
      return;
    }
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(raw);
    if (match == null) return;
    final amt = double.tryParse(match.group(1)!) ?? 0;
    if (amt <= 0) return;

    final note = raw.replaceFirst(match.group(0)!, '').trim();
    final cat = _inferCategory(note.isEmpty ? raw : note);
    final entry = {
      'id': 'exp_${DateTime.now().millisecondsSinceEpoch}',
      'title': note.isEmpty ? cat : note,
      'amount': amt,
      'category': cat,
      'payment_mode': 'UPI',
      'paid_by_uid': _uid,
      'paid_by_name': _myName,
      'is_income': false,
      'added_by': _myName,
      'created_at': DateTime.now().toIso8601String(),
    };
    _quickAddCtrl.clear();
    setState(() => _entries.insert(0, entry));
    await _saveEntries();
    await _syncCoupleEvent('add_entry', entry);
  }

  Future<void> _cycleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_isCoupleMode) {
        _coupleThemeIdx = (_coupleThemeIdx + 1) % _coupleThemes.length;
        _cachedCoupleThemeIdx = _coupleThemeIdx;
        PocketSpendPage.coupleThemeNotifier.value = _coupleThemeIdx;
        prefs.setInt('pocket_spend_couple_theme', _coupleThemeIdx);
      } else {
        _meThemeIdx = (_meThemeIdx + 1) % _meThemes.length;
        _cachedMeThemeIdx = _meThemeIdx;
        prefs.setInt('pocket_spend_me_theme', _meThemeIdx);
      }
    });
  }

  void _showVipUpgradeDialog() {
    final t = _theme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Text('👑', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Unlock Unlimited Poket Spend',
                style: GoogleFonts.outfit(
                  color: t.textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'You have used all $kFreeEntryLimit free entries. Upgrade to Poket VIP (₹99/mo) for unlimited expenses, budgets, and insights!',
          style: GoogleFonts.plusJakartaSans(
            color: t.subTextColor,
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Later', style: GoogleFonts.outfit(color: t.subTextColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: t.accent,
              foregroundColor: t.isDark ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionPage()),
              );
              final vip =
                  await PocketAdMobService.instance.isUserVip(forceRefresh: true);
              if (mounted) setState(() => _isVip = vip);
            },
            child: Text(
              'Get Poket VIP',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  void _openInvitePartnerSheet() {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;
    final searchCtrl = TextEditingController();
    List<Map<String, dynamic>> results = [];
    bool searching = false;
    final t = _theme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: t.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '💑 Invite Couple Partner',
                style: GoogleFonts.outfit(
                  color: t.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Search your partner by name to send a Couple Mode invite to their Requests.',
                style: GoogleFonts.plusJakartaSans(
                  color: t.subTextColor,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: searchCtrl,
                style: TextStyle(color: t.textColor),
                decoration: InputDecoration(
                  hintText: 'Search partner name...',
                  hintStyle: TextStyle(color: t.subTextColor),
                  prefixIcon: Icon(Icons.search_rounded, color: t.accent),
                  filled: true,
                  fillColor: t.isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (q) async {
                  if (q.trim().length < 2) return;
                  setSheet(() => searching = true);
                  try {
                    final res = await _supabase
                        .from('profile')
                        .select('user_id, name, profile_image_url')
                        .ilike('name', '%${q.trim()}%')
                        .neq('user_id', uid)
                        .limit(8);
                    setSheet(() {
                      results = List<Map<String, dynamic>>.from(res as List);
                      searching = false;
                    });
                  } catch (_) {
                    setSheet(() => searching = false);
                  }
                },
              ),
              const SizedBox(height: 12),
              if (searching)
                const Center(child: CircularProgressIndicator())
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      final u = results[i];
                      final name = u['name']?.toString() ?? 'User';
                      final img = u['profile_image_url']?.toString();
                      final targetId = u['user_id']?.toString() ?? '';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              (img != null && img.startsWith('http'))
                                  ? NetworkImage(img)
                                  : null,
                          onBackgroundImageError:
                              (img != null && img.startsWith('http'))
                                  ? (_, __) {}
                                  : null,
                          child: (img == null || !img.startsWith('http'))
                              ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'P')
                              : null,
                        ),
                        title: Text(name,
                            style: GoogleFonts.outfit(
                                color: t.textColor, fontWeight: FontWeight.w700)),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: t.accent,
                            foregroundColor:
                                t.isDark ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            try {
                              await _supabase.from('notifications').insert({
                                'user_id': targetId,
                                'sender_id': uid,
                                'source_id': uid,
                                'type': 'couple_spend_invite',
                                'message':
                                    '$_myName invited you to Poket Couple Mode!',
                                'status': 'unread',
                              });
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('💑 Couple invite sent to $name!'),
                                    backgroundColor: t.accent,
                                  ),
                                );
                              }
                            } catch (e) {
                              debugPrint('Error sending couple invite: $e');
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to send couple invite. Please retry.'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Invite'),
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

  Future<void> _removePartner() async {
    final oldPartnerId = _partnerId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pocket_spend_partner_id_$_uid');
    await prefs.remove('pocket_spend_partner_name_$_uid');
    await prefs.remove('pocket_spend_partner_avatar_$_uid');
    await prefs.remove('pocket_spend_couple_group_$_uid');

    setState(() {
      _partnerId = null;
      _partnerName = null;
      _partnerAvatar = null;
      _coupleGroupId = null;
    });

    final uid = _supabase.auth.currentUser?.id;
    if (uid != null && oldPartnerId != null && oldPartnerId.isNotEmpty) {
      try {
        await _supabase.from('notifications').insert({
          'user_id': oldPartnerId,
          'sender_id': uid,
          'source_id': uid,
          'type': 'couple_spend_removed',
          'message': '$_myName ended the Poket Couple link.',
          'status': 'unread',
        });
      } catch (_) {}
    }
  }

  Future<void> _openCoupleSpace() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null || _partnerId == null) return;
    if (_coupleGroupId != null && _coupleGroupId!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WhatsAppGroupChat(
            groupId: _coupleGroupId!,
            groupName: '💑 $_myName & ${_partnerName ?? 'Partner'}',
          ),
        ),
      );
      return;
    }

    try {
      final groupRes = await _supabase
          .from('groups')
          .insert({
            'name': '💑 $_myName & ${_partnerName ?? 'Partner'}',
            'description': 'Private Poket Couple Space',
            'created_by': uid,
          })
          .select('id')
          .single();
      final gid = groupRes['id'].toString();
      await _supabase.from('group_members').insert([
        {'group_id': gid, 'user_id': uid, 'role': 'admin', 'is_active': true},
        {
          'group_id': gid,
          'user_id': _partnerId,
          'role': 'admin',
          'is_active': true
        },
      ]);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pocket_spend_couple_group_$_uid', gid);
      setState(() => _coupleGroupId = gid);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WhatsAppGroupChat(
              groupId: gid,
              groupName: '💑 $_myName & ${_partnerName ?? 'Partner'}',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error opening couple space: $e');
    }
  }

  void _openAddEntrySheet({bool isIncome = false}) {
    if (!_isVip && _entries.length >= kFreeEntryLimit) {
      _showVipUpgradeDialog();
      return;
    }

    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String selectedCat = _categories.first['name'] as String;
    String paymentMethod = 'UPI';
    String paidByUid = _uid;
    bool income = isIncome;
    bool showCalc = false;
    String calcExpr = '';
    final t = _theme;

    String evalCalc(String expr) {
      try {
        final clean = expr.replaceAll('×', '*').replaceAll('÷', '/').trim();
        if (clean.isEmpty) return '';
        // Simple left-to-right evaluator for +, -, *, /
        final tokens = RegExp(r'(\d+\.?\d*|[+\-*/])')
            .allMatches(clean)
            .map((m) => m.group(0)!)
            .toList();
        if (tokens.isEmpty) return '';
        double acc = double.tryParse(tokens[0]) ?? 0.0;
        for (int i = 1; i + 1 < tokens.length; i += 2) {
          final op = tokens[i];
          final rhs = double.tryParse(tokens[i + 1]) ?? 0.0;
          if (op == '+') acc += rhs;
          if (op == '-') acc -= rhs;
          if (op == '*') acc *= rhs;
          if (op == '/' && rhs != 0) acc /= rhs;
        }
        return acc == acc.roundToDouble()
            ? acc.toInt().toString()
            : acc.toStringAsFixed(2);
      } catch (_) {
        return '';
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: t.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final chipBg = t.isDark
              ? Colors.white.withValues(alpha: 0.09)
              : Colors.black.withValues(alpha: 0.06);
          final calcKeys = [
            '7', '8', '9', '÷',
            '4', '5', '6', '×',
            '1', '2', '3', '-',
            'C', '0', '.', '+',
          ];
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.88,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: t.textColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        income ? '💰 Add Income' : '💸 Add Expense',
                        style: GoogleFonts.outfit(
                          color: t.textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Calculator',
                            onPressed: () =>
                                setSheetState(() => showCalc = !showCalc),
                            icon: Icon(
                              Icons.calculate_rounded,
                              color: showCalc ? t.accent : t.subTextColor,
                            ),
                          ),
                          Switch(
                            value: income,
                            activeThumbColor: t.secondaryAccent,
                            onChanged: (v) => setSheetState(() => income = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.outfit(
                      color: t.textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Amount (₹)',
                      labelStyle: TextStyle(color: t.subTextColor, fontSize: 13),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calculate_outlined, color: t.accent),
                        onPressed: () =>
                            setSheetState(() => showCalc = !showCalc),
                      ),
                      filled: true,
                      fillColor: chipBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (showCalc) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: t.accent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  calcExpr.isEmpty ? '0' : calcExpr,
                                  style: GoogleFonts.outfit(
                                    color: t.textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  final res = evalCalc(calcExpr);
                                  if (res.isNotEmpty) {
                                    setSheetState(() {
                                      amountCtrl.text = res;
                                      calcExpr = res;
                                    });
                                  }
                                },
                                child: Text(
                                  '= Apply',
                                  style: GoogleFonts.outfit(
                                    color: t.accent,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: calcKeys.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 6,
                              crossAxisSpacing: 6,
                              childAspectRatio: 2.1,
                            ),
                            itemBuilder: (_, i) {
                              final k = calcKeys[i];
                              return InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  setSheetState(() {
                                    if (k == 'C') {
                                      calcExpr = '';
                                    } else {
                                      calcExpr += k;
                                      final res = evalCalc(calcExpr);
                                      if (res.isNotEmpty) {
                                        amountCtrl.text = res;
                                      }
                                    }
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: t.cardColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    k,
                                    style: GoogleFonts.outfit(
                                      color: t.textColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  TextField(
                    controller: titleCtrl,
                    style: TextStyle(color: t.textColor),
                    decoration: InputDecoration(
                      labelText: 'Note / Description',
                      labelStyle: TextStyle(color: t.subTextColor),
                      filled: true,
                      fillColor: chipBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Payment Mode',
                    style: GoogleFonts.outfit(
                      color: t.subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: ['UPI', 'Cash', 'Card'].map((pm) {
                      final sel = paymentMethod == pm;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildPillChip(
                          label: pm,
                          selected: sel,
                          onTap: () => setSheetState(() => paymentMethod = pm),
                        ),
                      );
                    }).toList(),
                  ),
                  if (!income) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Category',
                      style: GoogleFonts.outfit(
                        color: t.subTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((c) {
                        final name = c['name'] as String;
                        final selected = selectedCat == name;
                        return _buildPillChip(
                          label: '${c['icon']} $name',
                          selected: selected,
                          onTap: () => setSheetState(() => selectedCat = name),
                        );
                      }).toList(),
                    ),
                  ],
                  if (_isCoupleMode && _partnerId != null && !income) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Paid By',
                      style: GoogleFonts.outfit(
                        color: t.subTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        {'id': _uid, 'name': _myName},
                        {'id': _partnerId!, 'name': _partnerName ?? 'Partner'},
                      ].map((p) {
                        final sel = paidByUid == p['id'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildPillChip(
                            label: p['name']!,
                            selected: sel,
                            onTap: () =>
                                setSheetState(() => paidByUid = p['id']!),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: t.accent,
                        foregroundColor: t.isDark ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        final amt = double.tryParse(amountCtrl.text.trim()) ?? 0;
                        if (amt <= 0) return;
                        final entry = {
                          'id': 'exp_${DateTime.now().millisecondsSinceEpoch}',
                          'title': titleCtrl.text.trim().isEmpty
                              ? (income ? 'Income' : selectedCat)
                              : titleCtrl.text.trim(),
                          'amount': amt,
                          'category': income ? 'Income' : selectedCat,
                          'payment_mode': paymentMethod,
                          'paid_by_uid': paidByUid,
                          'paid_by_name': paidByUid == _uid
                              ? _myName
                              : (_partnerName ?? 'Partner'),
                          'is_income': income,
                          'added_by': _myName,
                          'created_at': DateTime.now().toIso8601String(),
                        };
                        setState(() => _entries.insert(0, entry));
                        await _saveEntries();
                        await _syncCoupleEvent('add_entry', entry);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: Text(
                        'Save Entry',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double get _totalSpent => _entries
      .where((e) => e['is_income'] != true)
      .fold(0.0, (s, e) => s + ((e['amount'] as num?)?.toDouble() ?? 0.0));

  double get _totalIncome => _entries
      .where((e) => e['is_income'] == true)
      .fold(0.0, (s, e) => s + ((e['amount'] as num?)?.toDouble() ?? 0.0));

  double get _todaySpent {
    final now = DateTime.now();
    return _entries.where((e) {
      if (e['is_income'] == true) return false;
      final dt = DateTime.tryParse(e['created_at']?.toString() ?? '');
      return dt != null &&
          dt.year == now.year &&
          dt.month == now.month &&
          dt.day == now.day;
    }).fold(0.0, (s, e) => s + ((e['amount'] as num?)?.toDouble() ?? 0.0));
  }

  @override
  Widget build(BuildContext context) {
    final t = _theme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: t.bgGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: widget.embeddedInGroup
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_rounded,
                      color: t.textColor, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Poket Spend',
                  style: GoogleFonts.outfit(
                    color: t.textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: -0.3,
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: _showCurrencyPickerSheet,
                    child: Container(
                      margin: const EdgeInsets.only(right: 4, top: 10, bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: t.cardColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: t.textColor.withValues(alpha: 0.15),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _currencySymbol,
                        style: GoogleFonts.outfit(
                          color: t.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: t.name,
                    onPressed: _cycleTheme,
                    icon: Icon(Icons.palette_rounded, color: t.accent, size: 22),
                  ),
                ],
              ),
        body: Column(
          children: [
            // Minimal Couple First / Me Second Switcher
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: t.cardColor.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: t.textColor.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildModeChip(
                        label: '💑 Couple',
                        selected: _isCoupleMode,
                        onTap: () async {
                          setState(() => _isCoupleMode = true);
                          await _loadScopedData();
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildModeChip(
                        label: '👤 Me',
                        selected: !_isCoupleMode,
                        onTap: () async {
                          setState(() {
                            _isCoupleMode = false;
                            if (_tabIndex >= 4) _tabIndex = 0;
                          });
                          await _loadScopedData();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: [
                  _buildHomeDashboard(),
                  _buildBudgetTab(),
                  _buildHistoryTab(),
                  _buildTasksTab(),
                  if (_isCoupleMode) _buildCoupleSpaceTab(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: _tabIndex == 4
            ? null
            : FloatingActionButton.extended(
                backgroundColor: t.accent,
                foregroundColor: t.isDark ? Colors.black : Colors.white,
                onPressed: () => _openAddEntrySheet(),
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  'Add',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
                ),
              ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _tabIndex,
          onTap: (i) => setState(() => _tabIndex = i),
          backgroundColor: t.cardColor,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: t.accent,
          unselectedItemColor: t.subTextColor,
          items: [
            const BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: 'Home'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.pie_chart_rounded), label: 'Budget'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded), label: 'History'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.checklist_rounded), label: 'Tasks'),
            if (_isCoupleMode)
              const BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_rounded), label: 'Couple'),
          ],
        ),
      ),
    );
  }

  Widget _buildModeChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final t = _theme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? t.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: selected
                ? (t.isDark ? Colors.black : Colors.white)
                : t.subTextColor,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  int get _relationScore =>
      (_entries.length * 10) +
      (_coupleMessages.length * 5) +
      (_goals.length * 25) +
      (_milestones.length * 20) +
      (_whispers.length * 15) +
      (_bucketList.where((b) => b['done'] == true).length * 30);

  Widget _buildAvatarOrVector(String? url, int stage) {
    if (url != null && url.startsWith('http')) {
      return ClipOval(
        child: Image.network(
          url,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => VectorAvatarWidget(
            config: VectorAvatarConfig.getEvolutionAvatarForStage(
                stage.clamp(1, 90)),
            size: 40,
            showAura: false,
          ),
        ),
      );
    }
    return ClipOval(
      child: VectorAvatarWidget(
        config: VectorAvatarConfig.getEvolutionAvatarForStage(stage.clamp(1, 90)),
        size: 40,
        showAura: false,
      ),
    );
  }

  Widget _buildCoupleHeaderBar() {
    final t = _theme;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.cardColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          _buildAvatarOrVector(_myAvatar, _myStage),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('❤️', style: TextStyle(fontSize: 18, color: t.accent)),
          ),
          if (_partnerId == null)
            Expanded(
              child: GestureDetector(
                onTap: _openInvitePartnerSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: t.accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: t.accent.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_add_alt_1_rounded,
                          color: t.accent, size: 17),
                      const SizedBox(width: 6),
                      Text(
                        'Invite Partner',
                        style: GoogleFonts.outfit(
                          color: t.textColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else ...[
            _buildAvatarOrVector(_partnerAvatar, _partnerStage),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _partnerName ?? 'Partner',
                    style: GoogleFonts.outfit(
                      color: t.textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '❤️ Relation Score: $_relationScore',
                    style: GoogleFonts.plusJakartaSans(
                      color: t.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Couple Chat Space',
              icon: Icon(Icons.favorite_rounded, color: t.accent, size: 22),
              onPressed: _openCoupleSpace,
            ),
            IconButton(
              tooltip: 'Remove Partner',
              icon: Icon(Icons.person_remove_rounded,
                  color: t.subTextColor, size: 20),
              onPressed: _removePartner,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLiveWhisperCard() {
    final t = _theme;
    final incoming = _whispers.where((w) => w['sender_id'] != _uid).toList();
    final latest = incoming.isNotEmpty ? incoming.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Text(latest != null ? '💌' : '🎙️', style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: latest != null
                ? GestureDetector(
                    onTap: () async {
                      final txt = latest['text']?.toString() ?? '';
                      final isVoice = latest['is_voice'] == true;
                      if (isVoice && txt.isNotEmpty) {
                        try {
                          await _tts.speak(txt);
                        } catch (_) {}
                      }
                      if (mounted) {
                        await showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: t.cardColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: Text(
                              '💌 1-Time Whisper from ${_partnerName ?? 'Partner'}',
                              style: GoogleFonts.outfit(
                                  color: t.textColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15),
                            ),
                            content: Text(
                              txt,
                              style: GoogleFonts.plusJakartaSans(
                                  color: t.textColor, fontSize: 15),
                            ),
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: t.accent,
                                  foregroundColor:
                                      t.isDark ? Colors.black : Colors.white,
                                ),
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Seen ❤️'),
                              ),
                            ],
                          ),
                        );
                      }
                      final id = latest['id'];
                      setState(() => _whispers.removeWhere((w) => w['id'] == id));
                      await _syncCoupleEvent('mark_whisper_seen', {'id': id});
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1-Time Whisper from ${_partnerName ?? 'Partner'}',
                          style: GoogleFonts.outfit(
                            color: t.accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                          ),
                        ),
                        Text(
                          'Tap to open & listen (auto-vanishes)',
                          style: GoogleFonts.plusJakartaSans(
                            color: t.subTextColor,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Couple Whisper',
                        style: GoogleFonts.outfit(
                          color: t.textColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Send a 1-time secret note or voice whisper',
                        style: GoogleFonts.plusJakartaSans(
                          color: t.subTextColor,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
          ),
          GestureDetector(
            onTap: () {
              final ctrl = TextEditingController();
              bool asVoice = true;
              showDialog(
                context: context,
                builder: (ctx) => StatefulBuilder(
                  builder: (ctx, setD) => AlertDialog(
                    backgroundColor: t.cardColor,
                    title: Text('Send 1-Time Whisper',
                        style: GoogleFonts.outfit(color: t.textColor)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: ctrl,
                          style: TextStyle(color: t.textColor),
                          decoration: const InputDecoration(
                              hintText: 'Write a sweet note...'),
                        ),
                        SwitchListTile(
                          value: asVoice,
                          activeThumbColor: t.accent,
                          title: Text('Speak aloud as Voice',
                              style: TextStyle(color: t.textColor, fontSize: 13)),
                          onChanged: (v) => setD(() => asVoice = v),
                        ),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: t.accent,
                          foregroundColor:
                              t.isDark ? Colors.black : Colors.white,
                        ),
                        onPressed: () async {
                          if (ctrl.text.trim().isEmpty) return;
                          final w = {
                            'id': 'w_${DateTime.now().millisecondsSinceEpoch}',
                            'sender_id': _uid,
                            'text': ctrl.text.trim(),
                            'is_voice': asVoice,
                          };
                          setState(() => _whispers.insert(0, w));
                          await _syncCoupleEvent('add_whisper', w);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        child: const Text('Send 💌'),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: t.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Send',
                style: GoogleFonts.outfit(
                  color: t.isDark ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeDashboard() {
    final t = _theme;
    final remaining = (_monthlyBudget + _totalIncome - _totalSpent);
    final pct = (_monthlyBudget > 0 ? (_totalSpent / _monthlyBudget) : 0.0)
        .clamp(0.0, 1.0);
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = (daysInMonth - now.day + 1).clamp(1, 31);
    final safeDaily = (remaining / daysLeft).clamp(0.0, double.infinity);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        if (_isCoupleMode && !widget.embeddedInGroup) _buildCoupleHeaderBar(),
        if (_isCoupleMode && _partnerId != null && !widget.embeddedInGroup)
          _buildLiveWhisperCard(),

        // Story-style Snapshot Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                t.accent.withValues(alpha: 0.28),
                t.cardColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: t.accent.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DAILY SNAPSHOT',
                    style: GoogleFonts.outfit(
                      color: t.accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1.1,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openAddEntrySheet(isIncome: true),
                    icon: Icon(Icons.add_circle_outline_rounded,
                        color: t.secondaryAccent, size: 16),
                    label: Text(
                      'Income',
                      style: GoogleFonts.outfit(
                        color: t.secondaryAccent,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '$_currencySymbol${remaining.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  color: t.textColor,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Remaining • Today $_currencySymbol${_todaySpent.toStringAsFixed(0)} • Safe $_currencySymbol${safeDaily.toStringAsFixed(0)}/day',
                style: GoogleFonts.plusJakartaSans(
                  color: _todaySpent > safeDaily && safeDaily > 0
                      ? const Color(0xFFEF4444)
                      : t.subTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 8,
                  backgroundColor: t.textColor.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(
                    pct > 0.85 ? const Color(0xFFEF4444) : t.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Quick Smart Add Bar (e.g. "Tea 25" or "Auto 80")
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: t.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.textColor.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Icon(Icons.bolt_rounded, color: t.accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _quickAddCtrl,
                  style: TextStyle(color: t.textColor, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Quick add: e.g. "Tea 25" or "Auto 80"',
                    hintStyle: TextStyle(color: t.subTextColor, fontSize: 12.5),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (_) => _handleQuickSmartAdd(),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send_rounded, color: t.accent, size: 19),
                onPressed: _handleQuickSmartAdd,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (_isCoupleMode && _partnerId != null) _buildCoupleSplitCard(),
        _buildSavingsGoalsSection(),

        Text(
          'Recent Entries',
          style: GoogleFonts.outfit(
            color: t.textColor,
            fontWeight: FontWeight.w800,
            fontSize: 15.5,
          ),
        ),
        const SizedBox(height: 8),
        if (_entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: Text(
                'Tap "+ Add" to record your first expense!',
                style: GoogleFonts.plusJakartaSans(
                  color: t.subTextColor,
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          ..._entries.take(6).map(_buildEntryTile),
      ],
    );
  }

  Widget _buildCoupleSplitCard() {
    final t = _theme;
    final myPaid = _entries
        .where((e) => e['is_income'] != true && e['paid_by_uid'] == _uid)
        .fold(0.0, (s, e) => s + ((e['amount'] as num?)?.toDouble() ?? 0.0));
    final partnerPaid = _entries
        .where((e) => e['is_income'] != true && e['paid_by_uid'] == _partnerId)
        .fold(0.0, (s, e) => s + ((e['amount'] as num?)?.toDouble() ?? 0.0));
    final diff = (myPaid - partnerPaid) / 2.0;
    final statusText = diff.abs() < 1
        ? 'All Settled! 💚'
        : (diff > 0
            ? '${_partnerName ?? 'Partner'} owes you ₹${diff.toStringAsFixed(0)}'
            : 'You owe ${_partnerName ?? 'Partner'} ₹${(-diff).toStringAsFixed(0)}');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.balance_rounded, color: t.accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: GoogleFonts.outfit(
                    color: t.textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
                Text(
                  'You paid $_currencySymbol${myPaid.toStringAsFixed(0)} • ${_partnerName ?? 'Partner'} paid $_currencySymbol${partnerPaid.toStringAsFixed(0)}',
                  style: GoogleFonts.plusJakartaSans(
                    color: t.subTextColor,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          if (diff.abs() >= 1)
            GestureDetector(
              onTap: () async {
                final payerUid = diff > 0 ? _partnerId! : _uid;
                final payerName =
                    diff > 0 ? (_partnerName ?? 'Partner') : _myName;
                final settleAmt = diff.abs() * 2;
                final settleEntry = {
                  'id': 'settle_${DateTime.now().millisecondsSinceEpoch}',
                  'title': 'Settled Balance',
                  'amount': settleAmt,
                  'category': 'Other',
                  'payment_mode': 'UPI',
                  'paid_by_uid': payerUid,
                  'paid_by_name': payerName,
                  'is_income': true,
                  'added_by': _myName,
                  'created_at': DateTime.now().toIso8601String(),
                };
                // Balance out split by recording an offsetting entry
                final offsetEntry = Map<String, dynamic>.from(settleEntry)
                  ..['is_income'] = false;
                setState(() => _entries.insert(0, offsetEntry));
                await _saveEntries();
                await _syncCoupleEvent('add_entry', offsetEntry);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: t.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Settle Up',
                  style: GoogleFonts.outfit(
                    color: t.isDark ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSavingsGoalsSection() {
    final t = _theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Savings Goal Jars',
              style: GoogleFonts.outfit(
                color: t.textColor,
                fontWeight: FontWeight.w800,
                fontSize: 15.5,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                if (!_isVip && _goals.isNotEmpty) {
                  _showVipUpgradeDialog();
                  return;
                }
                final titleCtrl = TextEditingController();
                final targetCtrl = TextEditingController();
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: t.cardColor,
                    title: Text('New Savings Goal',
                        style: GoogleFonts.outfit(color: t.textColor)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleCtrl,
                          style: TextStyle(color: t.textColor),
                          decoration: const InputDecoration(hintText: 'Goal name (e.g. Goa Trip)'),
                        ),
                        TextField(
                          controller: targetCtrl,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: t.textColor),
                          decoration: const InputDecoration(hintText: 'Target (₹)'),
                        ),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () async {
                          final tgt = double.tryParse(targetCtrl.text.trim()) ?? 0;
                          if (titleCtrl.text.trim().isEmpty || tgt <= 0) return;
                          final g = {
                            'id': 'goal_${DateTime.now().millisecondsSinceEpoch}',
                            'title': titleCtrl.text.trim(),
                            'icon': '🎯',
                            'target': tgt,
                            'saved': 0.0,
                          };
                          setState(() => _goals.add(g));
                          await _saveGoals();
                          await _syncCoupleEvent('upsert_goal', g);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        child: const Text('Create'),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.add_rounded, color: t.accent, size: 18),
              label: Text('New Goal', style: TextStyle(color: t.accent)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ..._goals.map((g) {
          final target = (g['target'] as num?)?.toDouble() ?? 1.0;
          final saved = (g['saved'] as num?)?.toDouble() ?? 0.0;
          final pct = (saved / target).clamp(0.0, 1.0);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: t.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${g['icon'] ?? '🎯'} ${g['title']}',
                      style: GoogleFonts.outfit(
                        color: t.textColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() => g['saved'] = saved + 500.0);
                        await _saveGoals();
                        await _syncCoupleEvent('upsert_goal', Map<String, dynamic>.from(g));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: t.accent.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '+ ₹500',
                          style: GoogleFonts.outfit(
                            color: t.accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                  backgroundColor: t.textColor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(t.secondaryAccent),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${saved.toStringAsFixed(0)} / ₹${target.toStringAsFixed(0)}',
                  style: GoogleFonts.plusJakartaSans(
                    color: t.subTextColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 10),
      ],
    );
  }

  Future<void> _showSalaryBudgetInputDialog({
    required String title,
    required double initialValue,
    required ValueChanged<double> onSaved,
  }) async {
    final t = _theme;
    final ctrl = TextEditingController(
      text: initialValue > 0 ? initialValue.toStringAsFixed(0) : '',
    );
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.cardColor,
        title: Text(title,
            style: GoogleFonts.outfit(
                color: t.textColor, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: TextStyle(color: t.textColor),
          decoration: InputDecoration(
            hintText: 'Enter amount ($_currencySymbol)',
            hintStyle: TextStyle(color: t.subTextColor),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: t.subTextColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: t.accent,
              foregroundColor: t.onAccentTextColor,
            ),
            onPressed: () {
              final val = double.tryParse(ctrl.text.trim()) ?? 0.0;
              Navigator.pop(ctx);
              onSaved(val);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetTab() {
    final t = _theme;
    final totalBudget =
        _isCoupleMode ? (_monthlyBudget + _partnerBudget) : _monthlyBudget;
    final totalSalary =
        _isCoupleMode ? (_mySalary + _partnerSalary) : _mySalary;
    final planBase = totalSalary > 0 ? totalSalary : totalBudget;
    final needsAmt = planBase * 0.50;
    final wantsAmt = planBase * 0.30;
    final savingsAmt = planBase * 0.20;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        // 💼 Salary & Monthly Budget Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: t.cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isCoupleMode
                        ? 'Couple Salary & Budget'
                        : 'Monthly Salary & Budget',
                    style: GoogleFonts.outfit(
                      color: t.textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Total: $_currencySymbol${totalBudget.toStringAsFixed(0)}',
                    style: GoogleFonts.outfit(
                      color: t.accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_isCoupleMode) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: t.accent.withValues(alpha: 0.45)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _showSalaryBudgetInputDialog(
                          title: 'Partner 1 (His) Salary',
                          initialValue: _mySalary,
                          onSaved: (v) {
                            setState(() => _mySalary = v);
                            _saveSalaryAndPartnerBudget(mySalary: v);
                          },
                        ),
                        child: Text(
                          'His Salary: $_currencySymbol${_mySalary.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                              color: t.textColor,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: t.accent.withValues(alpha: 0.45)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _showSalaryBudgetInputDialog(
                          title: 'Partner 2 (Her) Salary',
                          initialValue: _partnerSalary,
                          onSaved: (v) {
                            setState(() => _partnerSalary = v);
                            _saveSalaryAndPartnerBudget(partnerSalary: v);
                          },
                        ),
                        child: Text(
                          'Her Salary: $_currencySymbol${_partnerSalary.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                              color: t.textColor,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Partner 1 Budget: $_currencySymbol${_monthlyBudget.toStringAsFixed(0)}',
                  style: GoogleFonts.plusJakartaSans(
                      color: t.subTextColor, fontSize: 12.5),
                ),
                Slider(
                  value: _monthlyBudget.clamp(1000, 100000),
                  min: 1000,
                  max: 100000,
                  divisions: 99,
                  activeColor: t.accent,
                  onChanged: (v) {
                    setState(() => _monthlyBudget = v);
                    _saveBudget(v);
                  },
                ),
                Text(
                  'Partner 2 Budget: $_currencySymbol${_partnerBudget.toStringAsFixed(0)}',
                  style: GoogleFonts.plusJakartaSans(
                      color: t.subTextColor, fontSize: 12.5),
                ),
                Slider(
                  value: _partnerBudget.clamp(1000, 100000),
                  min: 1000,
                  max: 100000,
                  divisions: 99,
                  activeColor: t.secondaryAccent,
                  onChanged: (v) {
                    setState(() => _partnerBudget = v);
                    _saveSalaryAndPartnerBudget(partnerBudget: v);
                  },
                ),
              ] else ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: t.accent.withValues(alpha: 0.45)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _showSalaryBudgetInputDialog(
                    title: 'My Monthly Salary',
                    initialValue: _mySalary,
                    onSaved: (v) {
                      setState(() => _mySalary = v);
                      _saveSalaryAndPartnerBudget(mySalary: v);
                    },
                  ),
                  icon: Icon(Icons.payments_rounded, color: t.accent, size: 18),
                  label: Text(
                    _mySalary > 0
                        ? 'Monthly Salary: $_currencySymbol${_mySalary.toStringAsFixed(0)}'
                        : 'Add Monthly Salary',
                    style: GoogleFonts.outfit(
                        color: t.textColor, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Limit: $_currencySymbol${_monthlyBudget.toStringAsFixed(0)}',
                  style: GoogleFonts.plusJakartaSans(
                    color: t.subTextColor,
                    fontSize: 13,
                  ),
                ),
                Slider(
                  value: _monthlyBudget.clamp(1000, 100000),
                  min: 1000,
                  max: 100000,
                  divisions: 99,
                  activeColor: t.accent,
                  onChanged: (v) {
                    setState(() => _monthlyBudget = v);
                    _saveBudget(v);
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 💡 Brief Smart Spending Guide (50 / 30 / 20 Rule)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: t.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.accent.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                totalSalary > 0
                    ? 'Smart Plan on $_currencySymbol${totalSalary.toStringAsFixed(0)} Salary'
                    : 'Smart 50 / 30 / 20 Guide',
                style: GoogleFonts.outfit(
                  color: t.textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Needs (50%)\n$_currencySymbol${needsAmt.toStringAsFixed(0)}',
                    style: TextStyle(color: t.subTextColor, fontSize: 12),
                  ),
                  Text(
                    'Wants (30%)\n$_currencySymbol${wantsAmt.toStringAsFixed(0)}',
                    style: TextStyle(color: t.subTextColor, fontSize: 12),
                  ),
                  Text(
                    'Savings (20%)\n$_currencySymbol${savingsAmt.toStringAsFixed(0)}',
                    style: TextStyle(
                        color: t.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ..._categories.map((c) {
          final name = c['name'] as String;
          final catSpent = _entries
              .where((e) => e['is_income'] != true && e['category'] == name)
              .fold(0.0, (s, e) => s + ((e['amount'] as num?)?.toDouble() ?? 0.0));
          final pct = (totalBudget > 0 ? (catSpent / totalBudget) : 0.0)
              .clamp(0.0, 1.0);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: t.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${c['icon']} $name',
                        style: GoogleFonts.outfit(
                            color: t.textColor, fontWeight: FontWeight.w700)),
                    Text('$_currencySymbol${catSpent.toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(
                            color: t.textColor, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                  backgroundColor: t.textColor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(Color(c['color'] as int)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHistoryTab() {
    final t = _theme;
    final filtered = _entries.where((e) {
      final matchesCat =
          _historyFilter == 'All' || e['category'] == _historyFilter;
      final matchesQ = _historyQuery.isEmpty ||
          (e['title']?.toString().toLowerCase() ?? '')
              .contains(_historyQuery.toLowerCase());
      return matchesCat && matchesQ;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
          child: TextField(
            onChanged: (v) => setState(() => _historyQuery = v),
            style: TextStyle(color: t.textColor),
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              hintStyle: TextStyle(color: t.subTextColor),
              prefixIcon: Icon(Icons.search_rounded, color: t.subTextColor),
              filled: true,
              fillColor: t.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: ['All', ..._categories.map((c) => c['name'] as String)]
                .map((cat) {
              final sel = _historyFilter == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildPillChip(
                  label: cat,
                  selected: sel,
                  onTap: () => setState(() => _historyFilter = cat),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _buildEntryTile(filtered[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildTasksTab() {
    final t = _theme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bills',
              style: GoogleFonts.outfit(
                color: t.textColor,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                final ctrl = TextEditingController();
                final amtCtrl = TextEditingController();
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: t.cardColor,
                    title: Text('Add Bill',
                        style: GoogleFonts.outfit(color: t.textColor)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: ctrl,
                          style: TextStyle(color: t.textColor),
                          decoration: const InputDecoration(hintText: 'Bill name'),
                        ),
                        TextField(
                          controller: amtCtrl,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: t.textColor),
                          decoration: InputDecoration(
                              hintText: 'Amount ($_currencySymbol)'),
                        ),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () async {
                          if (ctrl.text.trim().isEmpty) return;
                          setState(() {
                            _billTasks.add({
                              'id': 'bt_${DateTime.now().millisecondsSinceEpoch}',
                              'title': ctrl.text.trim(),
                              'amount':
                                  double.tryParse(amtCtrl.text.trim()) ?? 0.0,
                              'done': false,
                            });
                          });
                          await _saveTasks();
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.add_rounded, color: t.accent),
              label: Text('Add Bill', style: TextStyle(color: t.accent)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(_billTasks.length, (idx) {
          final item = _billTasks[idx];
          final done = item['done'] == true;
          final billId = item['id']?.toString() ?? 'bill_$idx';
          return Dismissible(
            key: Key('bill_dismiss_$billId'),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.only(right: 18),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Colors.white),
            ),
            onDismissed: (_) async {
              setState(() => _billTasks.removeAt(idx));
              await _saveTasks();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: t.cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: Checkbox(
                  value: done,
                  activeColor: t.accent,
                  onChanged: (v) async {
                    final checked = v ?? false;
                    setState(() => item['done'] = checked);
                    await _saveTasks();
                    await _syncCoupleEvent(
                        'upsert_task', Map<String, dynamic>.from(item));
                    final billAmt =
                        (item['amount'] as num?)?.toDouble() ?? 0.0;
                    if (checked && billAmt > 0) {
                      if (!_isVip && _entries.length >= kFreeEntryLimit) {
                        _showVipUpgradeDialog();
                        return;
                      }
                      final exp = {
                        'id': 'bill_${DateTime.now().millisecondsSinceEpoch}',
                        'title': item['title']?.toString() ?? 'Bill Paid',
                        'amount': billAmt,
                        'category': 'Bills',
                        'payment_mode': 'UPI',
                        'paid_by_uid': _uid,
                        'paid_by_name': _myName,
                        'is_income': false,
                        'added_by': _myName,
                        'created_at': DateTime.now().toIso8601String(),
                      };
                      setState(() => _entries.insert(0, exp));
                      await _saveEntries();
                      await _syncCoupleEvent('add_entry', exp);
                    }
                  },
                ),
                title: Text(
                  item['title']?.toString() ?? '',
                  style: GoogleFonts.outfit(
                    color: t.textColor,
                    fontWeight: FontWeight.w700,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  '$_currencySymbol${((item['amount'] as num?)?.toDouble() ?? 0).toStringAsFixed(0)}',
                  style: GoogleFonts.plusJakartaSans(
                    color: t.subTextColor,
                    fontSize: 12,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline_rounded,
                      color: t.subTextColor, size: 20),
                  onPressed: () async {
                    setState(() => _billTasks.removeAt(idx));
                    await _saveTasks();
                  },
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEntryTile(Map<String, dynamic> e) {
    final t = _theme;
    final isInc = e['is_income'] == true;
    final amt = (e['amount'] as num?)?.toDouble() ?? 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: (isInc ? t.secondaryAccent : t.accent)
                .withValues(alpha: 0.16),
            child: Icon(
              isInc ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isInc ? t.secondaryAccent : t.accent,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e['title']?.toString() ?? '',
                  style: GoogleFonts.outfit(
                    color: t.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  e['category']?.toString() ?? 'Other',
                  style: GoogleFonts.plusJakartaSans(
                    color: t.subTextColor,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isInc ? '+' : '-'}$_currencySymbol${amt.toStringAsFixed(0)}',
            style: GoogleFonts.outfit(
              color: isInc ? t.secondaryAccent : t.textColor,
              fontWeight: FontWeight.w800,
              fontSize: 14.5,
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                color: t.subTextColor, size: 18),
            onPressed: () async {
              final deletedId = e['id'];
              setState(() => _entries.removeWhere((x) => x['id'] == deletedId));
              await _saveEntries();
              if (deletedId != null) {
                await _syncCoupleEvent('delete_entry', {'id': deletedId});
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPillChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final t = _theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? t.accent
              : (t.isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? t.accent
                : t.textColor.withValues(alpha: 0.22),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: selected
                ? (t.isDark ? Colors.black : Colors.white)
                : t.textColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildCoupleSpaceTab() {
    final t = _theme;
    final moods = [
      'Missing you ❤️',
      'Coffee? ☕',
      'Busy at work 💼',
      'Date Night 🌙',
      'Happy 🥰',
    ];

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              _buildCoupleHeaderBar(),

              // Daily Mood & Love Notes
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: t.cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: t.accent.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '💘 Love Notes & Mood',
                          style: GoogleFonts.outfit(
                            color: t.textColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                          ),
                        ),
                        if (_partnerMood.isNotEmpty)
                          Text(
                            '${_partnerName ?? 'Partner'}: $_partnerMood',
                            style: GoogleFonts.plusJakartaSans(
                              color: t.accent,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: moods.map((m) {
                        final sel = _myMood == m;
                        return _buildPillChip(
                          label: m,
                          selected: sel,
                          onTap: () async {
                            setState(() => _myMood = m);
                            await _syncCoupleEvent(
                                'set_mood', {'uid': _uid, 'mood': m});
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Special Dates & Milestones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '📅 Special Dates',
                    style: GoogleFonts.outfit(
                      color: t.textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      if (!_isVip && _milestones.length >= 2) {
                        _showVipUpgradeDialog();
                        return;
                      }
                      final ctrl = TextEditingController();
                      DateTime picked =
                          DateTime.now().add(const Duration(days: 30));
                      await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: t.cardColor,
                          title: Text('Add Special Date',
                              style: GoogleFonts.outfit(color: t.textColor)),
                          content: TextField(
                            controller: ctrl,
                            style: TextStyle(color: t.textColor),
                            decoration: const InputDecoration(
                                hintText: 'e.g. Anniversary, Trip Day'),
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () async {
                                if (ctrl.text.trim().isEmpty) return;
                                final m = {
                                  'id':
                                      'ms_${DateTime.now().millisecondsSinceEpoch}',
                                  'title': ctrl.text.trim(),
                                  'date': picked.toIso8601String(),
                                };
                                setState(() => _milestones.add(m));
                                await _syncCoupleEvent('upsert_milestone', m);
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.add_rounded, color: t.accent, size: 18),
                    label: Text('Add Date', style: TextStyle(color: t.accent)),
                  ),
                ],
              ),
              ..._milestones.map((m) {
                final dt = DateTime.tryParse(m['date']?.toString() ?? '') ??
                    DateTime.now();
                final daysLeft = dt.difference(DateTime.now()).inDays;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: t.cardColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '💍 ${m['title']}',
                        style: GoogleFonts.outfit(
                          color: t.textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        daysLeft >= 0 ? '$daysLeft days left' : 'Passed',
                        style: GoogleFonts.outfit(
                          color: t.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),

              // Shared Bucket List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '✨ Couple Bucket List',
                    style: GoogleFonts.outfit(
                      color: t.textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      if (!_isVip && _bucketList.length >= 2) {
                        _showVipUpgradeDialog();
                        return;
                      }
                      final ctrl = TextEditingController();
                      await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: t.cardColor,
                          title: Text('Add Bucket List',
                              style: GoogleFonts.outfit(color: t.textColor)),
                          content: TextField(
                            controller: ctrl,
                            style: TextStyle(color: t.textColor),
                            decoration: const InputDecoration(
                                hintText: 'Place, movie, or wish...'),
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () async {
                                if (ctrl.text.trim().isEmpty) return;
                                final b = {
                                  'id':
                                      'bk_${DateTime.now().millisecondsSinceEpoch}',
                                  'title': ctrl.text.trim(),
                                  'done': false,
                                };
                                setState(() => _bucketList.add(b));
                                await _syncCoupleEvent('upsert_bucket', b);
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.add_rounded, color: t.accent, size: 18),
                    label: Text('Add Wish', style: TextStyle(color: t.accent)),
                  ),
                ],
              ),
              ..._bucketList.map((b) {
                final done = b['done'] == true;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: t.cardColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: CheckboxListTile(
                    value: done,
                    activeColor: t.accent,
                    title: Text(
                      b['title']?.toString() ?? '',
                      style: GoogleFonts.outfit(
                        color: t.textColor,
                        fontWeight: FontWeight.w700,
                        decoration: done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    onChanged: (v) async {
                      setState(() => b['done'] = v ?? false);
                      await _syncCoupleEvent(
                          'upsert_bucket', Map<String, dynamic>.from(b));
                    },
                  ),
                );
              }),
              const SizedBox(height: 14),

              // Built-in Private Couple Chat
              Text(
                '💬 Private Couple Chat',
                style: GoogleFonts.outfit(
                  color: t.textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              if (_partnerId == null)
                Text(
                  'Invite your partner above to unlock Private Couple Chat!',
                  style: GoogleFonts.plusJakartaSans(
                    color: t.subTextColor,
                    fontSize: 12.5,
                  ),
                )
              else if (_coupleMessages.isEmpty)
                Text(
                  'Say hi to ${_partnerName ?? 'your partner'}! ❤️',
                  style: GoogleFonts.plusJakartaSans(
                    color: t.subTextColor,
                    fontSize: 12.5,
                  ),
                )
              else
                ..._coupleMessages.take(15).map((msg) {
                  final isMe = msg['sender_id']?.toString() == _uid;
                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isMe ? t.accent : t.cardColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        msg['message_text']?.toString() ?? '',
                        style: GoogleFonts.plusJakartaSans(
                          color: isMe
                              ? (t.isDark ? Colors.black : Colors.white)
                              : t.textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
        if (_partnerId != null && _coupleGroupId != null)
          Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 10, 10),
            color: t.cardColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _coupleChatCtrl,
                    style: TextStyle(color: t.textColor, fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Write a sweet message...',
                      hintStyle: TextStyle(color: t.subTextColor),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send_rounded, color: t.accent),
                  onPressed: () async {
                    final txt = _coupleChatCtrl.text.trim();
                    if (txt.isEmpty) return;
                    _coupleChatCtrl.clear();
                    setState(() {
                      _coupleMessages.insert(0, {
                        'sender_id': _uid,
                        'message_text': txt,
                        'created_at': DateTime.now().toIso8601String(),
                      });
                    });
                    try {
                      await _supabase.from('group_messages').insert({
                        'group_id': _coupleGroupId,
                        'sender_id': _uid,
                        'message_text': txt,
                        'message_type': 'text',
                      });
                    } catch (_) {}
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}
