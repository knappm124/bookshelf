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
                  content: Text('Delete "${i.name}" from your inventory?'),
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

  const BookRow({
    super.key,
    required this.i,
    required this.index,
    required this.collections,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Semantics(
        button: true,
        label:
            '${i.name}, author ${i.author},description ${i.description}, rating ${i.rating}, review ${i.review}',
        hint: 'Open item details',
        child: Material(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            canRequestFocus: true,
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.focused)) {
                return colorScheme.primary.withValues(alpha: 0.22);
              }
              if (states.contains(WidgetState.hovered)) {
                return colorScheme.primary.withValues(alpha: 0.08);
              }
              return null;
            }),
            onTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => EditableBook(
                    i: i,
                    collections: collections,
                  ),
                ),
              );
            },
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: colorScheme.outlineVariant),
                gradient: LinearGradient(
                  colors: [
                    colorScheme.surface,
                    colorScheme.surfaceContainerLowest,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 108,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primaryContainer.withValues(
                                  alpha: 0.72,
                                ),
                                colorScheme.surfaceContainerHigh,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: buildInventoryImage(
                              source: i.img ?? '',
                              width: 96,
                              height: 108,
                              fit: BoxFit.cover,
                              semanticLabel: '${i.name} item image',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      i.name,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      i.author,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: colorScheme.onSurface,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Rating: ${i.rating}',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Review: ${i.review}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Icon(
                            Icons.arrow_forward_rounded,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
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

class EditableBook extends StatefulWidget {
  final Book i;
  final Collection collections;

  const EditableBook({
    super.key,
    required this.i,
    required this.collections,
  });

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
    final images = _item.img;

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
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          runSpacing: 16,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 520),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _item.name,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w800),
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withValues(
                                  alpha: 0.72,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                images.length > 1
                                    ? '${images.length} photos saved'
                                    : 'Single photo view',
                                style: theme.textTheme.labelLarge,
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
                                    if (images.length > 1) ...[
                                      const SizedBox(height: 16),
                                      Text(
                                        'Gallery',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        height: 92,
                                        child: buildInventoryImage(
                                          source: _item.img,
                                          width: double.infinity,
                                          height: 92,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
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
        BookIcons(
          i: i,
          collections: collections,
          onBookUpdated: onBookUpdated,
        ),
      ],
    );
  }
}