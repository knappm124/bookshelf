import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'book.dart';

const String _collectionStorageKey = 'collection_json';

Collection collectionFromJson(String json) {
  final Map<String, dynamic> collectionMap = jsonDecode(json);
  final String collectionName = collectionMap['name'] as String? ?? '';
  final String collectionId = collectionMap['id'] as String? ?? '';
  List<Book> books = [];
  final rawBooks = collectionMap['books'];
  if (rawBooks is List) {
    for (final rawBook in rawBooks) {
      final bookMap = rawBook as Map<String, dynamic>;
      books.add(
        Book(
          id: bookMap['id'] as String?,
          name: bookMap['name'] as String? ?? '',
          author: bookMap['author'] as String? ?? '',
          genres: List<String>.from(bookMap['genres'] ?? []),
          isbn: bookMap['isbn'] as String?,
          img: bookMap['img'] as String?,
          rating: bookMap['rating'] as int?,
          review: bookMap['review'] as String?,
          description: bookMap['description'] as String?,
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
