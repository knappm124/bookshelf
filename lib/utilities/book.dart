import 'package:uuid/uuid.dart';

class Book {
  static final Uuid _uuid = Uuid();
  String _id;
  String _name;
  String _author;
  List<String> _genres;
  int _isbn;
  String _img;
  int _rating;
  String _review;
  String _description;

  Book({String? id, required this._name, required this._author, List<String>? genres,  int? isbn, String? img, int? rating, String? review, String? description})
      : _id = id ?? Book._uuid.v4(),
        _isbn = isbn ?? 0,
        _rating = rating ?? 0,
        _review = review ?? '',
        _img = img ?? '',
        _genres = genres ?? [],
        _description = description ?? '';

  set name(String name) {
    _name = name;
  }

  set author(String author) {
    _author = author;
  }

  set genres(List<String> genres) {
    _genres = genres;
  }

  set isbn(int isbn) {
    _isbn = isbn;
  }

  set img(String img) {
    _img = img;
  }

  set rating(int rating) {
    _rating = rating;
  }

  set review(String review) {
    _review = review;
  }

  set description(String description) {
    _description = description;
  }
}
