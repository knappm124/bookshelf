import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

import 'book.dart';
import 'api.dart';
import 'file_utils.dart';
import 'image_utils.dart';
import 'editing.dart';

class AddBook extends StatefulWidget {
  final Collection collection;
  final Bookshelf bookshelf;

  const AddBook({super.key, required this.bookshelf, required this.collection});

  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  String _imagePaths = '';
  int rating = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _genresController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final Map<String, Set<String>> _selectedTagValues = {};

  Future<Book> _addBookAndPersist() async {
    String name = _nameController.text;
    String author = _authorController.text;
    String img = _imagePaths;
    List<String> genres = _genresController.text
        .split(',')
        .map((s) => s.trim())
        .toList();
    String review = _reviewController.text;
    int rating = this.rating;
    String description = _descriptionController.text;

    Book newBook = Book(
      name: name,
      author: author,
      img: img,
      genres: genres,
      review: review,
      description: description,
      rating: rating,
    );

    final i = widget.collection.bookshelves.indexWhere(
      (bookshelf2) => widget.bookshelf.id == bookshelf2.id,
    );
    if (i != -1) {
      widget.collection.bookshelves[i].addBook(newBook);
    } else {
      throw Exception('Bookshelf not found in the collection.');
    }
    await saveCollectionToStorage(widget.collection);

    return newBook;
  }

