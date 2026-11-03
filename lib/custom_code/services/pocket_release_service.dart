import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_president_service.dart';

/// 🚀 Model representing a distinct App Release Build Record
class AppReleaseRecord {
  final String id;
  final String platform; // 'android' or 'ios'
  final String version; // e.g. '1.0.155'
  final int buildNumber; // e.g. 330
  final String? shorebirdReleaseId;
  final String releaseTitle;
  final String releaseNotes;
  final List<String> features;
  final List<String> improvements;
  final List<String> bugFixes;
  final String announcementMessage;
  final String buildType; // 'Testing', 'Internal', 'TestFlight', 'Production'
  final String storeStatus; // 'draft', 'submitted', 'in_review', 'approved', 'live'
  final bool isActiveProduction;
  final DateTime? productionActivatedAt;
  final bool isMandatory;
  final String? storeUrl;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppReleaseRecord({
    required this.id,
    required this.platform,
    required this.version,
    required this.buildNumber,
    this.shorebirdReleaseId,
    required this.releaseTitle,
    required this.releaseNotes,
    this.features = const [],
    this.improvements = const [],
    this.bugFixes = const [],
    this.announcementMessage = '',
    this.buildType = 'Testing',
    this.storeStatus = 'draft',
    this.isActiveProduction = false,
    this.productionActivatedAt,
    this.isMandatory = false,
    this.storeUrl,
    this.createdBy = 'Admin',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory AppReleaseRecord.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      if (raw is String && raw.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) return decoded.map((e) => e.toString()).toList();
        } catch (_) {
          return [raw];
        }
      }
      return [];
    }

    return AppReleaseRecord(
      id: json['id']?.toString() ?? '',
      platform: (json['platform']?.toString() ?? 'android').toLowerCase(),
      version: json['version']?.toString().trim() ?? '1.0.0',
      buildNumber: int.tryParse(json['build_number']?.toString() ?? '0') ?? 0,
      shorebirdReleaseId: json['shorebird_release_id']?.toString(),
      releaseTitle: json['release_title']?.toString() ?? 'POKET Update',
      releaseNotes: json['release_notes']?.toString() ?? '',
      features: parseStringList(json['features']),
      improvements: parseStringList(json['improvements']),
      bugFixes: parseStringList(json['bug_fixes']),
      announcementMessage: json['announcement_message']?.toString() ?? '',
      buildType: json['build_type']?.toString() ?? 'Testing',
      storeStatus: json['store_status']?.toString() ?? 'draft',
      isActiveProduction: json['is_active_production'] == true,
      productionActivatedAt: json['production_activated_at'] != null
          ? DateTime.tryParse(json['production_activated_at'].toString())
          : null,
      isMandatory: json['is_mandatory'] == true,
      storeUrl: json['store_url']?.toString(),
      createdBy: json['created_by']?.toString() ?? 'Admin',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platform': platform.toLowerCase(),
      'version': version,
      'build_number': buildNumber,
      'shorebird_release_id': shorebirdReleaseId,
      'release_title': releaseTitle,
      'release_notes': releaseNotes,
      'features': features,
      'improvements': improvements,
      'bug_fixes': bugFixes,
      'announcement_message': announcementMessage,
      'build_type': buildType,
      'store_status': storeStatus,
      'is_active_production': isActiveProduction,
      'production_activated_at': productionActivatedAt?.toIso8601String(),
      'is_mandatory': isMandatory,
      'store_url': storeUrl,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get fullVersionString => '$version+$buildNumber';

  /// Formatted comprehensive release notes showing sections
  String get formattedDisplayNotes {
    if (releaseNotes.trim().isNotEmpty) return releaseNotes.trim();

    final buffer = StringBuffer();
    if (features.isNotEmpty) {
      buffer.writeln('✨ What\'s New:');
      for (final f in features) {
        buffer.writeln('• $f');
      }
      buffer.writeln();
    }
    if (improvements.isNotEmpty) {
      buffer.writeln('⚡ Improvements:');
      for (final i in improvements) {
        buffer.writeln('• $i');
      }
      buffer.writeln();
    }
    if (bugFixes.isNotEmpty) {
      buffer.writeln('🐛 Bug Fixes:');
      for (final b in bugFixes) {
        buffer.writeln('• $b');
      }
    }

    final res = buffer.toString().trim();
    return res.isNotEmpty ? res : 'Bug fixes, performance improvements, and new features.';
  }
}

/// 🏛️ Central Service for Version-Based Release Management & Store Update Tracking
class PocketReleaseService {
  static final PocketReleaseService instance = PocketReleaseService._internal();
  factory PocketReleaseService() => instance;
  PocketReleaseService._internal();

