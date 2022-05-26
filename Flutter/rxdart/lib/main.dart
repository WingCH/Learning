import 'package:flutter/material.dart';

import 'library_service.dart';

void main() {
  LibraryService().setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DemoPage(),
    );
  }
}

class DemoPage extends StatelessWidget {
  DemoPage({Key? key}) : super(key: key);
  final libraryService = LibraryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SizedBox(
            height: 400,
            child: StreamBuilder<List<Book>>(
              stream: libraryService.stream,
              builder: (context, snapshot) {
                print('[book listview] StreamBuilder builder');
                return ListView.builder(
                  itemCount: snapshot.data?.length ?? 0,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (BuildContext context, int index) {
                    Book? book = snapshot.data?[index];
                    return _BookItem(
                      book: book!,
                    );
                  },
                );
              },
            ),
          ),
          TextButton(
            onPressed: () {
              libraryService.addBook(
                book: Book(
                  id: "4",
                  name: "説明書",
                ),
              );
            },
            child: const Text('Add book'),
          ),
        ],
      ),
    );
  }
}

class _BookItem extends StatelessWidget {
  const _BookItem({
    Key? key,
    required this.book,
  }) : super(key: key);

  final Book book;

  @override
  Widget build(BuildContext context) {
    final libraryService = LibraryService();
    return StreamBuilder<bool?>(
      stream: libraryService.getBookBorrowStatus(id: book.id).distinct(),
      builder: (context, snapshot) {
        print('[book item] StreamBuilder builder');
        bool isBorrowed = snapshot.data ?? false;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ListTile(
            onTap: () {
              if (isBorrowed) {
                libraryService.checkOut(bookId: book.id);
              } else {
                libraryService.checkIn(bookId: book.id);
              }
            },
            title: Text(book.name),
            trailing: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFe0f2f1),
              ),
              child: Icon(isBorrowed ? Icons.close : Icons.book),
            ),
          ),
        );
      },
    );
  }
}
