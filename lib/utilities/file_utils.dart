import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'book.dart';

const String _collectionStorageKey = 'collection_json';

Collection collectionFromJson(String json) {
  final Map<String, dynamic> collectionMap = jsonDecode(json);
  final String collectionName = collectionMap['name'] as String? ?? '';
  final String collectionId = collectionMap['id'] as String? ?? '';
  List<Bookshelf> bookshelves = [];
  final rawBookshelves = collectionMap['bookshelves'];
  if (rawBookshelves is List) {
    for (final rawBookshelf in rawBookshelves) {
      final bookshelfMap = rawBookshelf as Map<String, dynamic>;
      List<Book> shelfBooks = [];
      final rawShelfBooks = bookshelfMap['books'];
      if (rawShelfBooks is List) {
        for (final rawBook in rawShelfBooks) {
          final bookMap = rawBook as Map<String, dynamic>;
          shelfBooks.add(
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
      bookshelves.add(
        Bookshelf(
          id: bookshelfMap['id'] as String?,
          name: bookshelfMap['name'] as String? ?? '',
          books: shelfBooks,
        ),
      );
    }
  }
  final tags = <Tag>[];
  final rawTags = collectionMap['tags'];
  if (rawTags is List) {
    for (final rawTag in rawTags) {
      final tagMap = rawTag as Map<String, dynamic>;
      tags.add(
        Tag(
          id: tagMap['id'] as String?,
          name: tagMap['name'] as String? ?? '',
          options: List<String>.from(tagMap['options'] ?? []),
        ),
      );
    }
  }
  return Collection(
    id: collectionId,
    name: collectionName,
    bookshelves: bookshelves,
    tags: tags,
  );
}

String collectionToJson(Collection collection) {
  Map<String, dynamic> collectionMap = {
    'id': collection.id,
    'name': collection.name,
    'bookshelves': collection.bookshelves
        .map(
          (bookshelf) => {
            'id': bookshelf.id,
            'name': bookshelf.name,
            'books': bookshelf.books
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
          },
        )
        .toList(),
    'tags': collection.tags
        .map((tag) => {'id': tag.id, 'name': tag.name, 'options': tag.options})
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
