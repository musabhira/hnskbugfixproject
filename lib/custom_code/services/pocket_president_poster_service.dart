import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_president_service.dart';

/// 🏛️ Model for President Educational Posters & Marketing Cards
class PresidentEducationalPoster {
  final String id;
  final String title;
  final String imageUrl;
  final String language; // 'ml' (Malayalam), 'ta' (Tamil), 'kn' (Kannada), 'hi' (Hindi), 'all' (Global/English)
  final String aspectRatio; // 'story_9x16', 'feed_1x1', 'portrait_4x5'
  final DateTime createdAt;
  final int viewCount;
  final bool isActive;
  final String? subtitle;
  final String category; // 'Vocabulary', 'Phrases', 'Grammar', 'Citadel', 'General'

  const PresidentEducationalPoster({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.language = 'ml',
    this.aspectRatio = 'story_9x16',
    required this.createdAt,
    this.viewCount = 0,
    this.isActive = true,
    this.subtitle,
    this.category = 'Vocabulary',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image_url': imageUrl,
        'language': language,
        'aspect_ratio': aspectRatio,
        'created_at': createdAt.toIso8601String(),
        'view_count': viewCount,
        'is_active': isActive,
        'subtitle': subtitle,
        'category': category,
      };

  factory PresidentEducationalPoster.fromJson(Map<String, dynamic> json) {
    return PresidentEducationalPoster(
      id: json['id']?.toString() ?? 'poster_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? 'Daily English Vocabulary',
      imageUrl: json['image_url']?.toString() ?? '',
      language: (json['language']?.toString().toLowerCase()) ?? 'ml',
      aspectRatio: json['aspect_ratio']?.toString() ?? 'story_9x16',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] != false,
      subtitle: json['subtitle']?.toString(),
      category: json['category']?.toString() ?? 'Vocabulary',
    );
  }

  String get languageDisplayName {
    switch (language.toLowerCase()) {
      case 'ml':
        return '🌴 Malayalam (മലയാളം)';
      case 'ta':
        return '🦚 Tamil (தமிழ்)';
      case 'kn':
        return '🌸 Kannada (ಕನ್ನಡ)';
      case 'hi':
        return '🪷 Hindi (हिन्दी)';
      case 'all':
      default:
        return '🌐 All Languages (Global)';
    }
  }
}

/// 🏛️ Official Presidential Poster & Educational Content Broadcast Service
/// Manages the "Presidential Store / Vault" in the Admin Desk, distributing
/// high-converting educational cards into:
/// 1. President Vibes (Stories)
/// 2. Direct Citizen Chats (1-on-1 Messages)
/// 3. Home Feed Reels (Injected cards every 5-6 reels)
/// 4. Strict Channel-based Seen Tracking (ensures users NEVER see duplicate cards in Homes or Vibes)
class PocketPresidentPosterService {
  static const String _kPostersKey = 'president_educational_posters_v2';
  static const String _kSeenHomesPrefix = 'pres_seen_homes_';
  static const String _kSeenVibesPrefix = 'pres_seen_vibes_';
  static const String _kSeenChatPrefix = 'pres_seen_chat_';
  static const String _kSeenGeneralPrefix = 'president_seen_posters_';

  // In-memory cache of posters
  static List<PresidentEducationalPoster>? _cachedPosters;

