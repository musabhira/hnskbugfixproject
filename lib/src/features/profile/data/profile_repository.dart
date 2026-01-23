import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/backend/supabase/supabase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'profile_repository.g.dart';

@riverpod
class ProfileRepository extends _$ProfileRepository {
  @override
  ProfileRepository build() => this;

  final _supabase = SupaFlow.client;

  Future<Map<String, dynamic>?> fetchUserProfile(String userId) async {
    final response = await _supabase
        .from('profile_gallery_service_likes_comments_view')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchUserServices(String userId) async {
    final response =
        await _supabase.from('service').select().eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchUserGallery(String userId) async {
    final response =
        await _supabase.from('gallery').select().eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchUserThreads(String userId) async {
    final response = await _supabase
        .from('thread_comments_view')
        .select()
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchThreadComments(
      String threadId) async {
    final response = await _supabase
        .from('thread_comments_view')
        .select()
        .eq('thread_id', threadId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> postThreadComment(
      String threadId, String userId, String content) async {
    await _supabase.from('thread_comments').insert({
      'thread_id': threadId,
      'user_id': userId,
      'content': content,
    });
  }

  Future<void> deleteThreadComment(String commentId) async {
    await _supabase.from('thread_comments').delete().eq('id', commentId);
  }

  Future<Map<String, dynamic>> checkBlockStatus(
      String myId, String otherId) async {
    final blockedByMe = await _supabase
        .from('blocks')
        .select('created_at')
        .eq('blocker_id', myId)
        .eq('blocked_id', otherId)
        .maybeSingle();

    final blockedByOther = await _supabase
        .from('blocks')
        .select('created_at')
        .eq('blocker_id', otherId)
        .eq('blocked_id', myId)
        .maybeSingle();

    return {
      'isBlocked': blockedByMe != null,
      'isBlockedByOther': blockedByOther != null,
      'blockTime': blockedByMe?['created_at'],
      'blockedByOtherTime': blockedByOther?['created_at'],
    };
  }

  Future<bool> checkFollowStatus(String myId, String otherId) async {
    final response = await _supabase
        .from('follows')
        .select()
        .eq('follower_id', myId)
        .eq('followed_id', otherId)
        .maybeSingle();
    return response != null;
  }

  Future<void> followUser(String myId, String otherId) async {
    await _supabase.from('follows').insert({
      'follower_id': myId,
      'followed_id': otherId,
    });
  }

  Future<void> unfollowUser(String myId, String otherId) async {
    await _supabase
        .from('follows')
        .delete()
        .eq('follower_id', myId)
        .eq('followed_id', otherId);
  }

  Future<Map<String, dynamic>?> fetchHideStatus(String userId) async {
    final response = await _supabase
        .from('hide')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return response;
  }

  Future<void> blockUser(String blockerId, String blockedId) async {
    await _supabase.rpc('block_user', params: {
      'target_user_id': blockedId,
    });
  }

  Future<void> unblockUser(String blockerId, String blockedId) async {
    await _supabase.rpc('unblock_user', params: {
      'target_user_id': blockedId,
    });
  }

  Future<Map<String, int>> fetchFollowCounts(String userId) async {
    final followersResponse =
        await _supabase.from('follows').select('id').eq('followed_id', userId);

    final followingResponse =
        await _supabase.from('follows').select('id').eq('follower_id', userId);

    final userResponse = await _supabase
        .from('users')
        .select('followers')
        .eq('id', userId)
        .maybeSingle();

    final int userTableFollowers = userResponse?['followers']?.toInt() ?? 0;

    return {
      'followers': followersResponse.length + userTableFollowers,
      'following': followingResponse.length,
    };
  }

  Future<List<dynamic>> fetchGalleriesWithSocialData(
      String currentUserId, String filterUserId) async {
    final response = await _supabase.rpc(
      'get_galleries_with_social_data',
      params: {
        'p_current_user_id': currentUserId,
        'p_filter_user_id': filterUserId,
      },
    );
    return response as List<dynamic>;
  }

  Future<int> fetchWatchSessionCoins(String userId) async {
    final session = await _supabase
        .from('watch_sessions')
        .select('total_coins_earned')
        .eq('user_id', userId)
        .eq('is_active', true)
        .maybeSingle();
    return session?['total_coins_earned'] ?? 0;
  }

  Future<void> deleteGalleryItem(String itemId, String? imageUrl) async {
    if (imageUrl != null) {
      final storagePathMatch =
          RegExp(r'gallery_photos/(.+)').firstMatch(imageUrl);
      if (storagePathMatch != null) {
        final storagePath = storagePathMatch.group(1);
        if (storagePath != null) {
          await _supabase.storage.from('gallery_photos').remove([storagePath]);
        }
      }
    }
    await _supabase.from('gallery').delete().match({'id': itemId});
  }

  Future<void> deleteServiceItem(String itemId) async {
    await _supabase.from('service').delete().match({'id': itemId});
  }

  Future<void> deleteThread(String threadId) async {
    await _supabase.from('threads').delete().eq('id', threadId);
  }

  Future<List<dynamic>> fetchGalleryShowcase(
      String userId, int offset, int limit) async {
    final response = await _supabase
        .from('gallery')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return response;
  }
}

@riverpod
FutureOr<Map<String, dynamic>?> userProfile(Ref ref, String userId) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.fetchUserProfile(userId);
}

@riverpod
FutureOr<List<Map<String, dynamic>>> userServices(Ref ref, String userId) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.fetchUserServices(userId);
}

@riverpod
FutureOr<List<Map<String, dynamic>>> userGallery(Ref ref, String userId) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.fetchUserGallery(userId);
}

@riverpod
FutureOr<List<Map<String, dynamic>>> userThreads(Ref ref, String userId) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.fetchUserThreads(userId);
}

@riverpod
FutureOr<Map<String, int>> followCounts(Ref ref, String userId) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.fetchFollowCounts(userId);
}

@riverpod
FutureOr<List<Map<String, dynamic>>> threadComments(Ref ref, String threadId) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.fetchThreadComments(threadId);
}
