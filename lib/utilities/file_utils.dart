import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'book.dart';

const String _collectionStorageKey = 'collection_json';

Collection collectionFromJson(String json) {
  Map<String, dynamic> collectionMap = jsonDecode(json);
  String collectionName = collectionMap['name'];
  String collectionId = collectionMap['id'];
  List<Book> books = [];
  if (collectionMap['books'] != null) {
    for (var bookMap in collectionMap['books']) {
      books.add(
        Book(
          id: bookMap['id'],
          name: bookMap['name'],
          author: bookMap['author'],
          genres: List<String>.from(bookMap['genres'] ?? []),
          isbn: bookMap['isbn'],
          img: bookMap['img'],
          rating: bookMap['rating'],
          review: bookMap['review'],
          description: bookMap['description'],
        ),
      );
    }
  }
  return Collection(id: collectionId, name: collectionName, books: books);
}

String collectionToJson(Collection collection) {
  Map<String, dynamic> collectionMap = {
    'id': collection.id,
    'name': collection.name,
    'books': collection.books
        .map(
          (book) => {
            'id': book.id,
            'name': book.name,
            'author': book.author,
            'genres': book.genres,
            'isbn': book.isbn,
            'img': book.img,
            'rating': book.rating,
            'review': book.review,
            'description': book.description,
          },
        )
        .toList(),
  };
  return jsonEncode(collectionMap);
}

Future<Collection?> loadCollectionFromStorage() async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString(_collectionStorageKey);
  if (json == null || json.isEmpty) {
    return null;
  }
  return collectionFromJson(json);
}

Future<void> saveCollectionToStorage(Collection collection) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_collectionStorageKey, collectionToJson(collection));
}