  static const String _kLocalReleasesStoreKey = 'pocket_app_releases_store_v1';
  static const String _kActiveAndroidReleaseKey = 'pocket_active_android_release_v1';
  static const String _kActiveIosReleaseKey = 'pocket_active_ios_release_v1';

  static const String defaultAndroidPlayStoreUrl =
      'https://play.google.com/store/apps/details?id=com.poketmates.app&pcampaignid=web_share';
  static const String defaultIosAppStoreUrl =
      'https://apps.apple.com/app/id6748091106';

  // ---------------------------------------------------------------------------
  // 1. FETCH ALL RELEASES (Admin Panel Table)
  // ---------------------------------------------------------------------------
  static Future<List<AppReleaseRecord>> fetchAllReleases() async {
    final List<AppReleaseRecord> results = [];
    final prefs = await SharedPreferences.getInstance();

    // 1. Try fetching from Supabase table `app_releases`
    try {
      final res = await SupaFlow.client
          .from('app_releases')
          .select('*')
          .order('build_number', ascending: false);

      if (res.isNotEmpty) {
        for (final item in res) {
          try {
            results.add(AppReleaseRecord.fromJson(item));
          } catch (_) {}
        }
        // Cache locally for offline resilience
        await prefs.setString(
          _kLocalReleasesStoreKey,
          jsonEncode(results.map((r) => r.toJson()).toList()),
        );
        return results;
      }
    } catch (e) {
      debugPrint('PocketReleaseService: Remote app_releases query error: $e');
    }

    // 2. Fallback to Local Preferences Store
    final localRaw = prefs.getString(_kLocalReleasesStoreKey);
    if (localRaw != null && localRaw.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(localRaw);
        for (final item in decoded) {
          results.add(AppReleaseRecord.fromJson(item));
        }
      } catch (_) {}
    }

    // 3. Fallback: If completely empty, synthesize from existing `app_updates` row 1
    if (results.isEmpty) {
      final legacy = await _synthesizeFromLegacyAppUpdates();
      if (legacy.isNotEmpty) {
        results.addAll(legacy);
        await saveReleasesLocally(results);
      }
    }

