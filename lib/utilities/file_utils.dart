import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; 
import 'package:http/http.dart' as http;

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

Future<File?> saveNetworkImage(String imageUrl) async {
  try {
    // 1. Download image bytes
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to load image');
    }

    // 2. Get secure internal directory
    final directory = await getApplicationDocumentsDirectory();
    
    // 3. Create unique file name
    final String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${directory.path}/$fileName');

    // 4. Save bytes to file
    await file.writeAsBytes(response.bodyBytes);
    
    debugPrint('Image saved to: ${file.path}');
    return file;
    
  } catch (e) {
    debugPrint('Error saving image: $e');
    return null;
  }
}