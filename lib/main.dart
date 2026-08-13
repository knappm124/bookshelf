import 'utilities/addbook.dart';
import 'utilities/book.dart';
import 'utilities/file_utils.dart';
import 'utilities/bookwidgets.dart';

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0E7490),
    brightness: Brightness.light,
  );
  final baseTextTheme = GoogleFonts.dmSansTextTheme();
  final sectionShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(22),
  );
  final fieldShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: Color.alphaBlend(
      colorScheme.primary.withValues(alpha: 0.035),
      colorScheme.surface,
    ),
    canvasColor: colorScheme.surface,
    textTheme: baseTextTheme.copyWith(
      displaySmall: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
      titleMedium: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
      labelLarge: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
      bodyMedium: GoogleFonts.dmSans(),
      bodySmall: GoogleFonts.dmSans(color: colorScheme.onSurface),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        color: colorScheme.onSurface,
        fontSize: 23,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.06),
      shape: sectionShape,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.38),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.error, width: 1.6),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide(color: colorScheme.outlineVariant),
      backgroundColor: colorScheme.surfaceContainerLowest,
      selectedColor: colorScheme.primaryContainer.withValues(alpha: 0.75),
      checkmarkColor: colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(color: colorScheme.onSurface),
      secondaryLabelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 18),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: fieldShape,
        textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: fieldShape,
        side: BorderSide(color: colorScheme.outlineVariant),
        foregroundColor: colorScheme.onSurface,
        textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: fieldShape,
        foregroundColor: colorScheme.primary,
        textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        foregroundColor: colorScheme.onSurface,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(fieldShape),
        side: WidgetStatePropertyAll(
          BorderSide(color: colorScheme.outlineVariant),
        ),
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        visualDensity: VisualDensity.standard,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant.withValues(alpha: 0.7),
      thickness: 1,
      space: 1,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      showDragHandle: true,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: GoogleFonts.dmSans(color: colorScheme.onInverseSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

Future<void> main() async {
  Logger.root.level = Level.ALL;
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    // Keep this only for non-web platforms where path_provider is available.
    // The app now uses a web-safe fallback for Chrome.
  }
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Collection? _collections;
  List<Book>? _filteredBooks;
  String? _loadErrorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    try {
      final loadedCollection = await loadCollectionFromStorage();

      if (!mounted) {
        return;
      }

      setState(() {
        _loadErrorMessage = null;
        _collections =
            loadedCollection ?? Collection(name: 'My Bookshelf', books: []);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _collections = null;
        _loadErrorMessage = 'Failed to load inventory data.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          appBar: AppBar(title: const Text('My Bookshelf')),
          body: Center(
            child: _loadErrorMessage == null
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_loadErrorMessage!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          unawaited(_loadCollections());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
          ),
        ),
      );
    }

    if (_loadErrorMessage != null && _collections == null) {
      return MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          appBar: AppBar(title: const Text('My Bookshelf')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_loadErrorMessage!),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    unawaited(_loadCollections());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      theme: buildAppTheme(),
      navigatorKey: _navigatorKey,
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('My Bookshelf'),
        ),
        body: SafeArea(
          child: Scroll(
            collections:
                _collections ?? Collection(name: 'My Bookshelf', books: []),
            filteredBooks: _filteredBooks,
            onAddPressed: () {
              unawaited(_openNewBook());
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            unawaited(_openNewBook());
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Book'),
        ),
      ),
    );
  }
  Future<void> _openNewBook() async {
    if (_collections == null) {
      return;
    }

    final result = await _navigatorKey.currentState?.push<Book>(
      MaterialPageRoute(
        builder: (context) => AddBook(collection: _collections!),
      ),
    );

    if (!mounted || result == null) {
      return;
    }
  }
}

class Scroll extends StatefulWidget {
  final Collection collections;
  final List<Book>? filteredBooks;
  final VoidCallback onAddPressed;

  const Scroll({
    super.key,
    required this.collections,
    required this.filteredBooks,
    required this.onAddPressed,
  });

  @override
  State<Scroll> createState() => _ScrollState();
}

enum SortField { name, author }

