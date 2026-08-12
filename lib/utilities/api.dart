import 'package:http/http.dart' as http;
import 'dart:convert';

class IsbnApi {
  Future<void> fetchdata() async {
    final uri = 'https://openlibrary.org/search.json';
    final queryParameters = {
      'isbn': '9781496755544', // Replace with the desired ISBN
    };
    final url = Uri.parse(uri).replace(queryParameters: queryParameters);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Title: ${data['docs'][0]['title']}');
    } else {
      print('Failed with status: ${response.statusCode}');
    }
  }
}