  /// Default Seed Posters matching user reference designs (Daily Vocabulary & Community)
  static final List<PresidentEducationalPoster> _seedPosters = [
    PresidentEducationalPoster(
      id: 'pres_poster_who_ml_1',
      title: 'Daily English Vocabulary: Phrases with WHO',
      subtitle: 'English - Malayalam • Phrases with \'WHO\'',
      imageUrl: 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=800&auto=format&fit=crop&q=80',
      language: 'ml',
      aspectRatio: 'feed_1x1',
      category: 'Vocabulary',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      viewCount: 142,
    ),
    PresidentEducationalPoster(
      id: 'pres_poster_meet_all_2',
      title: 'Speak English. Meet Your POKETMates.',
      subtitle: 'Chat. Connect. Practise English Every Day.',
      imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&auto=format&fit=crop&q=80',
      language: 'all',
      aspectRatio: 'story_9x16',
      category: 'Phrases',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      viewCount: 230,
    ),
    PresidentEducationalPoster(
      id: 'pres_poster_battle_all_3',
      title: 'Learn. Build. Battle. Grow your home.',
      subtitle: 'Defend your Citadel. Speak English with courage.',
      imageUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800&auto=format&fit=crop&q=80',
      language: 'all',
      aspectRatio: 'story_9x16',
      category: 'Citadel',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      viewCount: 310,
    ),
    PresidentEducationalPoster(
      id: 'pres_poster_who_ta_4',
      title: 'Daily English Vocabulary: Phrases with WHO',
      subtitle: 'English - Tamil • Phrases with \'WHO\'',
      imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=800&auto=format&fit=crop&q=80',
      language: 'ta',
      aspectRatio: 'feed_1x1',
      category: 'Vocabulary',
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      viewCount: 88,
    ),
    PresidentEducationalPoster(
      id: 'pres_poster_who_hi_5',
      title: 'Daily English Vocabulary: Phrases with WHO',
      subtitle: 'English - Hindi • Phrases with \'WHO\'',
      imageUrl: 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800&auto=format&fit=crop&q=80',
      language: 'hi',
      aspectRatio: 'feed_1x1',
      category: 'Vocabulary',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      viewCount: 115,
    ),
    PresidentEducationalPoster(
      id: 'pres_poster_who_kn_6',
      title: 'Daily English Vocabulary: Phrases with WHO',
      subtitle: 'English - Kannada • Phrases with \'WHO\'',
      imageUrl: 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=800&auto=format&fit=crop&q=80',
      language: 'kn',
      aspectRatio: 'feed_1x1',
      category: 'Vocabulary',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      viewCount: 64,
    ),
  ];

  /// Normalize native language string to short code ('ml', 'ta', 'kn', 'hi', 'all')
  static String normalizeLanguageCode(String? raw) {
    if (raw == null || raw.isEmpty) return 'all';
    final lower = raw.toLowerCase().trim();
    if (lower.contains('malayalam') || lower == 'ml') return 'ml';
    if (lower.contains('tamil') || lower == 'ta') return 'ta';
    if (lower.contains('kannada') || lower == 'kn') return 'kn';
    if (lower.contains('hindi') || lower == 'hi') return 'hi';
    return 'all';
  }

  /// Upload an image to Supabase Storage 'statuses' bucket and return its public URL
  static Future<String?> uploadPosterImageToSupabase({
    required File imageFile,
    required String title,
  }) async {
    try {
      final supabase = SupaFlow.client;
      final bytes = await imageFile.readAsBytes();
      final ext = imageFile.path.split('.').last.toLowerCase();
      final mime = (ext == 'png') ? 'image/png' : 'image/jpeg';
      final fileName = 'pres_store_${DateTime.now().millisecondsSinceEpoch}_${title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.$ext';

      // Upload binary to Supabase Storage
      await supabase.storage.from('statuses').uploadBinary(
        fileName,
        bytes,
        fileOptions: FileOptions(contentType: mime, upsert: true),
      );

      final publicUrl = supabase.storage.from('statuses').getPublicUrl(fileName);
      debugPrint('🏛️ President Store: Successfully uploaded poster image to Supabase: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('⚠️ President Store Supabase upload error: $e');
      return null;
    }
  }

  /// Get all posters with optional language filter
  static Future<List<PresidentEducationalPoster>> getAllPosters({
    String? languageFilter,
    String? categoryFilter,
  }) async {
    if (_cachedPosters == null) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPostersKey);
      if (raw != null && raw.isNotEmpty) {
        try {
          final List<dynamic> list = jsonDecode(raw);
          _cachedPosters = list.map((e) => PresidentEducationalPoster.fromJson(Map<String, dynamic>.from(e))).toList();
        } catch (_) {
          _cachedPosters = List.from(_seedPosters);
        }
      } else {
        _cachedPosters = List.from(_seedPosters);
        await prefs.setString(_kPostersKey, jsonEncode(_cachedPosters!.map((p) => p.toJson()).toList()));
      }
    }

    var result = (_cachedPosters ?? _seedPosters).where((p) => p.isActive).toList();

    if (languageFilter != null && languageFilter.isNotEmpty && languageFilter.toLowerCase() != 'all') {
      final code = normalizeLanguageCode(languageFilter);
      result = result.where((p) => p.language == code || p.language == 'all').toList();
    }

    if (categoryFilter != null && categoryFilter.isNotEmpty && categoryFilter.toLowerCase() != 'all') {
      result = result.where((p) => p.category.toLowerCase() == categoryFilter.toLowerCase()).toList();
    }

