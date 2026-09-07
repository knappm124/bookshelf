import 'package:flutter/material.dart';
import 'addbook.dart';

import 'book.dart';

class EditingBook extends StatefulWidget {
  final Book i;
  final Bookshelf bookshelf;
  final Collection collections;

  const EditingBook({super.key, required this.i, required this.bookshelf, required this.collections});

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
  final Map<String, Set<String>> _selectedTagValues = {};
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

    // Copy existing tag selections from the item
    widget.i.tags.forEach((tag, values) {
      _selectedTagValues[tag.name] = Set<String>.from(values);
    });
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
    final genres = _genresController.text
        .trim()
        .split(',')
        .map((s) => s.trim())
        .toList();
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

    widget.bookshelf.updateBook(widget.i, updatedBook);

    if (!mounted) return;
    Navigator.of(context).pop(updatedBook);
  }

  @override
  Widget build(BuildContext context) {
    final sortedTags = widget.collections.tags.toList()
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
                                        if (tagRows.isNotEmpty) ...[
                            const Divider(height: 28),
                            EditorSectionBlock(
                              title: 'Tags',
                              subtitle:
                                  'Keep categorization up to date so filtering still works well.',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: tagRows,
                              ),
                            ),
                          ],
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

class EditorSectionBlock extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const EditorSectionBlock({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),)
        ],
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class EditorSummaryPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const EditorSummaryPill({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.labelLarge),
        ],
      ),
    );
  }
}

class TagSelectorRow extends StatelessWidget {
  final String tagName;
  final List<String> options;
  final Set<String> selectedValues;
  final ValueChanged<Set<String>> onSelectionChanged;

  const TagSelectorRow({
    super.key,
    required this.tagName,
    required this.options,
    required this.selectedValues,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tagName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = selectedValues.contains(option);
              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  final updatedSelection = Set<String>.from(selectedValues);
                  if (selected) {
                    updatedSelection.add(option);
                  } else {
                    updatedSelection.remove(option);
                  }
                  onSelectionChanged(updatedSelection);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}