    return results;
  }

  // ---------------------------------------------------------------------------
  // 2. FETCH ACTIVE PRODUCTION RELEASE FOR SPECIFIC PLATFORM
  // ---------------------------------------------------------------------------
  static Future<AppReleaseRecord?> fetchActiveProductionRelease(String platform) async {
    final cleanPlatform = platform.toLowerCase().trim();
    final prefs = await SharedPreferences.getInstance();

    // 1. Fetch from Supabase
    try {
      final res = await SupaFlow.client
          .from('app_releases')
          .select('*')
          .eq('platform', cleanPlatform)
          .eq('is_active_production', true)
          .maybeSingle();

      if (res != null) {
        final record = AppReleaseRecord.fromJson(res);
        final cacheKey = cleanPlatform == 'ios' ? _kActiveIosReleaseKey : _kActiveAndroidReleaseKey;
        await prefs.setString(cacheKey, jsonEncode(record.toJson()));
        return record;
      }
    } catch (e) {
      debugPrint('PocketReleaseService: Error fetching remote active release: $e');
    }

    // 2. Check local active cache
    final cacheKey = cleanPlatform == 'ios' ? _kActiveIosReleaseKey : _kActiveAndroidReleaseKey;
    final cachedJson = prefs.getString(cacheKey);
    if (cachedJson != null && cachedJson.isNotEmpty) {
      try {
        return AppReleaseRecord.fromJson(jsonDecode(cachedJson));
      } catch (_) {}
    }

    // 3. Fallback to legacy app_updates table
    try {
      final legacyRes = await SupaFlow.client
          .from('app_updates')
          .select('*')
          .eq('id', 1)
          .maybeSingle();

      if (legacyRes != null) {
        final isIos = cleanPlatform == 'ios';
        final bool isActive = isIos
            ? (legacyRes['ios_active'] == true)
            : (legacyRes['android_active'] == true);

        if (isActive) {
          final ver = isIos
              ? (legacyRes['ios_version']?.toString().trim() ?? '')
              : (legacyRes['android_version']?.toString().trim() ?? '');

          if (ver.isNotEmpty) {
            final desc = legacyRes['description']?.toString() ?? '';
            final rawFeatures = legacyRes['features'];
            List<String> feats = [];
            if (rawFeatures is List) feats = rawFeatures.map((e) => e.toString()).toList();

            return AppReleaseRecord(
              id: 'legacy_${cleanPlatform}_1',
              platform: cleanPlatform,
              version: ver,
              buildNumber: 0,
              releaseTitle: legacyRes['title']?.toString() ?? 'POKET Update Available',
              releaseNotes: desc,
              features: feats,
              isActiveProduction: true,
              isMandatory: legacyRes['is_mandatory'] == true,
              storeUrl: isIos ? (legacyRes['ios_link'] ?? defaultIosAppStoreUrl) : (legacyRes['android_link'] ?? defaultAndroidPlayStoreUrl),
              storeStatus: 'live',
              buildType: 'Production',
            );
          }
        }
      }
    } catch (_) {}

    return null;
  }

  // ---------------------------------------------------------------------------
  // 3. UPSERT RELEASE RECORD (Create or Edit)
  // ---------------------------------------------------------------------------
  static Future<void> saveReleaseRecord(AppReleaseRecord record) async {
    // 1. Sync to Supabase
    try {
      await SupaFlow.client.from('app_releases').upsert(
            record.toJson(),
            onConflict: 'platform,version,build_number',
          );
    } catch (e) {
      debugPrint('PocketReleaseService: Remote upsert error (will persist locally): $e');
    }

    // 2. Persist locally
    final all = await fetchAllReleases();
    final idx = all.indexWhere((r) =>
        r.id == record.id ||
        (r.platform == record.platform &&
            r.version == record.version &&
            r.buildNumber == record.buildNumber));

    if (idx >= 0) {
      all[idx] = record;
    } else {
      all.insert(0, record);
    }

    await saveReleasesLocally(all);
  }

  // ---------------------------------------------------------------------------
  // 4. SET AS ACTIVE PRODUCTION RELEASE (Explicit Admin Action)
  // ---------------------------------------------------------------------------
  static Future<void> setActiveProductionRelease(AppReleaseRecord targetRelease) async {
    final platform = targetRelease.platform.toLowerCase();
    final now = DateTime.now();

    // 1. Deactivate all existing releases for this platform in Supabase
    try {
      await SupaFlow.client
          .from('app_releases')
          .update({
            'is_active_production': false,
            'updated_at': now.toIso8601String(),
          })
          .eq('platform', platform);

      // 2. Activate the target release
      await SupaFlow.client.from('app_releases').update({
        'is_active_production': true,
        'store_status': 'live',
        'build_type': 'Production',
        'production_activated_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      }).eq('id', targetRelease.id);

      // 3. Also synchronize into legacy `app_updates` row id = 1 for backwards compatibility
      final isIos = platform == 'ios';
      final payload = <String, dynamic>{
        if (isIos) 'ios_version': targetRelease.version,
        if (!isIos) 'android_version': targetRelease.version,
        if (isIos) 'ios_active': true,
        if (!isIos) 'android_active': true,
        'title': targetRelease.releaseTitle,
        'description': targetRelease.releaseNotes,
        'features': targetRelease.features,
        'is_mandatory': targetRelease.isMandatory,
        if (isIos && targetRelease.storeUrl != null) 'ios_link': targetRelease.storeUrl,
        if (!isIos && targetRelease.storeUrl != null) 'android_link': targetRelease.storeUrl,
      };

      await SupaFlow.client.from('app_updates').update(payload).eq('id', 1);
    } catch (e) {
      debugPrint('PocketReleaseService: Error syncing active release to Supabase: $e');
    }

    // 4. Update local cache
    final updatedTarget = AppReleaseRecord(
      id: targetRelease.id,
      platform: targetRelease.platform,
      version: targetRelease.version,
      buildNumber: targetRelease.buildNumber,
      shorebirdReleaseId: targetRelease.shorebirdReleaseId,
      releaseTitle: targetRelease.releaseTitle,
      releaseNotes: targetRelease.releaseNotes,
      features: targetRelease.features,
      improvements: targetRelease.improvements,
      bugFixes: targetRelease.bugFixes,
      announcementMessage: targetRelease.announcementMessage,
      buildType: 'Production',
      storeStatus: 'live',
      isActiveProduction: true,
      productionActivatedAt: now,
      isMandatory: targetRelease.isMandatory,
      storeUrl: targetRelease.storeUrl,
      createdBy: targetRelease.createdBy,
      createdAt: targetRelease.createdAt,
      updatedAt: now,
    );

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = platform == 'ios' ? _kActiveIosReleaseKey : _kActiveAndroidReleaseKey;
    await prefs.setString(cacheKey, jsonEncode(updatedTarget.toJson()));

    // Update the local list
    final all = await fetchAllReleases();
    for (int i = 0; i < all.length; i++) {
      if (all[i].platform.toLowerCase() == platform) {
        if (all[i].id == targetRelease.id) {
          all[i] = updatedTarget;
        } else if (all[i].isActiveProduction) {
          all[i] = AppReleaseRecord(
            id: all[i].id,
            platform: all[i].platform,
            version: all[i].version,
            buildNumber: all[i].buildNumber,
            shorebirdReleaseId: all[i].shorebirdReleaseId,
            releaseTitle: all[i].releaseTitle,
            releaseNotes: all[i].releaseNotes,
            features: all[i].features,
            improvements: all[i].improvements,
            bugFixes: all[i].bugFixes,
            announcementMessage: all[i].announcementMessage,
            buildType: all[i].buildType,
            storeStatus: all[i].storeStatus,
            isActiveProduction: false,
            productionActivatedAt: all[i].productionActivatedAt,
            isMandatory: all[i].isMandatory,
            storeUrl: all[i].storeUrl,
            createdBy: all[i].createdBy,
            createdAt: all[i].createdAt,
            updatedAt: now,
          );
        }
      }
    }
    await saveReleasesLocally(all);

    // 5. Trigger Official President Broadcast Announcement (deduplicated per release ID)
    await _broadcastProductionReleaseAnnouncement(updatedTarget);
  }

  // ---------------------------------------------------------------------------
  // 5. DELETE RELEASE RECORD
  // ---------------------------------------------------------------------------
  static Future<bool> deleteReleaseRecord(String releaseId) async {
    final all = await fetchAllReleases();
    final target = all.firstWhere((r) => r.id == releaseId, orElse: () => throw Exception('Release not found'));

    if (target.isActiveProduction) {
      throw Exception('Cannot delete the currently active production release! Please deactivate or replace it first.');
    }

    try {
      await SupaFlow.client.from('app_releases').delete().eq('id', releaseId);
    } catch (e) {
      debugPrint('PocketReleaseService: Error deleting release from Supabase: $e');
    }

    all.removeWhere((r) => r.id == releaseId);
    await saveReleasesLocally(all);
    return true;
  }

  // ---------------------------------------------------------------------------
  // 6. DEDUPLICATED PRODUCTION ANNOUNCEMENT VIA PRESIDENT SERVICE
  // ---------------------------------------------------------------------------
  static Future<void> _broadcastProductionReleaseAnnouncement(AppReleaseRecord release) async {
    final prefs = await SharedPreferences.getInstance();
    final announcementKey = 'pres_release_announcement_dispatched_${release.platform}_${release.id}';

    // Prevent duplicate broadcasts if admin toggles or clicks save again
    if (prefs.getBool(announcementKey) == true) {
      debugPrint('PocketReleaseService: Announcement already dispatched for ${release.id}. Skipping duplicate.');
      return;
    }

    final platformName = release.platform.toLowerCase() == 'ios' ? 'iOS' : 'Android';
    final title = release.releaseTitle.isNotEmpty ? release.releaseTitle : 'POKET $platformName Update Available';

    final buffer = StringBuffer();
    buffer.writeln('A new official update is now available for all $platformName citizens!');
    buffer.writeln('Version: ${release.version} (Build ${release.buildNumber})');
    buffer.writeln();

    if (release.announcementMessage.trim().isNotEmpty) {
      buffer.writeln(release.announcementMessage.trim());
      buffer.writeln();
    } else if (release.releaseNotes.trim().isNotEmpty) {
      buffer.writeln(release.releaseNotes.trim());
      buffer.writeln();
    }

    if (release.features.isNotEmpty) {
      buffer.writeln('✨ Highlights:');
      for (int i = 0; i < release.features.length; i++) {
        buffer.writeln('${i + 1}. ${release.features[i]}');
      }
      buffer.writeln();
    }

    if (release.storeUrl != null && release.storeUrl!.isNotEmpty) {
      buffer.writeln('Update here: ${release.storeUrl}');
    }

    // Post to official Presidential Announcements channel
    await PocketPresidentService.broadcastAnnouncement(
      title: title,
      content: buffer.toString().trim(),
      priority: release.isMandatory ? 'urgent' : 'high',
    );

    await prefs.setBool(announcementKey, true);
    debugPrint('PocketReleaseService: Official production announcement successfully broadcast for ${release.id}.');
  }

  // ---------------------------------------------------------------------------
  // 7. SEMANTIC & BUILD NUMBER VERSION COMPARISON
  // ---------------------------------------------------------------------------
  /// Compares installed app against the active production release.
  /// Rule: Returns true ONLY if installed build is older than target production release.
  static bool isInstalledBuildOutdated({
    required String currentVersion,
    required int currentBuild,
    required String targetVersion,
    required int targetBuild,
  }) {
    if (targetVersion.isEmpty) return false;

    // 1. Authoritative: Compare build numbers when available
    if (targetBuild > 0 && currentBuild > 0) {
      return currentBuild < targetBuild;
    }

    // 2. Semantic version comparison (major.minor.patch)
    final currParts = currentVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final targetParts = targetVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLen = mathMax(currParts.length, targetParts.length);
    for (int i = 0; i < maxLen; i++) {
      final curr = (i < currParts.length) ? currParts[i] : 0;
      final target = (i < targetParts.length) ? targetParts[i] : 0;
      if (curr < target) return true;
      if (curr > target) return false;
    }

    return false;
  }

  static int mathMax(int a, int b) => a > b ? a : b;

  // ---------------------------------------------------------------------------
  // 8. REGISTER A NEW SHOREBIRD RELEASE AS TESTING BY DEFAULT
  // ---------------------------------------------------------------------------
  static Future<AppReleaseRecord> registerShorebirdRelease({
    required String platform,
    required String version,
    required int buildNumber,
    required String shorebirdReleaseId,
    String releaseTitle = '',
    String releaseNotes = '',
    List<String> features = const [],
    List<String> improvements = const [],
    List<String> bugFixes = const [],
  }) async {
    final cleanPlatform = platform.toLowerCase().trim();
    final title = releaseTitle.isNotEmpty
        ? releaseTitle
        : 'POKET $version+$buildNumber (Shorebird Release)';

    final newRecord = AppReleaseRecord(
      id: 'shorebird_${cleanPlatform}_${version.replaceAll('.', '_')}_$buildNumber',
      platform: cleanPlatform,
      version: version,
      buildNumber: buildNumber,
      shorebirdReleaseId: shorebirdReleaseId,
      releaseTitle: title,
      releaseNotes: releaseNotes,
      features: features,
      improvements: improvements,
      bugFixes: bugFixes,
      buildType: cleanPlatform == 'ios' ? 'TestFlight' : 'Testing',
      storeStatus: 'draft',
      isActiveProduction: false, // NEVER automatically activate as production
      isMandatory: false,
      createdBy: 'Shorebird CI/CD',
    );

    await saveReleaseRecord(newRecord);
    return newRecord;
  }

  // ---------------------------------------------------------------------------
  // HELPERS: Local Storage & Legacy Migration
  // ---------------------------------------------------------------------------
  static Future<void> saveReleasesLocally(List<AppReleaseRecord> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kLocalReleasesStoreKey,
      jsonEncode(list.map((r) => r.toJson()).toList()),
    );
  }

  static Future<List<AppReleaseRecord>> _synthesizeFromLegacyAppUpdates() async {
    try {
      final legacy = await SupaFlow.client
          .from('app_updates')
          .select('*')
          .eq('id', 1)
          .maybeSingle();

      if (legacy != null) {
        final List<AppReleaseRecord> list = [];
        final desc = legacy['description']?.toString() ?? '';
        final featsRaw = legacy['features'];
        List<String> feats = [];
        if (featsRaw is List) feats = featsRaw.map((e) => e.toString()).toList();

        // Android record
        final androidVer = legacy['android_version']?.toString().trim() ?? '1.0.155';
        list.add(AppReleaseRecord(
          id: 'android_legacy_1',
          platform: 'android',
          version: androidVer,
          buildNumber: 330,
          releaseTitle: legacy['title']?.toString() ?? 'POKET Android Update',
          releaseNotes: desc,
          features: feats,
          buildType: 'Production',
          storeStatus: 'live',
          isActiveProduction: legacy['android_active'] == true,
          storeUrl: legacy['android_link'] ?? defaultAndroidPlayStoreUrl,
          isMandatory: legacy['is_mandatory'] == true,
        ));

        // iOS record
        final iosVer = legacy['ios_version']?.toString().trim() ?? '1.0.155';
        list.add(AppReleaseRecord(
          id: 'ios_legacy_1',
          platform: 'ios',
          version: iosVer,
          buildNumber: 330,
          releaseTitle: legacy['title']?.toString() ?? 'POKET iOS Update',
          releaseNotes: desc,
          features: feats,
          buildType: 'Production',
          storeStatus: 'live',
          isActiveProduction: legacy['ios_active'] == true,
          storeUrl: legacy['ios_link'] ?? defaultIosAppStoreUrl,
          isMandatory: legacy['is_mandatory'] == true,
        ));

        return list;
      }
    } catch (_) {}

    return [];
  }
}

