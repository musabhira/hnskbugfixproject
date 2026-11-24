import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
/// 4. Seen Tracking (ensures each user sees fresh, unseen cards)
class PocketPresidentPosterService {
  static const String _kPostersKey = 'president_educational_posters_v1';
  static const String _kSeenPrefix = 'president_seen_posters_';

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

  /// Get all posters with optional language filter
  static Future<List<PresidentEducationalPoster>> getAllPosters({String? languageFilter}) async {
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

    final all = _cachedPosters ?? _seedPosters;
    if (languageFilter == null || languageFilter.isEmpty || languageFilter.toLowerCase() == 'all') {
      return all.where((p) => p.isActive).toList();
    }

    final code = normalizeLanguageCode(languageFilter);
    return all.where((p) => p.isActive && (p.language == code || p.language == 'all')).toList();
  }

  /// Add a new poster into the Presidential Store / Vault
  static Future<void> addPoster(PresidentEducationalPoster poster) async {
    final list = await getAllPosters();
    final updated = [poster, ...list];
    _cachedPosters = updated;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPostersKey, jsonEncode(updated.map((p) => p.toJson()).toList()));

    // Sync to Supabase reports or statuses for multi-device sync
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

  /// Mark that a citizen has viewed a specific poster
  static Future<void> markPosterSeen(String userId, String posterId) async {
    if (userId.isEmpty || posterId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_kSeenPrefix$userId';
      final seenList = prefs.getStringList(key) ?? [];
      if (!seenList.contains(posterId)) {
        seenList.add(posterId);
        await prefs.setStringList(key, seenList);
      }
    } catch (e) {
      debugPrint('Error marking poster seen: $e');
    }
  }

  /// Synchronous retrieval of a seed or cached educational poster for instant reels feed
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

  /// Retrieve the next unseen educational poster for a user in their native language
  static Future<PresidentEducationalPoster?> getNextUnseenPoster({
    required String userId,
    String? language,
  }) async {
    final langCode = normalizeLanguageCode(language ?? PocketLanguageService.currentLanguage);
    final posters = await getAllPosters(languageFilter: langCode);
    if (posters.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final key = '$_kSeenPrefix$userId';
    final seenIds = prefs.getStringList(key) ?? [];

    // Filter unseen
    final unseen = posters.where((p) => !seenIds.contains(p.id)).toList();
    if (unseen.isNotEmpty) {
      return unseen.first;
    }

    // If user has seen all available posters in this category, return random one so rotation continues!
    posters.shuffle();
    return posters.first;
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
        '🏛️ Official Presidential Learning Card:\n\n${poster.title}\n${poster.subtitle ?? ''}\n\nKeep practicing daily to build spoken confidence!';
    await PocketPresidentService.sendPresidentReplyToUser(
      targetUserId: targetUserId,
      replyText: text,
      messageType: 'image',
      fileUrl: poster.imageUrl,
      adminName: 'Presidential Desk',
    );
  }
}
