import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

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
            child: StreamBuilder<List<Tuple2<Book, bool>>>(
              stream: libraryService.borrowedBooksStream,
              builder: (context, snapshot) {
                print('[book listview]StreamBuilder builder');
                return ListView.builder(
                  itemCount: snapshot.data?.length ?? 0,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (BuildContext context, int index) {
                    Book? book = snapshot.data?[index].item1;
                    bool isBorrowed = snapshot.data?[index].item2 ?? false;
                    return _BookItem(
                      book: book!,
                      isBorrowed: isBorrowed,
                      onTap: () {
                        if (isBorrowed) {
                          libraryService.checkOut(bookId: book.id);
                        } else {
                          libraryService.checkIn(bookId: book.id);
                        }
                      },
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
    required this.isBorrowed,
    required this.onTap,
  }) : super(key: key);

  final Book book;
  final bool isBorrowed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListTile(
        onTap: onTap,
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
  }
}
