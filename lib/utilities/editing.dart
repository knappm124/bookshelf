import 'package:flutter/material.dart';
import 'addbook.dart';

import 'book.dart';

class EditingBook extends StatefulWidget {
  final Book i;
  final Collection collections;

  const EditingBook({super.key, required this.i, required this.collections});

  @override
  State<StatefulWidget> createState() => _EditingBookState();
}

class _EditingBookState extends State<EditingBook> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _genresController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;
  late String _imagePaths;
  static const double fieldSpacing = 12;

  EdgeInsets _contentPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.fromLTRB(
      12,
      12,
      12,
      12 + mediaQuery.padding.bottom + mediaQuery.viewInsets.bottom,
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers and fields from the passed-in item
    _nameController.text = widget.i.name;
    _authorController.text = widget.i.author;
    _descriptionController.text = widget.i.description;
    _reviewController.text = widget.i.review;
    _genresController.text = widget.i.genres.join(', ');
    _imagePaths = widget.i.img;
    _rating = widget.i.rating;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _genresController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _saveBook() {
    if (!mounted) {
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the highlighted fields.')),
      );
      return;
    }

    final name = _nameController.text.trim();
    final author = _authorController.text.trim();
    final description = _descriptionController.text.trim();
    final genres = _genresController.text.trim().split(',').map((s) => s.trim()).toList();
    final review = _reviewController.text.trim();

    final updatedBook = Book(
      name: name,
      author: author,
      genres: genres,
      description: description,
      review: review,
      img: _imagePaths,
      rating: _rating,
      isbn: widget.i.isbn,
    );

    widget.collections.editBook(widget.i,updatedBook);

    if (!mounted) return;
    Navigator.of(context).pop(updatedBook);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Book'),
        actions: [
          IconButton(
            onPressed: _saveBook,
            tooltip: 'Save item',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: const Icon(Icons.check),
          ),
          const SizedBox(width: 4),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: _contentPadding(context),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: fieldSpacing),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _rating >= 1
                                ? Icons.star_rate
                                : Icons.star_rate_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = 1;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            _rating >= 2
                                ? Icons.star_rate
                                : Icons.star_rate_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = 2;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            _rating >= 3
                                ? Icons.star_rate
                                : Icons.star_rate_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = 3;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            _rating >= 4
                                ? Icons.star_rate
                                : Icons.star_rate_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = 4;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            _rating >= 5
                                ? Icons.star_rate
                                : Icons.star_rate_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = 5;
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
