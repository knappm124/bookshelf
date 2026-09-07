import 'utilities/addbook.dart';
import 'utilities/book.dart';
import 'utilities/file_utils.dart';
import 'utilities/bookwidgets.dart';
import 'utilities/filter.dart';
import 'utilities/isbnscanner.dart';
import 'utilities/menu.dart';

import 'dart:async';
import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';

ThemeData buildAppTheme({Brightness brightness = Brightness.light}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0E7490),
    brightness: brightness,
  );
  final baseTextTheme = GoogleFonts.dmSansTextTheme(
    ThemeData(brightness: brightness).textTheme,
  );
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
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: colorScheme.onSurface,
      ),
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
  ThemeMode _themeMode = ThemeMode.system;
  static const String _themeModePrefKey = 'bookshelf.themeMode';
  Collection? _collections;
  Bookshelf? _bookshelf;
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
      final collections =
          loadedCollection ??
          Collection(
            name: 'My Bookshelf',
            bookshelves: [Bookshelf(name: 'Default')],
          );

      if (collections.bookshelves.isEmpty) {
        collections.addBookshelf('Default');
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _loadErrorMessage = null;
        _collections = collections;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _collections = null;
        _loadErrorMessage = 'Failed to load collection data.';
        _isLoading = false;
      });
    }
  }

  Future<void> _onThemeModeChanged(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModePrefKey, themeMode.name);

    if (!mounted) {
      return;
    }

    setState(() {
      _themeMode = themeMode;
    });
  }

  Future<void> _openSettings() async {
    if (_collections == null) {
      return;
    }

    await _navigatorKey.currentState?.push<void>(
      MaterialPageRoute(
        builder: (context) => Menu(
          c: _collections!,
          filteredBooks: _filteredBooks,
          themeMode: _themeMode,
          onThemeModeChanged: _onThemeModeChanged,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _bookshelf = _selectedBookshelf(_collections!);
    });
  }

  Bookshelf _selectedBookshelf(Collection collections) {
    final selectedBookshelf = _bookshelf;
    if (selectedBookshelf != null) {
      for (final bookshelf in collections.bookshelves) {
        if (bookshelf.id == selectedBookshelf.id) {
          return bookshelf;
        }
      }
    }
    return collections.bookshelves.first;
  }

  void _selectBookshelf(Collection collections, String bookshelfId) {
    for (final bookshelf in collections.bookshelves) {
      if (bookshelf.id == bookshelfId) {
        setState(() {
          _bookshelf = bookshelf;
          _filteredBooks = null;
        });
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        theme: buildAppTheme(),
        darkTheme: buildAppTheme(brightness: Brightness.dark),
        themeMode: _themeMode,
        home: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('My Bookshelf'),
            actions: [
              IconButton(
                icon: Icon(Icons.settings),
                tooltip: 'Settings',
                onPressed: () {
                  unawaited(_openSettings());
                },
              ),
            ],
          ),
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

    final collections =
        _collections ??
        Collection(
          name: 'My Bookshelf',
          bookshelves: [Bookshelf(name: 'Default')],
        );
    final selectedBookshelf = _selectedBookshelf(collections);

    return MaterialApp(
      theme: buildAppTheme(),
      darkTheme: buildAppTheme(brightness: Brightness.dark),
      themeMode: _themeMode,
      navigatorKey: _navigatorKey,
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('My Bookshelf'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () {
                unawaited(_openSettings());
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Scroll(
            collections: collections,
            bookshelf: selectedBookshelf,
            onBookshelfSelected: (bookshelfId) {
              _selectBookshelf(collections, bookshelfId);
            },
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

    final selectedBookshelf = _selectedBookshelf(_collections!);
    final context = _navigatorKey.currentContext;
    if (context == null) {
      return;
    }

    final choice = await showModalBottomSheet<_AddBookMethod>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Enter Manually'),
              onTap: () => Navigator.pop(context, _AddBookMethod.manual),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scan ISBN'),
              onTap: () => Navigator.pop(context, _AddBookMethod.scan),
            ),
          ],
        ),
      ),
    );

    if (choice == null) {
      return;
    }

    final result = await _navigatorKey.currentState?.push<Book>(
      MaterialPageRoute(
        builder: (context) => choice == _AddBookMethod.manual
            ? AddBook(collection: _collections!, bookshelf: selectedBookshelf)
            : IsbnScanner(
                collection: _collections!,
                bookshelf: selectedBookshelf,
              ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _filteredBooks = null;
    });
  }
}

enum _AddBookMethod { manual, scan }

class Scroll extends StatefulWidget {
  final Collection collections;
  final Bookshelf bookshelf;
  final ValueChanged<String> onBookshelfSelected;
  final List<Book>? filteredBooks;
  final VoidCallback onAddPressed;

  const Scroll({
    super.key,
    required this.collections,
    required this.bookshelf,
    required this.onBookshelfSelected,
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
  FilterCriteria _filterCriteria = const FilterCriteria();
  SortField _sortField = SortField.name;
  bool _sortAscending = true;
  bool _showSortArrow = false;
  bool _isListView = false;

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

  Future<void> _openFilter() async {
    await Navigator.of(context).push<void>(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        pageBuilder: (context, animation, secondaryAnimation) {
          final screenWidth = MediaQuery.sizeOf(context).width;
          return Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: screenWidth >= 700 ? 0.78 : 0.86,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                child: SafeArea(
                  top: false,
                  child: Filter(
                    c: widget.collections,
                    bookshelf: widget.bookshelf,
                    criteria: _filterCriteria,
                    onFilterChanged: (_) {
                      setState(() {});
                    },
                    onCriteriaChanged: (criteria) {
                      setState(() {
                        _filterCriteria = criteria;
                      });
                    },
                  ),
                ),
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(
            position: animation.drive(slide),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  List<Book> _buildVisibleBooks() {
    final baseBooks = List<Book>.from(
      _filterCriteria.hasActiveFilters
          ? _filterCriteria.apply(widget.bookshelf.books)
          : (widget.filteredBooks ?? widget.bookshelf.books),
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
          LayoutBuilder(
            builder: (context, constraints) => MenuAnchor(
              alignmentOffset: const Offset(0, 4),
              style: MenuStyle(
                backgroundColor: WidgetStatePropertyAll(
                  colorScheme.surfaceContainerHigh,
                ),
                padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              menuChildren: [
                for (final bookshelf in widget.collections.bookshelves)
                  SizedBox(
                    width: constraints.maxWidth,
                    child: MenuItemButton(
                      onPressed: () {
                        widget.onBookshelfSelected(bookshelf.id);
                      },
                      child: Text(
                        bookshelf.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
              builder: (context, controller, child) => Semantics(
                button: true,
                label: 'Switch collection',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    child: InputDecorator(
                      isEmpty: false,
                      decoration: InputDecoration(
                        labelText: 'Switch collection',
                        filled: true,
                        fillColor: colorScheme.primaryContainer.withValues(
                          alpha: 0.34,
                        ),
                        prefixIcon: Icon(
                          Icons.collections_bookmark_outlined,
                          color: colorScheme.primary,
                        ),
                        floatingLabelStyle: TextStyle(
                          color: colorScheme.primary,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.bookshelf.name,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
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
              IconButton.filledTonal(
                onPressed: _openFilter,
                tooltip: 'Filter books',
                icon: Badge(
                  isLabelVisible: _filterCriteria.hasActiveFilters,
                  child: const Icon(Icons.filter_list),
                ),
              ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Books',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  LayoutIcons(
                    isListView: _isListView,
                    onViewChanged: (isListView) {
                      setState(() {
                        _isListView = isListView;
                      });
                    },
                  ),
                ],
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
    final hasNoBooks = widget.bookshelf.books.isEmpty;
    final totalBooks = widget.bookshelf.books.length;
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
                                Icons.book_outlined,
                                size: 36,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              hasNoBooks
                                  ? 'Start adding books'
                                  : 'No Books in this view',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              emptyStateMessage,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
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
                    child: _isListView
                        ? ListViewWidget(
                            key: const ValueKey('list-view'),
                            books: booksToDisplay,
                            bookshelf: widget.bookshelf,
                            onBookUpdated: (_) => setState(() {}),
                            collections: widget.collections,
                          )
                        : GridView.builder(
                            key: const ValueKey('grid-view'),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 100,
                                  mainAxisExtent: 120,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                ),
                            itemCount: booksToDisplay.length,
                            itemBuilder: (context, index) => _buildAnimatedBook(
                              booksToDisplay[index],
                              index,
                            ),
                          ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBook(Book book, int index) {
    final durationMs = 180 + (index * 18).clamp(0, 180);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: durationMs),
      curve: Curves.easeOutCubic,
      child: BookRow(
        key: ValueKey(book.id),
        i: book,
        index: index,
        bookshelf: widget.bookshelf,
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
  }
}

class LayoutIcons extends StatelessWidget {
  final bool isListView;
  final ValueChanged<bool> onViewChanged;

  const LayoutIcons({
    super.key,
    required this.isListView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.grid_view),
          tooltip: 'Grid View',
          onPressed: () => onViewChanged(false),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.list),
          tooltip: 'List View',
          onPressed: () => onViewChanged(true),
        ),
      ],
    );
  }
}
