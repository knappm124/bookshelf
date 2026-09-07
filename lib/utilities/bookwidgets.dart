import 'dart:async';

import 'package:flutter/material.dart';

import 'editing.dart';
import 'book.dart';
import 'image_utils.dart';

class BookIcons extends StatelessWidget {
  final Book i;
  final Bookshelf bookshelf;
  final Collection collections;
  final ValueChanged<Book> onBookUpdated;

  const BookIcons({
    super.key,
    required this.i,
    required this.bookshelf,
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
                    EditingBook(i: i, bookshelf: bookshelf, collections: collections),
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

            bookshelf.removeBook(i);
            messenger.showSnackBar(
              SnackBar(
                content: Text('Deleted "${i.name}"'),
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    bookshelf.addBook(i);
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
  final Bookshelf bookshelf;
  final Collection collections;
  static const double _maxCoverDimension = 150;

  const BookRow({
    super.key,
    required this.i,
    required this.index,
    required this.bookshelf,
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
    final defaultSize = const Size(96, 108);

    return Padding(
      padding: EdgeInsets.zero,
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
                        EditableBook(i: i, bookshelf: bookshelf, collections: collections),
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
  final Bookshelf bookshelf;
  final Collection collections;

  const EditableBook({super.key, required this.i, required this.bookshelf, required this.collections});

  @override
  State<EditableBook> createState() => _EditableBookState();
}

class _EditableBookState extends State<EditableBook> {
  late Book _item;
  late final Collection collections;

  @override
  void initState() {
    super.initState();
    _item = widget.i;
    collections = widget.collections;
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Description',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _item.description.isNotEmpty
                                      ? _item.description
                                      : 'No description available.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Genres: ${_item.genres.isNotEmpty ? _item.genres.join(', ') : 'No genres available.'}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      _item.rating > 0
                                          ? Icons.star_rate
                                          : Icons.star_rate_outlined,
                                    ),
                                    Icon(
                                      _item.rating > 1
                                          ? Icons.star_rate
                                          : Icons.star_rate_outlined,
                                    ),
                                    Icon(
                                      _item.rating > 2
                                          ? Icons.star_rate
                                          : Icons.star_rate_outlined,
                                    ),
                                    Icon(
                                      _item.rating > 3
                                          ? Icons.star_rate
                                          : Icons.star_rate_outlined,
                                    ),
                                    Icon(
                                      _item.rating > 4
                                          ? Icons.star_rate
                                          : Icons.star_rate_outlined,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _item.review.isNotEmpty
                                      ? 'Review: ${_item.review}'
                                      : 'No review available.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16, height: 16),
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
                                  bookshelf: widget.bookshelf,
                                  onBookUpdated: _handleBookUpdated,
                                  collections: collections,
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
  final Bookshelf bookshelf;
  final Collection collections;
  final ValueChanged<Book> onBookUpdated;

  const EditableBookHeader({
    super.key,
    required this.i,
    required this.bookshelf,
    required this.collections,
    required this.onBookUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BookIcons(i: i, bookshelf: bookshelf, onBookUpdated: onBookUpdated, collections: collections,),
      ],
    );
  }
}

class ListViewWidget extends StatelessWidget {
  final List<Book> books;
  final Bookshelf bookshelf;
  final Collection collections;
  final ValueChanged<Book> onBookUpdated;

  const ListViewWidget({
    super.key,
    required this.books,
    required this.bookshelf,
    required this.collections,
    required this.onBookUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () async {
                await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditableBook(i: book, bookshelf: bookshelf, collections: collections),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 64,
                        height: 82,
                        child: buildInventoryImage(
                          source: book.img,
                          width: 64,
                          height: 82,
                          fit: BoxFit.cover,
                          semanticLabel: '${book.name} item image',
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            book.author,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
