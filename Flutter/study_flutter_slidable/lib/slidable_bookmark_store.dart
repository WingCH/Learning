import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to store bookmark states
final bookmarkProvider = StateNotifierProvider<BookmarkStore, Set<int>>((ref) {
  return BookmarkStore();
});

// StateNotifier for managing bookmark states
class BookmarkStore extends StateNotifier<Set<int>> {
  BookmarkStore() : super({});

  // Check if an item is bookmarked
  bool isBookmarked(int index) {
    return state.contains(index);
  }

  // Toggle bookmark status for an item
  void toggleBookmark(int index) {
    if (state.contains(index)) {
      state = Set.from(state)..remove(index);
    } else {
      state = Set.from(state)..add(index);
    }
  }
} 