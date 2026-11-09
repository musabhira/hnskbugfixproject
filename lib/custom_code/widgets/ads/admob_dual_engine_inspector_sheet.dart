import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';

/// 🔬 Pocket AdMob Dual-Engine Lab & Live Diagnostic Inspector
/// Enables side-by-side comparison of Legacy Engine (dc50278) vs Current Engine,
/// real-time Supabase entitlement diagnostics, and live AdMob error inspection on physical devices.
class AdMobDualEngineInspectorSheet extends StatefulWidget {
  const AdMobDualEngineInspectorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AdMobDualEngineInspectorSheet(),
    );
  }

  @override
  State<AdMobDualEngineInspectorSheet> createState() =>
      _AdMobDualEngineInspectorSheetState();
}

class _AdMobDualEngineInspectorSheetState
    extends State<AdMobDualEngineInspectorSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Keys to force rebuild / fresh ad requests
  Key _engineAKey = UniqueKey();
  Key _engineBKey = UniqueKey();

  // Live status trackers
  String _engineAStatus = 'Initializing...';
  String _engineBStatus = 'Initializing...';
  String? _engineADetails;
  String? _engineBDetails;

  // Supabase & Entitlement Diagnostics
  bool _isLoadingDb = true;
  String? _userId;
  String? _userEmail;
  Map<String, dynamic> _profileDbState = {};
  bool _cachedVipSync = false;
  bool _cachedVipAsync = false;

  // Manual Test Overrides
  bool _forceFreeMode = false;

  // Real-time Event Log Console
  final List<String> _logs = [];
  final ScrollController _logScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLiveDiagnostics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _logScrollController.dispose();
    super.dispose();
  }

  void _addLog(String source, String status, String? details) {
    if (!mounted) return;
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final entry = '[$timeStr] [$source] $status ${details != null ? '-> $details' : ''}';
    setState(() {
      _logs.insert(0, entry);
      if (_logs.length > 80) _logs.removeLast();
    });
  }

  Future<void> _loadLiveDiagnostics() async {
    setState(() => _isLoadingDb = true);
    _addLog('SYS', 'FETCH_START', 'Querying Supabase profile & cache');

    try {
      final user = SupaFlow.client.auth.currentUser;
      _userId = user?.id ?? 'No auth user (Guest)';
      _userEmail = user?.email ?? 'No email';

      _cachedVipSync = PocketAdMobService.instance.isUserVipSync();
      _cachedVipAsync = await PocketAdMobService.instance.isUserVip();

      if (user?.id != null) {
        final res = await SupaFlow.client
            .from('profile')
            .select('is_vip, is_premium, verified, subscription_tier, subscription_status, role')
            .eq('id', user!.id)
            .maybeSingle();

        _profileDbState = res ?? {'status': 'No record found in profile table'};
      }

      _addLog('SYS', 'DIAGNOSTICS_READY',
          'VipSync: $_cachedVipSync | VipAsync: $_cachedVipAsync | DB: $_profileDbState');
    } catch (e) {
      _profileDbState = {'error': e.toString()};
      _addLog('SYS', 'DB_ERROR', e.toString());
    } finally {
      if (mounted) setState(() => _isLoadingDb = false);
    }
  }

  void _reloadBothEngines() {
    HapticFeedback.mediumImpact();
    setState(() {
      _engineAKey = UniqueKey();
      _engineBKey = UniqueKey();
      _engineAStatus = 'Reloading...';
      _engineBStatus = 'Reloading...';
      _engineADetails = null;
      _engineBDetails = null;
    });
    _addLog('ACTION', 'RELOAD_ALL', 'Triggered fresh ad network calls for both engines');
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.90,
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0xFFFFFC00), width: 1.5),
          left: BorderSide(color: Colors.white12, width: 0.8),
          right: BorderSide(color: Colors.white12, width: 0.8),
        ),
      ),
      child: Column(
        children: [
          // Drag handle & Header
          _buildHeader(context),

          // Diagnostic Entitlement Status Card
          _buildEntitlementCard(),

          // Engine Selector Tabs
          _buildTabs(),

          // Main Content View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDualComparisonView(),
                _buildSingleEngineView(isLegacy: true),
                _buildSingleEngineView(isLegacy: false),
              ],
            ),
          ),

          // Action Toolbar & Live Console
          _buildBottomActionStrip(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFFFFC00).withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Color(0xFFFFFC00),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'AdMob Live Lab',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Platform.isIOS
                            ? Colors.blue.withValues(alpha: 0.2)
                            : Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Platform.isIOS
                              ? Colors.blueAccent
                              : Colors.greenAccent,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        Platform.isIOS ? 'iOS Device' : 'Android',
                        style: GoogleFonts.outfit(
                          color: Platform.isIOS
                              ? Colors.blueAccent
                              : Colors.greenAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Compare dc50278 vs Current Engine & Inspect Errors',
                  style: GoogleFonts.outfit(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            tooltip: 'Reload Diagnostics',
            onPressed: () {
              HapticFeedback.lightImpact();
              _loadLiveDiagnostics();
            },
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white54),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEntitlementCard() {
    final isVipActive = _cachedVipSync || _cachedVipAsync;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isVipActive
              ? const Color(0xFFFFD700).withValues(alpha: 0.6)
              : Colors.greenAccent.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isVipActive ? Icons.verified_rounded : Icons.person_rounded,
                    color: isVipActive
                        ? const Color(0xFFFFD700)
                        : Colors.greenAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isVipActive
                        ? 'VIP ENTITLED (Ads Suppressed)'
                        : 'FREE ACCOUNT (Ads Active)',
                    style: GoogleFonts.outfit(
                      color: isVipActive
                          ? const Color(0xFFFFD700)
                          : Colors.greenAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Test Ads:',
                    style: GoogleFonts.outfit(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Switch.adaptive(
                    value: PocketAdMobService.useTestModeInBuild,
                    activeThumbColor: Colors.lightBlueAccent,
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      setState(() {
                        PocketAdMobService.useTestModeInBuild = val;
                        PocketAdMobService.instance.setOverrideTestMode(val);
                      });
                      _addLog('TEST', 'AD_MODE_TOGGLE',
                          val ? '🧪 Google Test Ads (100% Fill Rate) enabled' : '🚀 Live Production Ads enabled');
                      _reloadBothEngines();
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Bypass VIP:',
                    style: GoogleFonts.outfit(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Switch.adaptive(
                    value: _forceFreeMode,
                    activeThumbColor: const Color(0xFFFFFC00),
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      setState(() => _forceFreeMode = val);
                      _addLog('TEST', 'MODE_TOGGLE',
                          val ? 'Forced FREE test mode enabled' : 'Normal mode restored');
                      _reloadBothEngines();
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (_isLoadingDb)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.white10,
              color: Color(0xFFFFFC00),
            )
          else ...[
            Text(
              'User: ${_userEmail ?? 'Guest'} (${_userId?.substring(0, _userId!.length > 8 ? 8 : _userId!.length)}...)',
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11),
            ),
            const SizedBox(height: 2),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildDbChip(
                    'is_vip', _profileDbState['is_vip']?.toString() ?? 'null'),
                _buildDbChip('verified',
                    _profileDbState['verified']?.toString() ?? 'null'),
                _buildDbChip('is_premium',
                    _profileDbState['is_premium']?.toString() ?? 'null'),
                _buildDbChip('tier',
                    _profileDbState['subscription_tier']?.toString() ?? 'free'),
                _buildDbChip('role',
                    _profileDbState['role']?.toString() ?? 'user'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Equation: isTrueVip = ${isVipActive ? "TRUE (VIP)" : "FALSE (FREE)"}',
                  style: GoogleFonts.jetBrainsMono(
                    color: isVipActive ? const Color(0xFFFFD700) : Colors.greenAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('is_vip', false);
                    await prefs.setBool('is_premium', false);
                    await prefs.setBool('remove_ads', false);
                    await prefs.setString('handskill_plan', 'free');
                    if (_userId != null) {
                      await prefs.setBool('is_vip_$_userId', false);
                      await prefs.setBool('is_premium_$_userId', false);
                      await prefs.setString('handskill_plan_$_userId', 'free');
                    }
                    PocketAdMobService.instance.onAccountSwitched(_userId);
                    _addLog('ACTION', 'CACHE_PURGED', 'Wiped all old VIP flags from device storage!');
                    await _loadLiveDiagnostics();
                    _reloadBothEngines();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🧹 Device VIP Cache Purged! Free Mode Restored.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cleaning_services_rounded, color: Colors.redAccent, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'Wipe Device Cache',
                          style: GoogleFonts.outfit(
                            color: Colors.redAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDbChip(String label, String value) {
    final isTrue = value == 'true';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isTrue
            ? const Color(0xFFFFD700).withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isTrue
              ? const Color(0xFFFFD700).withValues(alpha: 0.4)
              : Colors.white12,
          width: 0.7,
        ),
      ),
      child: Text(
        '$label: $value',
        style: GoogleFonts.outfit(
          color: isTrue ? const Color(0xFFFFD700) : Colors.white70,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFFFFFC00),
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white60,
        labelStyle:
            GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12),
        tabs: const [
          Tab(text: 'Dual Compare'),
          Tab(text: 'Engine A (dc50278)'),
          Tab(text: 'Engine B (Current)'),
        ],
      ),
    );
  }

  Widget _buildDualComparisonView() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        // Engine A Card
        _buildEngineCardHeader(
          title: 'Engine A: Working dc50278 (v1.0.225)',
          badgeColor: Colors.amberAccent,
          status: _engineAStatus,
          details: _engineADetails,
        ),
        LegacyDc50278NativeAdCard(
          key: _engineAKey,
          placement: PocketAdPlacement.home,
          forceFreeMode: _forceFreeMode,
          onStatusChange: (status, details) {
            _addLog('ENGINE_A', status, details);
            if (mounted) {
              setState(() {
                _engineAStatus = status;
                _engineADetails = details;
              });
            }
          },
        ),

        const SizedBox(height: 16),

        // Engine B Card
        _buildEngineCardHeader(
          title: 'Engine B: Current Engine (v1.0.233)',
          badgeColor: Colors.cyanAccent,
          status: _engineBStatus,
          details: _engineBDetails,
        ),
        PocketNativeAdCard(
          key: _engineBKey,
          placement: PocketAdPlacement.home,
          forceFreeMode: _forceFreeMode,
          onStatusChange: (status, details) {
            _addLog('ENGINE_B', status, details);
            if (mounted) {
              setState(() {
                _engineBStatus = status;
                _engineBDetails = details;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSingleEngineView({required bool isLegacy}) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        _buildEngineCardHeader(
          title: isLegacy
              ? 'Engine A: Legacy dc50278 (v1.0.225)'
              : 'Engine B: Current Engine (v1.0.233)',
          badgeColor: isLegacy ? Colors.amberAccent : Colors.cyanAccent,
          status: isLegacy ? _engineAStatus : _engineBStatus,
          details: isLegacy ? _engineADetails : _engineBDetails,
        ),
        if (isLegacy)
          LegacyDc50278NativeAdCard(
            key: _engineAKey,
            placement: PocketAdPlacement.home,
            forceFreeMode: _forceFreeMode,
            onStatusChange: (status, details) {
              _addLog('ENGINE_A', status, details);
              if (mounted) {
                setState(() {
                  _engineAStatus = status;
                  _engineADetails = details;
                });
              }
            },
          )
        else
          PocketNativeAdCard(
            key: _engineBKey,
            placement: PocketAdPlacement.home,
            forceFreeMode: _forceFreeMode,
            onStatusChange: (status, details) {
              _addLog('ENGINE_B', status, details);
              if (mounted) {
                setState(() {
                  _engineBStatus = status;
                  _engineBDetails = details;
                });
              }
            },
          ),
      ],
    );
  }

  Widget _buildEngineCardHeader({
    required String title,
    required Color badgeColor,
    required String status,
    String? details,
  }) {
    final isLoaded = status == 'LOADED';
    final isFailed = status == 'FAILED';

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isLoaded
                      ? Colors.green.withValues(alpha: 0.2)
                      : isFailed
                          ? Colors.red.withValues(alpha: 0.2)
                          : badgeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isLoaded
                        ? Colors.greenAccent
                        : isFailed
                            ? Colors.redAccent
                            : badgeColor,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.outfit(
                    color: isLoaded
                        ? Colors.greenAccent
                        : isFailed
                            ? Colors.redAccent
                            : badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (details != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                details,
                style: GoogleFonts.outfit(
                  color: isFailed ? Colors.redAccent : Colors.white60,
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomActionStrip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Live Log Viewer Header & Logs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.terminal_rounded,
                      color: Color(0xFFFFFC00), size: 15),
                  const SizedBox(width: 6),
                  Text(
                    'Live Event Console (${_logs.length})',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  final text = _logs.join('\n');
                  Clipboard.setData(ClipboardData(text: text));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logs copied to clipboard'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    'Copy Logs',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFFC00),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Scrollable Console
          Container(
            height: 70,
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: ListView.builder(
              controller: _logScrollController,
              itemCount: _logs.length,
              itemBuilder: (ctx, i) {
                final log = _logs[i];
                final isError = log.contains('FAILED') || log.contains('ERROR');
                final isSuccess = log.contains('LOADED');
                return Text(
                  log,
                  style: GoogleFonts.jetBrainsMono(
                    color: isError
                        ? Colors.redAccent
                        : isSuccess
                            ? Colors.greenAccent
                            : Colors.white70,
                    fontSize: 9.5,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          // Quick Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _reloadBothEngines,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    'Reload Both Ads',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFC00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _addLog('TEST', 'REWARDED_CLICK', 'Triggering test rewarded ad');
                  PocketAdMobService.instance.showRewardedAd(
                    context: context,
                    forceShowForTesting: true,
                    onUserEarnedReward: (reward) {
                      _addLog('TEST', 'REWARDED_EARNED',
                          'Reward earned: ${reward.amount} ${reward.type}');
                    },
                  );
                },
                icon: const Icon(Icons.videocam_rounded, size: 16),
                label: Text(
                  'Rewarded Ad',
                  style: GoogleFonts.outfit(fontSize: 11.5),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _addLog('TEST', 'INTERSTITIAL_CLICK',
                      'Triggering test interstitial ad');
                  PocketAdMobService.instance.showInterstitialAd(
                    context: context,
                    forceShowForTesting: true,
                    onDismissed: () {
                      _addLog('TEST', 'INTERSTITIAL_DISMISSED',
                          'Interstitial dismissed');
                    },
                  );
                },
                icon: const Icon(Icons.fullscreen_rounded, size: 16),
                label: Text(
                  'Interstitial',
                  style: GoogleFonts.outfit(fontSize: 11.5),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
