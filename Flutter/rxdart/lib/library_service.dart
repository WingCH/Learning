import 'package:rxdart/rxdart.dart';

class Book {
  final String id;
  final String name;

  Book({required this.id, required this.name});

  @override
  String toString() {
    return 'Book('
        'id: $id, '
        'name: $name'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return other is Book && other.id == id && other.name == name;
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      name,
    );
  }
}

// https://flutter.cn/community/tutorials/singleton-pattern-in-flutter-n-dart
class LibraryService {
  LibraryService._internal() {
    _booksSubject.listen((value) {
      print('listen: $value');
    });
  }

  factory LibraryService() => _instance;

  static final LibraryService _instance = LibraryService._internal();

  final _booksSubject = BehaviorSubject<List<Book>>.seeded([]);

  Stream<List<Book>> get stream => _booksSubject.stream;

  void setup() {
    _booksSubject.value = [
      Book(
        id: "1",
        name: 'iOS 13 App程式設計實戰心法',
      ),
      Book(
        id: "2",
        name: 'Swift 進階',
      ),
      Book(
        id: "3",
        name: 'Getting Started with the BLoC Pattern',
      ),
      Book(
        id: "4",
        name: 'Parsing JSON in Flutter',
      ),
    ];
  }

  void addBook({required Book book}) {
    List<Book> oldList = _booksSubject.value.toList();
    oldList.add(book);
    _booksSubject.value = oldList;
  }

  /// 借書
  void checkIn({required String bookName}) {}

  /// 還書
  void checkOut({required Book bookName}) {}
}
