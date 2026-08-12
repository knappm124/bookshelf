import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:convert';

import 'book.dart';
import 'image_utils.dart';

class AddBook extends StatefulWidget {
  const AddBook({super.key});

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

  @override
  Widget build(BuildContext context) {
    const double fieldSpacing = 12;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
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
                keyboardType: TextInputType.multiline, // Enables the 'Enter' key on the keyboard
                minLines: 1,                           // Minimum lines to show initially
                maxLines: null,    
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: fieldSpacing),
              Row(children: [
                IconButton(
                  icon: Icon(rating >= 1 ? Icons.star_rate : Icons.star_rate_outlined),
                  onPressed: () {
                    setState(() {
                      rating = 1;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(rating >= 2 ? Icons.star_rate : Icons.star_rate_outlined),
                  onPressed: () {
                    setState(() {
                      rating = 2;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(rating >= 3 ? Icons.star_rate : Icons.star_rate_outlined),
                  onPressed: () {
                    setState(() {
                      rating = 3;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(rating >= 4 ? Icons.star_rate : Icons.star_rate_outlined),
                  onPressed: () {
                    setState(() {
                      rating = 4;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(rating >= 5 ? Icons.star_rate : Icons.star_rate_outlined),
                  onPressed: () {
                    setState(() {
                      rating = 5;
                    });
                  },
                ),
              ],),
              const SizedBox(height: fieldSpacing),
              TextField(
                keyboardType: TextInputType.multiline, // Enables the 'Enter' key on the keyboard
                minLines: 1,                           // Minimum lines to show initially
                maxLines: null,    
                controller: _reviewController,
                decoration: const InputDecoration(labelText: 'Review'),
              ),
              const SizedBox(height: fieldSpacing),
              ElevatedButton(
                onPressed: () {
                  // Handle adding the book
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

                  // Create a new Book object and add it to your collection
                  Book newBook = Book(
                    name: name,
                    author: author,
                    img: img,
                    genres: genres,
                    review: review,
                    description: description,
                    rating: rating,
                  );
                  // Add the book to your data source here

                  // Clear the text fields after adding
                  _nameController.clear();
                  _authorController.clear();
                  _genresController.clear();
                  _reviewController.clear();
                  _descriptionController.clear();

                  // Optionally, show a confirmation message or navigate back
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
  Uint8List? _previewBytes;
  String _imagePaths = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imagePaths = widget.initialImagePaths;

    if (_imagePaths.startsWith('data:')) {
      final commaIndex = _imagePaths.indexOf(',');
      if (commaIndex != -1 && commaIndex + 1 < _imagePaths.length) {
        try {
          _previewBytes = base64Decode(_imagePaths.substring(commaIndex + 1));
        } catch (_) {
          _previewBytes = null;
        }
      }
    }
  }

  Future<void> _toggleCoverImage() async {
    if (_imagePaths.isNotEmpty) {
      setState(() {
        _imagePaths = '';
        _previewBytes = null;
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
        _previewBytes = imageBytes;
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
    final primaryPreview = _previewBytes;

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
                      child: primaryPreview != null && primaryPreview.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(21),
                              child: Image.memory(
                                primaryPreview,
                                fit: BoxFit.cover,
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
