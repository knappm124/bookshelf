import 'package:flutter/material.dart';

import 'book.dart';

class Menu extends StatelessWidget {
  final List<Book> books;
  final Function(Book) onBookSelected;

  const Menu({super.key, required this.books, required this.onBookSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return ListTile(
            title: Text(book.name),
            onTap: () {
              onBookSelected(book);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}