import 'package:uuid/uuid.dart';

class Collection {
  static final Uuid _uuid = Uuid();
  String _id;
  String _name;
  List<Book> _books;

  Collection({String? id, required this._name, List<Book>? books})
    : _id = id ?? Collection._uuid.v4(),
      _books = books ?? [];

  set name(String name) {
    _name = name;
  }

  set books(List<Book> books) {
    _books = books;
  }

  String get id => _id;
  String get name => _name;
  List<Book> get books => _books;

  void addBook(Book book) {
    _books.add(book);
  }

  void removeBook(Book book) {
    _books.remove(book);
  }

  void editBook(Book oldBook, Book newBook) {
    int index = _books.indexWhere((book) => book.id == oldBook.id);
    if (index != -1) {
      _books[index] = newBook;
    }
  }
}

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

  Book({
    String? id,
    required this._name,
    required this._author,
    List<String>? genres,
    int? isbn,
    String? img,
    int? rating,
    String? review,
    String? description,
  }) : _id = id ?? Book._uuid.v4(),
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

  String get id => _id;
  String get name => _name;
  String get author => _author;
  List<String> get genres => _genres;
  int get isbn => _isbn;
  String get img => _img;
  int get rating => _rating;
  String get review => _review;
  String get description => _description;
}
