import 'dart:async';

import 'package:flutter/material.dart';

import 'editing.dart';
import 'book.dart';
import 'image_utils.dart';

class BookIcons extends StatelessWidget {
  final Book i;
  final Collection collections;
  final ValueChanged<Book> onBookUpdated;

  const BookIcons({
    super.key,
    required this.i,
    required this.collections,
    required this.onBookUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: () async {
            final updatedBook = await Navigator.of(context).push<Book?>(
              MaterialPageRoute(
                builder: (context) =>
                    EditingBook(i: i, collections: collections),
              ),
            );
            if (updatedBook != null) {
              onBookUpdated(updatedBook);
            }
          },
          tooltip: 'Edit item',
          icon: const Icon(Icons.edit_outlined),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: () async {
            final navigator = Navigator.of(context);
            final messenger = ScaffoldMessenger.of(context);
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Delete item?'),
                  content: Text('Delete "${i.name}" from your bookshelf?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );

            if (confirmed != true) {
              return;
            }

            collections.removeBook(i);
            messenger.showSnackBar(
              SnackBar(
                content: Text('Deleted "${i.name}"'),
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    collections.addBook(i);
                  },
                ),
              ),
            );
            navigator.pop();
          },
          tooltip: 'Delete item',
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}

class BookRow extends StatelessWidget {
  final Book i;
  final int index;
  final Collection collections;
  static const double _maxCoverDimension = 200;

  const BookRow({
    super.key,
    required this.i,
    required this.index,
    required this.collections,
  });

  Future<Size?> _resolveImageSize(String source) async {
    if (source.trim().isEmpty) {
      return null;
    }

    ImageProvider? provider;

    if (isDataImageUri(source)) {
      final bytes = decodeImageFromDataUri(source);
      if (bytes == null || bytes.isEmpty) {
        return null;
      }
      provider = MemoryImage(bytes);
    } else {
      final uri = Uri.tryParse(source);
      final isRemote =
          uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

      if (isRemote) {
        provider = NetworkImage(source);
      } else {
        return null;
      }
    }

    final completer = Completer<Size?>();
    final stream = provider.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;

    listener = ImageStreamListener(
      (ImageInfo imageInfo, bool synchronousCall) {
        stream.removeListener(listener);
        completer.complete(
          Size(
            imageInfo.image.width.toDouble(),
            imageInfo.image.height.toDouble(),
          ),
        );
      },
      onError: (Object error, StackTrace? stackTrace) {
        stream.removeListener(listener);
        completer.complete(null);
      },
    );

    stream.addListener(listener);
    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        stream.removeListener(listener);
        return null;
      },
    );
  }

  Size _boundedSize(Size sourceSize) {
    final scale = [
      _maxCoverDimension / sourceSize.width,
      _maxCoverDimension / sourceSize.height,
      1.0,
    ].reduce((a, b) => a < b ? a : b);

    return Size(sourceSize.width * scale, sourceSize.height * scale);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final defaultSize = const Size(96, 108);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Semantics(
          button: true,
          label: '${i.name}, by author ${i.author}',
          hint: 'Open item details',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () async {
                await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditableBook(i: i, collections: collections),
                  ),
                );
              },
              child: FutureBuilder<Size?>(
                future: _resolveImageSize(i.img),
                builder: (context, snapshot) {
                  final rawSize = snapshot.data ?? defaultSize;
                  final size = _boundedSize(rawSize);

                  return Container(
                    width: size.width,
                    height: size.height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: buildInventoryImage(
                        source: i.img,
                        width: size.width,
                        height: size.height,
                        fit: BoxFit.contain,
                        semanticLabel: '${i.name} item image',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EditableBook extends StatefulWidget {
  final Book i;
  final Collection collections;

  const EditableBook({super.key, required this.i, required this.collections});

  @override
  State<EditableBook> createState() => _EditableBookState();
}

class _EditableBookState extends State<EditableBook> {
  late Book _item;

  @override
  void initState() {
    super.initState();
    _item = widget.i;
  }

  void _handleBookUpdated(Book updatedBook) {
    setState(() {
      _item = updatedBook;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Book Details')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 760;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: FocusTraversalGroup(
                  policy: OrderedTraversalPolicy(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primaryContainer.withValues(
                                alpha: 0.95,
                              ),
                              colorScheme.surfaceContainerHigh,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.85,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _item.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _item.author,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Flex(
                        direction: isWide ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(1),
                            child: Expanded(
                              flex: isWide ? 2 : 0,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: colorScheme.outlineVariant,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.shadow.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 18,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        gradient: LinearGradient(
                                          colors: [
                                            colorScheme.primaryContainer
                                                .withValues(alpha: 0.5),
                                            colorScheme.surfaceContainerHigh,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Center(
                                        child: buildInventoryImage(
                                          source: _item.img,
                                          width: isWide ? 400 : 300,
                                          height: 280,
                                          fit: BoxFit.contain,
                                          semanticLabel:
                                              '${_item.name} selected image',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: isWide ? 16 : 0,
                            height: isWide ? 0 : 16,
                          ),
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(2),
                            child: Expanded(
                              flex: isWide ? 1 : 0,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                                child: EditableBookHeader(
                                  i: _item,
                                  collections: widget.collections,
                                  onBookUpdated: _handleBookUpdated,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EditableBookHeader extends StatelessWidget {
  final Book i;
  final Collection collections;
  final ValueChanged<Book> onBookUpdated;

  const EditableBookHeader({
    super.key,
    required this.i,
    required this.collections,
    required this.onBookUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BookIcons(i: i, collections: collections, onBookUpdated: onBookUpdated),
      ],
    );
  }
}