    return result;
  }

  /// Add a new poster into the Presidential Store / Vault
  static Future<void> addPoster(PresidentEducationalPoster poster) async {
    final list = await getAllPosters();
    final updated = [poster, ...list];
    _cachedPosters = updated;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPostersKey, jsonEncode(updated.map((p) => p.toJson()).toList()));

    // Sync to Supabase reports for multi-device sync
    try {
      final supabase = SupaFlow.client;
      await supabase.from('reports').insert({
        'content_type': 'president_educational_poster',
        'content_id': poster.id,
        'report_type': 'other',
        'description': poster.title,
        'additional_info': jsonEncode(poster.toJson()),
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  /// Delete a poster by ID
  static Future<void> deletePoster(String posterId) async {
    final list = await getAllPosters();
    final updated = list.where((p) => p.id != posterId).toList();
    _cachedPosters = updated;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPostersKey, jsonEncode(updated.map((p) => p.toJson()).toList()));
  }

  // =========================================================================
  // 👁️ CHANNEL-SPECIFIC SEEN TRACKING (Never repeat seen posters)
  // =========================================================================

  /// Mark seen in Homes Feed
  static Future<void> markPosterSeenInHomes(String userId, String posterId) async {
    if (userId.isEmpty || posterId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_kSeenHomesPrefix$userId';
      final seenList = prefs.getStringList(key) ?? [];
      if (!seenList.contains(posterId)) {
        seenList.add(posterId);
        await prefs.setStringList(key, seenList);
      }
      await markPosterSeen(userId, posterId);
    } catch (e) {
      debugPrint('Error marking poster seen in homes: $e');
    }
  }

  /// Mark seen in Vibes (Stories)
  static Future<void> markPosterSeenInVibes(String userId, String posterId) async {
    if (userId.isEmpty || posterId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_kSeenVibesPrefix$userId';
      final seenList = prefs.getStringList(key) ?? [];
      if (!seenList.contains(posterId)) {
        seenList.add(posterId);
        await prefs.setStringList(key, seenList);
      }
      await markPosterSeen(userId, posterId);
    } catch (e) {
      debugPrint('Error marking poster seen in vibes: $e');
    }
  }

  /// Mark seen in 1-on-1 Chat
  static Future<void> markPosterSeenInChat(String userId, String posterId) async {
    if (userId.isEmpty || posterId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_kSeenChatPrefix$userId';
      final seenList = prefs.getStringList(key) ?? [];
      if (!seenList.contains(posterId)) {
        seenList.add(posterId);
        await prefs.setStringList(key, seenList);
      }
      await markPosterSeen(userId, posterId);
    } catch (e) {
      debugPrint('Error marking poster seen in chat: $e');
    }
  }

  /// General seen tracking (backward compatibility)
  static Future<void> markPosterSeen(String userId, String posterId) async {
    if (userId.isEmpty || posterId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_kSeenGeneralPrefix$userId';
      final seenList = prefs.getStringList(key) ?? [];
      if (!seenList.contains(posterId)) {
        seenList.add(posterId);
        await prefs.setStringList(key, seenList);
      }
    } catch (e) {
      debugPrint('Error marking poster seen: $e');
    }
  }

  /// Get seen list for debugging / testing
  static Future<List<String>> getSeenPosterIds(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('$_kSeenGeneralPrefix$userId') ?? [];
    } catch (_) {
      return [];
    }
  }

  /// Retrieve the next UNSEEN poster specifically for Homes Feed.
  /// If the user has seen all posters in Homes, returns NULL so no duplicate poster is shown!
  static Future<PresidentEducationalPoster?> getNextUnseenPosterForHomes({
    required String userId,
    String? language,
  }) async {
    final langCode = normalizeLanguageCode(language ?? PocketLanguageService.currentLanguage);
    final posters = await getAllPosters(languageFilter: langCode);
    if (posters.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final seenIds = prefs.getStringList('$_kSeenHomesPrefix$userId') ?? [];

    final unseen = posters.where((p) => !seenIds.contains(p.id)).toList();
    if (unseen.isNotEmpty) {
      return unseen.first;
    }
    // All seen! Per user request: do NOT repeat already seen items in Homes feed
    return null;
  }

  /// Synchronous retrieval for instant initial feed build
  static PresidentEducationalPoster? getNextUnseenPosterSync({
    required String userId,
    String? language,
  }) {
    final langCode = normalizeLanguageCode(language ?? PocketLanguageService.currentLanguage);
    final all = _cachedPosters ?? _seedPosters;
    final filtered = all.where((p) => p.isActive && (p.language == langCode || p.language == 'all')).toList();
    if (filtered.isEmpty) return all.isNotEmpty ? all.first : null;
    return filtered.first;
  }

  /// Retrieve the next UNSEEN poster specifically for Vibes.
  /// If all seen, returns null so vibes are never repetitive!
  static Future<PresidentEducationalPoster?> getNextUnseenPosterForVibes({
    required String userId,
    String? language,
  }) async {
    final langCode = normalizeLanguageCode(language ?? PocketLanguageService.currentLanguage);
    final posters = await getAllPosters(languageFilter: langCode);
    if (posters.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final seenIds = prefs.getStringList('$_kSeenVibesPrefix$userId') ?? [];

    final unseen = posters.where((p) => !seenIds.contains(p.id)).toList();
    if (unseen.isNotEmpty) {
      return unseen.first;
    }
    return null;
  }

  /// Retrieve the next UNSEEN poster for 1-on-1 Chat
  static Future<PresidentEducationalPoster?> getNextUnseenPosterForChat({
    required String userId,
    String? language,
  }) async {
    final langCode = normalizeLanguageCode(language ?? PocketLanguageService.currentLanguage);
    final posters = await getAllPosters(languageFilter: langCode);
    if (posters.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final seenIds = prefs.getStringList('$_kSeenChatPrefix$userId') ?? [];

    final unseen = posters.where((p) => !seenIds.contains(p.id)).toList();
    if (unseen.isNotEmpty) {
      return unseen.first;
    }
    return null;
  }

  /// 🌟 Broadcast a poster as an official President Vibe (Story)
  static Future<void> publishPosterAsPresidentVibe(PresidentEducationalPoster poster) async {
    final caption = '🏛️ ${poster.title}\n\n${poster.subtitle ?? 'Speak English Every Day with PoketMates!'} 🌟';
    await PocketPresidentService.postPresidentVibe(
      caption: caption,
      mediaUrl: poster.imageUrl,
      mediaType: 'image',
      duration: 15,
    );
  }

  /// 💬 Send an educational poster directly into a citizen's 1-on-1 President Chat
  static Future<void> sendPosterToCitizenChat({
    required String targetUserId,
    required PresidentEducationalPoster poster,
    String? customNote,
  }) async {
    final text = customNote ??
        'Thank you for learning with us, dear friend! 💛 Here is your special learning card from the Presidential Desk:\n\n✨ ${poster.title}\n${poster.subtitle ?? ''}\n\nKeep speaking with courage every day!';
    await PocketPresidentService.sendPresidentReplyToUser(
      targetUserId: targetUserId,
      replyText: text,
      messageType: 'image',
      fileUrl: poster.imageUrl,
      adminName: 'Presidential Desk',
    );
    await markPosterSeenInChat(targetUserId, poster.id);
  }

  /// 📢 One-Click Broadcast to ALL registered citizens in Pocket World
  static Future<int> broadcastPosterToAllCitizens({
    required PresidentEducationalPoster poster,
    String? customNote,
  }) async {
    try {
      final supabase = SupaFlow.client;
      // Fetch users from profiles / users table
      final response = await supabase.from('users').select('id, display_name').limit(200);
      int count = 0;
      if (response is List) {
        for (final row in response) {
          final uid = row['id']?.toString();
          if (uid != null && uid.isNotEmpty && uid != PocketPresidentService.presidentId) {
            await sendPosterToCitizenChat(
              targetUserId: uid,
              poster: poster,
              customNote: customNote,
            );
            count++;
          }
        }
      }
      return count;
    } catch (e) {
      debugPrint('⚠️ Error broadcasting poster to all citizens: $e');
      return 0;
    }
  }

  /// ⏰ Automatic Daily Educational Card delivery for a user
  /// Sends 1 unseen poster per day into user's 1-on-1 President chat.
  static Future<bool> deliverDailyEducationalPosterToCitizen(String userId) async {
    if (userId.isEmpty) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final dateKey = 'pres_daily_poster_sent_${userId}_${now.year}_${now.month}_${now.day}';
      if (prefs.getBool(dateKey) == true) {
        return false; // Already sent today!
      }

      final poster = await getNextUnseenPosterForChat(userId: userId);
      if (poster == null) return false; // No unseen posters left

      await sendPosterToCitizenChat(
        targetUserId: userId,
        poster: poster,
      );
      await prefs.setBool(dateKey, true);
      return true;
    } catch (e) {
      debugPrint('Error delivering daily educational poster: $e');
      return false;
    }
  }
}
