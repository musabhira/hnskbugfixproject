import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

// State model for the market
@immutable
class MarketState {
  final List<String> categories;
  final Map<String, List<Map<String, dynamic>>> itemsByCategory;
  final Map<String, bool> isLoadingMore;
  final Map<String, bool> hasMore;
  final Map<String, int> currentPage;
  final bool isLoadingCategories;
  final String? error;

  const MarketState({
    this.categories = const ['All'],
    this.itemsByCategory = const {},
    this.isLoadingMore = const {},
    this.hasMore = const {},
    this.currentPage = const {},
    this.isLoadingCategories = false,
    this.error,
  });

  MarketState copyWith({
    List<String>? categories,
    Map<String, List<Map<String, dynamic>>>? itemsByCategory,
    Map<String, bool>? isLoadingMore,
    Map<String, bool>? hasMore,
    Map<String, int>? currentPage,
    bool? isLoadingCategories,
    String? error,
  }) {
    return MarketState(
      categories: categories ?? this.categories,
      itemsByCategory: itemsByCategory ?? this.itemsByCategory,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      error: error,
    );
  }
}

// Modern Notifier for the market logic
class MarketNotifier extends Notifier<MarketState> {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const int itemsPerPage = 20;

  @override
  MarketState build() {
    return const MarketState();
  }

  Future<void> initialize() async {
    if (state.categories.length > 1) return;
    await loadCategories();
    if (state.categories.isNotEmpty) {
      await loadItems(state.categories.first);
    }
  }

  Future<void> loadCategories() async {
    try {
      state = state.copyWith(isLoadingCategories: true);
      final user = _supabase.auth.currentUser;

      final response = await _supabase
          .from('gallery')
          .select('category')
          .not('category', 'is', null);
      final List<dynamic> data = response as List<dynamic>;

      final uniqueCategories = <String>{};
      for (var item in data) {
        if (item['category'] != null &&
            item['category'].toString().trim().isNotEmpty &&
            item['category'].toString().toLowerCase() != 'all') {
          uniqueCategories.add(item['category'].toString().trim());
        }
      }

      List<String> orderedCategories = ['All', ...uniqueCategories.toList()..sort()];

      if (user != null) {
        try {
          final userTrending = await _supabase.rpc(
              'get_user_trending_categories',
              params: {'p_user_id': user.id});
          if (userTrending != null &&
              userTrending is List &&
              userTrending.isNotEmpty) {
            final trending =
                userTrending.map((e) => e['category'].toString()).toList();
            List<String> prioritized = ['All'];
            for (var t in trending) {
              if (orderedCategories.contains(t) && t != 'All') {
                prioritized.add(t);
              }
            }
            for (var c in orderedCategories) {
              if (!prioritized.contains(c)) prioritized.add(c);
            }
            orderedCategories = prioritized;
          }
        } catch (e) {
          debugPrint('Error loading trending categories: $e');
        }
      }

      state = state.copyWith(
          categories: orderedCategories, isLoadingCategories: false);
    } catch (e) {
      state = state.copyWith(isLoadingCategories: false, error: e.toString());
    }
  }

