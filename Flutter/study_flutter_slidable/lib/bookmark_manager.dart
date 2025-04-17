import 'package:flutter_riverpod/flutter_riverpod.dart';

// 定義一個保存書籤狀態的 Provider
final bookmarkProvider = StateNotifierProvider<BookmarkNotifier, Set<int>>((ref) {
  return BookmarkNotifier();
});

// StateNotifier 用於管理書籤狀態
class BookmarkNotifier extends StateNotifier<Set<int>> {
  BookmarkNotifier() : super({});

  bool isBookmarked(int index) {
    return state.contains(index);
  }

  void toggleBookmark(int index) {
    if (state.contains(index)) {
      state = Set.from(state)..remove(index);
    } else {
      state = Set.from(state)..add(index);
    }
  }
} 