class _ScrollState extends State<Scroll> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SortField _sortField = SortField.name;
  bool _sortAscending = true;
  bool _showSortArrow = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  List<Book> _buildVisibleBooks() {
    final baseBooks = List<Book>.from(
      widget.filteredBooks ?? widget.collections.books,
    );
    final query = _searchQuery.trim().toLowerCase();

    final filteredBySearch = query.isEmpty
        ? baseBooks
        : baseBooks.where((book) {
            return book.name.toLowerCase().contains(query) ||
                book.author.toLowerCase().contains(query);
          }).toList();

    int compareResult(Book a, Book b) {
      switch (_sortField) {
        case SortField.name:
          return a.name.compareTo(b.name);
        case SortField.author:
          return a.author.compareTo(b.author);
      }
    }

    filteredBySearch.sort((a, b) {
      final result = compareResult(a, b);
      return _sortAscending ? result : -result;
    });
    return filteredBySearch;
  }

  String _sortLabel(SortField field) {
    switch (field) {
      case SortField.name:
        return 'Name';
      case SortField.author:
        return 'Author';
    }
  }

  void _toggleSort(SortField field) {
    setState(() {
      if (!_showSortArrow) {
        _sortField = field;
        _sortAscending = true;
        _showSortArrow = true;
      } else if (_sortField == field) {
        _sortAscending = !_sortAscending;
      } else {
        _sortField = field;
        _sortAscending = true;
      }
    });
  }

  Widget _buildSortChip(SortField field) {
    final selected = _showSortArrow && _sortField == field;
    final ascending = selected ? _sortAscending : true;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_sortLabel(field)),
          if (selected) ...[
            const SizedBox(width: 6),
            Icon(
              ascending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
            ),
          ],
        ],
      ),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => _toggleSort(field),
    );
  }


  Widget _buildControlPanel(BuildContext context, {required bool hasSearch}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search bookshelf',
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search title or author',
                    border: const OutlineInputBorder(),
                    suffixIcon: hasSearch
                        ? IconButton(
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.clear),
                            tooltip: 'Clear search',
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Sort by',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final field in SortField.values) _buildSortChip(field),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(
    BuildContext context, {
    required int visibleCount,
    required int totalCount,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Books',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final booksToDisplay = _buildVisibleBooks();
    final hasSearch = _searchQuery.trim().isNotEmpty;
    final hasNoBooks = widget.collections.books.isEmpty;
    final totalBooks = widget.collections.books.length;
    final visibleCount = booksToDisplay.length;

    String emptyStateMessage = 'No Books yet. Tap + to add your first Book.';
    if (hasSearch) {
      emptyStateMessage = 'No Books match your search.';
    }

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: FocusTraversalOrder(
              order: const NumericFocusOrder(2),
              child: _buildControlPanel(context, hasSearch: hasSearch),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              children: [
                _buildResultsHeader(
                  context,
                  visibleCount: visibleCount,
                  totalCount: totalBooks,
                ),
                const SizedBox(height: 12),
                if (booksToDisplay.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Center(
                      child: Container(
                        width: math.min(
                          MediaQuery.sizeOf(context).width - 48,
                          560,
                        ),
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primaryContainer
                                  .withValues(alpha: 0.38),
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHigh,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 74,
                              height: 74,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surface.withValues(alpha: 0.72),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                size: 36,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              hasNoBooks
                                  ? 'Start building your inventory'
                                  : 'No Books in this view',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              emptyStateMessage,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: widget.onAddPressed,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Book'),
                            ),
                            if (hasSearch)
                              TextButton(
                                onPressed: _clearSearch,
                                child: const Text('Clear Search'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: ListView.builder(
                      key: ValueKey(
                        '${booksToDisplay.length}-${_sortField.name}-${_sortAscending}-${_searchQuery.trim()}',
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 12),
                      itemCount: booksToDisplay.length,
                      itemBuilder: (context, index) {
                        final book = booksToDisplay[index];
                        final durationMs = 180 + (index * 18).clamp(0, 180);

                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: durationMs),
                          curve: Curves.easeOutCubic,
                          child: BookRow(
                            key: ValueKey(book.id),
                            i: book,
                            index: index,
                            collections: widget.collections,
                          ),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, (1 - value) * 10),
                                child: child,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

