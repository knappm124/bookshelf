import 'package:uuid/uuid.dart';

class Collection {
  static final Uuid _uuid = Uuid();
  final String _id;
  String _name;
  List<Tag> _tags;
  List<Book> _books;

  Collection({
    String? id,
    required this._name,
    List<Book>? books,
    List<Tag>? tags,
  }) : _id = id ?? Collection._uuid.v4(),
       _books = books ?? [],
       _tags = tags ?? [];

  set name(String name) {
    _name = name;
  }

  set books(List<Book> books) {
    _books = books;
  }

  set tags(List<Tag> tags) {
    _tags = tags;
  }

  String get id => _id;
  String get name => _name;
  List<Book> get books => _books;
  List<Tag> get tags => _tags;

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

  void addTag(String name) {
    _tags.add(Tag(name: name));
  }

  void removeTag(String name) {
    _tags.removeWhere((tag) => tag.name == name);
  }

  void editTag(Tag oldTag, Tag newTag) {
    int index = _tags.indexWhere((tag) => tag.id == oldTag.id);
    if (index != -1) {
      _tags[index] = newTag;
    }
  }
  List<String> getAllTagNames() {
    return _tags.map((tag) => tag.name).toList();
  }

  void addTagOption(String tagName, String option) {
    final tag = _tags.firstWhere((tag) => tag.name == tagName, orElse: () => throw Exception('Tag not found'));
    tag.addOption(option);
  }

  void removeTagOption(String tagName, String option) {
    final tag = _tags.firstWhere((tag) => tag.name == tagName, orElse: () => throw Exception('Tag not found'));
    tag.removeOption(option);
  }

  void renameTagOption(String tagName, String oldOption, String newOption) {
    final tag = _tags.firstWhere((tag) => tag.name == tagName, orElse: () => throw Exception('Tag not found'));
    final index = tag.options.indexOf(oldOption);
    if (index != -1) {
      tag.options[index] = newOption;
    }
  }

  void renameTag(String oldName, String newName) {
    final index = _tags.indexWhere((t) => t.name == oldName);
    if (index != -1) {
      _tags[index].name = newName;
    }
  }
  
  List<String> getTagOptions(String tagName) {
    final tag = _tags.firstWhere((tag) => tag.name == tagName, orElse: () => throw Exception('Tag not found'));
    return tag.options;
  }
}

class Tag {
  static final Uuid _uuid = Uuid();
  final String _id;
  String _name;
  List<String> _options;

  Tag({String? id, required this._name, List<String>? options})
      : _id = id ?? Tag._uuid.v4(),
        _options = options ?? [];

  set name(String name) {
    _name = name;
  }

  set options(List<String> options) {
    _options = options;
  }

  List<String> get options => _options;

  void addOption(String option) {
    _options.add(option);
  }

  void removeOption(String option) {
    _options.remove(option);
  }

  String get id => _id;
  String get name => _name;
}

class Book {
  static final Uuid _uuid = Uuid();
  final String _id;
  String _name;
  String _author;
  List<String> _genres;
  String _isbn;
  String _img;
  int _rating;
  String _review;
  String _description;

  Book({
    String? id,
    required this._name,
    required this._author,
    List<String>? genres,
    String? isbn,
    String? img,
    int? rating,
    String? review,
    String? description,
  }) : _id = id ?? Book._uuid.v4(),
       _isbn = isbn ?? '',
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

  set isbn(String isbn) {
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
  String get isbn => _isbn;
  String get img => _img;
  int get rating => _rating;
  String get review => _review;
  String get description => _description;
}
