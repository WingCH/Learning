import 'dart:ui';

import 'package:rxdart/rxdart.dart';

class Book {
  final String name;
  final Color color;

  Book({required this.name, required this.color});

  @override
  String toString() {
    return 'Book('
        'name: $name, '
        'color: $color'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return other is Book && other.name == name && other.color == color;
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      name,
      color,
    );
  }
}

// https://stackoverflow.com/a/12649574/5588637
class LibraryService {
  static final LibraryService _singleton = LibraryService._internal();

  factory LibraryService() {
    return _singleton;
  }

  LibraryService._internal();

  final _booksSubject = BehaviorSubject<List<Book>>.seeded([]);

  /// 借書
  void checkIn({required String bookName}) {}

  /// 還書
  void checkOut({required Book bookName}) {}
}