  Future<void> loadItems(String category, {bool isRefresh = false}) async {
    final page = isRefresh ? 0 : (state.currentPage[category] ?? 0);
    if (!isRefresh &&
        (state.itemsByCategory[category]?.isNotEmpty ?? false) &&
        state.hasMore[category] == false) {
      return;
    }

    try {
      if (isRefresh) {
        final newItems =
            Map<String, List<Map<String, dynamic>>>.from(state.itemsByCategory);
        newItems[category] = [];
        state = state.copyWith(itemsByCategory: newItems);
      }

      var query = _supabase.from('gallery_with_comments_view').select();
      if (category != 'All') query = query.eq('gallery_category', category);

      final response = await query
          .order('gallery_created_at', ascending: false)
          .range(page * itemsPerPage, (page + 1) * itemsPerPage - 1);

      final List<Map<String, dynamic>> fetchedItems =
          List<Map<String, dynamic>>.from(response as List);
      final currentCategoryItems = isRefresh
          ? <Map<String, dynamic>>[]
          : (state.itemsByCategory[category] ?? []);
      final updatedItems = [...currentCategoryItems, ...fetchedItems];

      final Map<String, List<Map<String, dynamic>>> newItemsMap =
          Map.from(state.itemsByCategory);
      newItemsMap[category] = updatedItems;

      final Map<String, bool> newHasMoreMap = Map.from(state.hasMore);
      newHasMoreMap[category] = fetchedItems.length >= itemsPerPage;

      final Map<String, int> newPageMap = Map.from(state.currentPage);
      newPageMap[category] = page + 1;

      state = state.copyWith(
          itemsByCategory: newItemsMap,
          hasMore: newHasMoreMap,
          currentPage: newPageMap);
    } catch (e) {
      debugPrint('Error loading items for $category: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadMore(String category) async {
    if (state.isLoadingMore[category] == true ||
        state.hasMore[category] == false) {
      return;
    }

    final Map<String, bool> loadingMore = Map.from(state.isLoadingMore);
    loadingMore[category] = true;
    state = state.copyWith(isLoadingMore: loadingMore);

    await loadItems(category);

    final Map<String, bool> finishedLoadingMore = Map.from(state.isLoadingMore);
    finishedLoadingMore[category] = false;
    state = state.copyWith(isLoadingMore: finishedLoadingMore);
  }

  Future<void> saveSelectedInterests(List<String> interests) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // First, clear all existing interests for the user
      await _supabase.rpc('clear_user_interests', params: {
        'p_user_id': user.id,
      });

      // Then add the new interests
      for (String interest in interests) {
        await _supabase.rpc('update_trending_search', params: {
          'p_user_id': user.id,
          'p_category': interest,
        });
      }

      // Reset items and pages to ensure fresh data and correct order
      state = state.copyWith(
        itemsByCategory: {},
        currentPage: {},
        hasMore: {},
      );

      // Refresh categories after saving - this will trigger the prioritization logic
      await loadCategories();

      // Load items for the new first category (which should be one of the selected ones)
      if (state.categories.isNotEmpty) {
        await loadItems(state.categories.first, isRefresh: true);
      }
    } catch (e) {
      debugPrint('Error saving interests: $e');
    }
  }
}

final marketProvider = NotifierProvider<MarketNotifier, MarketState>(() {
  return MarketNotifier();
});

// Following State model
@immutable
class FollowingState {
  final List<Map<String, dynamic>> items;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? error;

  const FollowingState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 0,
    this.error,
  });

  FollowingState copyWith({
    List<Map<String, dynamic>>? items,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? error,
  }) {
    return FollowingState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
    );
  }
}

class FollowingNotifier extends Notifier<FollowingState> {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const int itemsPerPage = 20;

  @override
  FollowingState build() {
    return const FollowingState();
  }

  Future<void> loadFollowingItems({bool isRefresh = false}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    if (!isRefresh && !state.hasMore && state.items.isNotEmpty) return;

    try {
      if (isRefresh) {
        state =
            state.copyWith(isLoading: true, items: [], page: 0, hasMore: true);
      } else {
        state = state.copyWith(isLoading: true);
      }

      final followsResponse = await _supabase
          .from('follows')
          .select('followed_id')
          .eq('follower_id', user.id);
      final followingIds = (followsResponse as List)
          .map((e) => e['followed_id'].toString())
          .toList();

      if (followingIds.isEmpty) {
        state = state.copyWith(isLoading: false, hasMore: false);
        return;
      }

      final response = await _supabase
          .from('gallery_with_comments_view')
          .select()
          .inFilter('user_id', followingIds)
          .order('gallery_created_at', ascending: false)
          .range(
              state.page * itemsPerPage, (state.page + 1) * itemsPerPage - 1);

      final fetchedItems = List<Map<String, dynamic>>.from(response as List);
      state = state.copyWith(
          items: [...state.items, ...fetchedItems],
          isLoading: false,
          page: state.page + 1,
          hasMore: fetchedItems.length >= itemsPerPage);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final followingMarketProvider =
    NotifierProvider<FollowingNotifier, FollowingState>(() {
  return FollowingNotifier();
});
