import 'package:http/http.dart' as http;
import 'dart:convert';

import 'book.dart';

class IsbnApi {
  String uri = 'https://www.googleapis.com/books/v1/volumes';
  String apiKey = 'AIzaSyCAhY6FzYdSuZuZLl7vttdMv_p7TmK7pD8';

  Future<Book> fetchdata() async {
  
    final queryParameters = {
      'q': 'isbn:9781496755544',
      'key': apiKey,
    };
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
      return Book(isbn: 9781496755544, name: title, author: author, description: description, genres: genres, img: imgUrl);
    } else {
      print('Failed with status: ${response.statusCode}');
      throw Exception('Failed to load book data');
    }
  }
}
