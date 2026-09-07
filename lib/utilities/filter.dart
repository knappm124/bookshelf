import 'package:flutter/material.dart';
import 'book.dart';

/// An immutable snapshot of the inventory filters selected by the user.
class FilterCriteria {
  final Map<String, Set<String>> tagFilters;

  const FilterCriteria({this.tagFilters = const {}});

  bool get hasActiveFilters {
    return tagFilters.values.any((values) => values.isNotEmpty);
  }

  /// Returns items that match every active filter; tag options are alternatives within a tag.
  List<Book> apply(List<Book> books) {
    return books.where((book) {
      final matchTags = tagFilters.entries.every((entry) {
        final selectedOptions = entry.value;
        if (selectedOptions.isEmpty) return true;
        return selectedOptions.any(
          (option) => book.containsOption(entry.key, option),
        );
      });

      return matchTags;
    }).toList();
  }
}

/// Bottom-sheet editor that lets users build and apply [FilterCriteria].
class Filter extends StatefulWidget {
  final Collection c;
  final Bookshelf bookshelf;
  final ValueChanged<List<Book>> onFilterChanged;
  final ValueChanged<FilterCriteria> onCriteriaChanged;
  final FilterCriteria criteria;

  const Filter({
    super.key,
    required this.c,
    required this.bookshelf,
    required this.onFilterChanged,
    required this.onCriteriaChanged,
    required this.criteria,
  });

  @override
  State<StatefulWidget> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  late Collection c;
  late Bookshelf bookshelf;
  late List<Book> filtered;
  Map<String, Set<String>> tagFilters = {};

  @override
  void initState() {
    super.initState();
    c = widget.c;
    bookshelf = widget.bookshelf;
    tagFilters = widget.criteria.tagFilters.map(
      (key, value) => MapEntry(key, Set<String>.from(value)),
    );
    filtered = widget.criteria.apply(bookshelf.books);

    // Notify parent of initial filtered items
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCriteriaChanged(widget.criteria);
      widget.onFilterChanged(filtered);
    });
  }

  @override
  void didUpdateWidget(covariant Filter oldWidget) {
    super.didUpdateWidget(oldWidget);

    c = widget.c;

    final criteria = _buildCriteria();
    filtered = criteria.apply(bookshelf.books);
  }

  FilterCriteria _buildCriteria() {
    return FilterCriteria(tagFilters: tagFilters);
  }

  Widget _buildChipSection({
    required String title,
    required List<String> options,
    required Set<String> selected,
    required ValueChanged<Set<String>> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (options.isEmpty)
          Text(
            'No options available for this tag.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              return FilterChip(
                label: Text(option),
                showCheckmark: false,
                selected: selected.contains(option),
                onSelected: (isSelected) {
                  final updated = Set<String>.from(selected);
                  if (isSelected) {
                    updated.add(option);
                  } else {
                    updated.remove(option);
                  }
                  onChanged(updated);
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  void _filterList() {
    setState(() {
      final criteria = _buildCriteria();
      filtered = criteria.apply(bookshelf.books);
      widget.onCriteriaChanged(criteria);
      widget.onFilterChanged(filtered);
    });
  }

  void _resetFilters() {
    setState(() {
      tagFilters = {};
      final criteria = _buildCriteria();
      filtered = criteria.apply(bookshelf.books);
      widget.onCriteriaChanged(criteria);
      widget.onFilterChanged(filtered);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedTags = widget.c.tags.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasActiveFilters = _buildCriteria().hasActiveFilters;

    return Material(
      color: colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer.withValues(alpha: 0.95),
                  colorScheme.surfaceContainerHigh,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.85),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filters',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Narrow down your inventory list and focus on the items you need right now.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (hasActiveFilters)
                      TextButton.icon(
                        onPressed: _resetFilters,
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Reset'),
                      ),
                    if (hasActiveFilters) const SizedBox(height: 6),
                    IconButton.filledTonal(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      tooltip: 'Close filters',
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          for (final tag in sortedTags)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _FilterSectionCard(
                title: tag.name,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildChipSection(
                    title: 'Options',
                    options: (tag.options.toList()..sort()),
                    selected: tagFilters[tag.name] ?? {},
                    onChanged: (newValue) {
                      setState(() {
                        tagFilters = Map.from(tagFilters)
                          ..[tag.name] = newValue;
                      });
                      _filterList();
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterSectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterSectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