  @override
  Widget build(BuildContext context) {
    const double fieldSpacing = 12;
    final sortedTags = widget.collection.tags.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final tagRows = sortedTags.map((tag) {
      return TagSelectorRow(
        tagName: tag.name,
        options: (tag.options.toList())..sort(),
        selectedValues: _selectedTagValues[tag.name] ?? <String>{},
        onSelectionChanged: (newSelection) {
          setState(() {
            _selectedTagValues[tag.name] = newSelection;
          });
        },
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Book')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: fieldSpacing),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: fieldSpacing),
              TextField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Author'),
              ),
              const SizedBox(height: fieldSpacing),
              ElevatedButton(
                onPressed: () async {
                  final books = await ManualBookAPI().fetchdata(
                    _nameController.text,
                    _authorController.text,
                  );

                  if (!context.mounted) {
                    return;
                  }
                  final selectedBook = await showDialog<Book>(
                    context: context,
                    builder: (context) => PickBook(books: books),
                  );

                  if (selectedBook == null || !mounted) {
                    return;
                  }
                  setState(() {
                    _nameController.text = selectedBook.name;
                    _authorController.text = selectedBook.author;
                    _descriptionController.text = selectedBook.description;
                    _genresController.text = selectedBook.genres.join(", ");
                    _imagePaths = selectedBook.img;
                  });
                },
                child: const Text('Try to pull info from Google Books'),
              ),
              const SizedBox(height: fieldSpacing),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: ImageUploaderScreen(
                  initialImagePaths: _imagePaths,
                  useStandaloneChrome: false,
                  onImageChanged: (path) {
                    setState(() {
                      _imagePaths = path;
                    });
                  },
                ),
              ),
              const SizedBox(height: fieldSpacing),
              TextField(
                controller: _genresController,
                decoration: const InputDecoration(
                  labelText: 'Genres (comma separated)',
                ),
              ),
              const SizedBox(height: fieldSpacing),
              TextField(
                keyboardType: TextInputType
                    .multiline, // Enables the 'Enter' key on the keyboard
                minLines: 1, // Minimum lines to show initially
                maxLines: null,
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: fieldSpacing),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      rating >= 1 ? Icons.star_rate : Icons.star_rate_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        rating = 1;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      rating >= 2 ? Icons.star_rate : Icons.star_rate_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        rating = 2;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      rating >= 3 ? Icons.star_rate : Icons.star_rate_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        rating = 3;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      rating >= 4 ? Icons.star_rate : Icons.star_rate_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        rating = 4;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      rating >= 5 ? Icons.star_rate : Icons.star_rate_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        rating = 5;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: fieldSpacing),
              TextField(
                keyboardType: TextInputType
                    .multiline, // Enables the 'Enter' key on the keyboard
                minLines: 1, // Minimum lines to show initially
                maxLines: null,
                controller: _reviewController,
                decoration: const InputDecoration(labelText: 'Review'),
              ),
              const SizedBox(height: fieldSpacing),
              if (tagRows.isNotEmpty) ...[
                const Divider(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: EditorSectionBlock(
                    title: 'Tags',
                    subtitle:
                        'Keep categorization up to date so filtering still works well.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: tagRows,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: fieldSpacing),
              ElevatedButton(
                onPressed: () async {
                  final book = await _addBookAndPersist();
                  if (!mounted) {
                    return;
                  }
                  Navigator.of(this.context).pop(book);
                },
                child: const Text('Add Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageUploaderScreen extends StatefulWidget {
  final String initialImagePaths;
  final bool useStandaloneChrome;
  final ValueChanged<String>? onImageChanged;

  const ImageUploaderScreen({
    super.key,
    required this.initialImagePaths,
    this.useStandaloneChrome = true,
    this.onImageChanged,
  });

  @override
  State<ImageUploaderScreen> createState() => _ImageUploaderScreenState();
}

class _ImageUploaderScreenState extends State<ImageUploaderScreen> {
  String _imagePaths = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imagePaths = widget.initialImagePaths;
  }

  @override
  void didUpdateWidget(covariant ImageUploaderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImagePaths != oldWidget.initialImagePaths &&
        widget.initialImagePaths != _imagePaths) {
      setState(() {
        _imagePaths = widget.initialImagePaths;
      });
    }
  }

  Future<void> _toggleCoverImage() async {
    if (_imagePaths.isNotEmpty) {
      setState(() {
        _imagePaths = '';
      });
      widget.onImageChanged?.call('');
      return;
    }

    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      final imageBytes = await pickedFile.readAsBytes();
      if (imageBytes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selected image is empty.')),
          );
        }
        return;
      }

      final encodedImage = encodeImageToDataUri(
        imageBytes,
        mimeType: pickedFile.mimeType,
        path: pickedFile.path,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _imagePaths = encodedImage;
      });
      widget.onImageChanged?.call(_imagePaths);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasImages = _imagePaths.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final previewSize = (constraints.maxWidth - 48)
            .clamp(180, 320)
            .toDouble();

        return Padding(
          padding: EdgeInsets.all(widget.useStandaloneChrome ? 4 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: widget.useStandaloneChrome
                      ? LinearGradient(
                          colors: [
                            colorScheme.primaryContainer.withValues(alpha: 0.5),
                            colorScheme.surfaceContainerHigh,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                ),
                child: Column(
                  children: [
                    Container(
                      width: previewSize,
                      height: previewSize,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: hasImages
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(21),
                              child: buildInventoryImage(
                                source: _imagePaths,
                                width: previewSize,
                                height: previewSize,
                                placeholder: Icon(
                                  Icons.image_outlined,
                                  size: 72,
                                  color: colorScheme.outline,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.image_outlined,
                              size: 72,
                              color: colorScheme.outline,
                            ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _toggleCoverImage,
                      icon: Icon(
                        hasImages ? Icons.delete_outline : Icons.upload_file,
                      ),
                      label: Text(hasImages ? 'Remove Cover' : 'Add Cover'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BookResult extends StatelessWidget {
  final Book book;

  const BookResult({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        return Navigator.of(context).pop(book);
      },
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 72,
            child: buildInventoryImage(
              source: book.img,
              width: 48,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.name, overflow: TextOverflow.ellipsis),
                Text(book.author, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PickBook extends StatelessWidget {
  final List<Book> books;

  const PickBook({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: books.length,
          itemBuilder: (context, index) {
            return BookResult(book: books[index]);
          },
        ),
      ),
    );
  }
}
