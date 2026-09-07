import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local offline storage service for Pocket Vocabulary
/// Saves words directly on device SharedPreferences (zero Supabase bloat)
class PocketVocabularyService {
  static const String _kStorageKey = 'pocket_vocabulary_saved_words_v1';

  static final PocketVocabularyService instance = PocketVocabularyService._internal();
  PocketVocabularyService._internal();

  /// Save a batch of words (e.g. today's 10 words) into local pocket vocabulary
  Future<int> saveWords(int day, List<Map<String, dynamic>> words) async {
    final prefs = await SharedPreferences.getInstance();
    final existingJson = prefs.getString(_kStorageKey);
    List<dynamic> list = [];
    if (existingJson != null && existingJson.isNotEmpty) {
      try {
        list = jsonDecode(existingJson) as List<dynamic>;
      } catch (e) {
        debugPrint('Error decoding pocket vocabulary: $e');
        list = [];
      }
    }

    final existingWords = list.map((e) => (e['word'] ?? '').toString().toLowerCase()).toSet();
    int addedCount = 0;

    for (final w in words) {
      final wordKey = (w['word'] ?? '').toString().toLowerCase();
      if (wordKey.isNotEmpty && !existingWords.contains(wordKey)) {
        list.add({
          ...w,
          'day': day,
          'savedAt': DateTime.now().toIso8601String(),
        });
        existingWords.add(wordKey);
        addedCount++;
      }
    }

    await prefs.setString(_kStorageKey, jsonEncode(list));
    // Also mark day as saved
    await prefs.setBool('pocket_vocab_day_${day}_saved', true);
    return addedCount;
  }

  /// Check if words for this day have already been saved to Pocket Vocabulary
  Future<bool> isDaySaved(int day) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('pocket_vocab_day_${day}_saved') ?? false;
  }

  /// Get all saved vocabulary items from local storage
  Future<List<Map<String, dynamic>>> getSavedWords() async {
    final prefs = await SharedPreferences.getInstance();
    final existingJson = prefs.getString(_kStorageKey);
    if (existingJson == null || existingJson.isEmpty) return [];
    try {
      final list = jsonDecode(existingJson) as List<dynamic>;
      return list.cast<Map<String, dynamic>>().reversed.toList();
    } catch (e) {
      debugPrint('Error loading saved words: $e');
      return [];
    }
  }

  /// Remove a specific word from pocket vocabulary
  Future<void> removeWord(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final existingJson = prefs.getString(_kStorageKey);
    if (existingJson == null || existingJson.isEmpty) return;
    try {
      final list = jsonDecode(existingJson) as List<dynamic>;
      list.removeWhere((item) => (item['word'] ?? '').toString().toLowerCase() == word.toLowerCase());
      await prefs.setString(_kStorageKey, jsonEncode(list));
    } catch (e) {
      debugPrint('Error removing word: $e');
    }
  }

  /// Total count of saved words
  Future<int> getSavedCount() async {
    final words = await getSavedWords();
    return words.length;
  }
}
