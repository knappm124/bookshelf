import 'package:uuid/uuid.dart';

class Collection {
  static final Uuid _uuid = Uuid();
  final String _id;
  String _name;
  List<Tag> _tags;
  List<Bookshelf> _bookshelf;

  Collection({
    String? id,
    required this._name,
    List<Bookshelf>? bookshelves,
    List<Tag>? tags,
  }) : _id = id ?? Collection._uuid.v4(),
       _bookshelf = bookshelves ?? [],
       _tags = tags ?? [];

  set name(String name) {
    _name = name;
  }

  set bookshelves(List<Bookshelf> bookshelves) {
    _bookshelf = bookshelves;
  }

  set tags(List<Tag> tags) {
    _tags = tags;
  }

  String get id => _id;
  String get name => _name;
  List<Bookshelf> get bookshelves => _bookshelf;
  List<Tag> get tags => _tags;

  List<String> getAllBookshelfNames() {
    return _bookshelf.map((bookshelf) => bookshelf.name).toList();
  }

  void addBookshelf(String name) {
    _bookshelf.add(Bookshelf(name: name));
  }

  void removeBookshelf(String name) {
    _bookshelf.removeWhere((bookshelf) => bookshelf.name == name);
  }

  void editBookshelf(String oldBookshelf, String newBookshelf) {
    final index = _bookshelf.indexWhere(
      (bookshelf) => bookshelf.name == oldBookshelf,
    );
    if (index != -1) {
      _bookshelf[index].name = newBookshelf;
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
    final tag = _tags.firstWhere(
      (tag) => tag.name == tagName,
      orElse: () => throw Exception('Tag not found'),
    );
    tag.addOption(option);
  }

  void removeTagOption(String tagName, String option) {
    final tag = _tags.firstWhere(
      (tag) => tag.name == tagName,
      orElse: () => throw Exception('Tag not found'),
    );
    tag.removeOption(option);
  }

  void renameTagOption(String tagName, String oldOption, String newOption) {
    final tag = _tags.firstWhere(
      (tag) => tag.name == tagName,
      orElse: () => throw Exception('Tag not found'),
    );
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
    final tag = _tags.firstWhere(
      (tag) => tag.name == tagName,
      orElse: () => throw Exception('Tag not found'),
    );
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
  Map<Tag, List<String>> _tags;

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
    Map<Tag, List<String>>? tags,
  }) : _id = id ?? Book._uuid.v4(),
       _isbn = isbn ?? '',
       _rating = rating ?? 0,
       _review = review ?? '',
       _img = img ?? '',
       _genres = genres ?? [],
       _description = description ?? '',
       _tags = tags ?? {};

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

  set tags(Map<Tag, List<String>> tags) {
    _tags = tags;
  }

  void addTag(Tag tag, List<String> options) {
    _tags[tag] = options;
  }
  
  void removeTag(String name) {
    _tags.removeWhere((tag, options) => tag.name == name);
  }

  bool containsOption(String tagName, String option) {
    final tag = _tags.keys.firstWhere(
      (t) => t.name == tagName,
      orElse: () => Tag(name: tagName),
    );
    final options = _tags[tag] ?? [];
    return options.contains(option);
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
  Map<Tag, List<String>> get tags => _tags;
}

class Bookshelf {
  static final Uuid _uuid = Uuid();
  final String _id;
  String _name;
  List<Book> _books;

  Bookshelf({String? id, required this._name, List<Book>? books})
    : _id = id ?? Bookshelf._uuid.v4(),
      _books = books ?? [];

  set name(String name) {
    _name = name;
  }

  set books(List<Book> books) {
    _books = books;
  }

  String get name => _name;
  String get id => _id;
  List<Book> get books => _books;

  void addBook(Book book) {
    _books.add(book);
  }

  void removeBook(Book book) {
    _books.removeWhere((b) => b.id == book.id);
  }

  void updateBook(Book book, Book updatedBook) {
    final index = _books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      _books[index] = updatedBook;
    }
  }
}
