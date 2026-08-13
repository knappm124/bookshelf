import 'package:http/http.dart' as http;
import 'dart:convert';

import '../secret.dart';
import 'book.dart';

class IsbnApi {
  String uri = 'https://www.googleapis.com/books/v1/volumes';

  Future<Book> fetchdata(String query) async {
    final queryParameters = {'q': 'isbn:$query', 'key': Secrets.apiKey};
    final url = Uri.parse(uri).replace(queryParameters: queryParameters);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String title = data['items'][0]['volumeInfo']['title'];
      String author = data['items'][0]['volumeInfo']['authors'][0];
      String description = data['items'][0]['volumeInfo']['description'];
      List<String> genres = data['items'][0]['volumeInfo']['categories'] != null
          ? List<String>.from(data['items'][0]['volumeInfo']['categories'])
          : [];
      String imgUrl = data['items'][0]['volumeInfo']['imageLinks'] != null
          ? data['items'][0]['volumeInfo']['imageLinks']['thumbnail']
          : 'https://via.placeholder.com/150';
      // Upgrade to https to avoid mixed-content/CORS fetch failures on web.
      imgUrl = imgUrl.replaceFirst('http://', 'https://');

      return Book(
        isbn: query,
        name: title,
        author: author,
        description: description,
        genres: genres,
        img: imgUrl,
      );
    } else {
      print('Failed with status: ${response.statusCode}');
      throw Exception('Failed to load book data');
    }
  }
}
