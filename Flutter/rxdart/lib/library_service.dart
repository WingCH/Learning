import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

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
      print('_booksSubject: $value');
    });
    _borrowedBooksSubject.listen((value) {
      print('_borrowedBooksSubject: $value');
    });
  }

  factory LibraryService() => _instance;

  static final LibraryService _instance = LibraryService._internal();

  final _booksSubject = BehaviorSubject<List<Book>>.seeded([]);
  final _borrowedBooksSubject = BehaviorSubject<List<String>>.seeded([]);

  Stream<List<Book>> get stream => _booksSubject.stream;

  Stream<List<Tuple2<Book, bool>>> get borrowedBooksStream =>
      _booksSubject.stream.switchMap(
        (bookList) {
          return _borrowedBooksSubject.stream.flatMap(
            (booksId) {
              return Stream.value(
                bookList.map(
                  (book) {
                    return Tuple2<Book, bool>(book, booksId.contains(book.id));
                  },
                ).toList(),
              );
            },
          );
        },
      );

  Stream<bool?> getBookBorrowStatus({required String id}) {
    return borrowedBooksStream.flatMap<bool?>((value) {
      bool? isBorrowed =
          value.firstWhereOrNull((element) => element.item1.id == id)?.item2;
      return Stream<bool?>.value(isBorrowed);
    });
  }

  void setup() {
    Stream<List<Tuple2<Book, bool>>> a = _booksSubject.stream.switchMap(
      (bookList) {
        return _borrowedBooksSubject.stream.flatMap(
          (booksId) {
            return Stream.value(
              bookList.map(
                (book) {
                  return Tuple2<Book, bool>(book, booksId.contains(book.id));
                },
              ).toList(),
            );
          },
        );
      },
    );
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
  void checkIn({required String bookId}) {
    List<String> oldList = _borrowedBooksSubject.value.toList();
    oldList.add(bookId);
    _borrowedBooksSubject.value = oldList;
  }

  /// 還書
  void checkOut({required String bookId}) {
    List<String> oldList = _borrowedBooksSubject.value.toList();
    oldList.remove(bookId);
    _borrowedBooksSubject.value = oldList;
  }
}
