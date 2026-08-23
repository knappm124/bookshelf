import 'package:flutter/material.dart';

import 'book.dart';

class Menu extends StatelessWidget {
  final Collection c;

  const Menu({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              minVerticalPadding: 14,
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.sell_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: const Text('Tags'),
              subtitle: const Text('Edit filtering and organization tags.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Editor(tagName: 'Tags', c: c),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Editor extends StatefulWidget {
  final String tagName;
  final Collection c;

  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a name';
    }
    return null;
  }

  const Editor({
    super.key,
    required this.tagName,
    required this.c,
  });

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  final TextEditingController controller = TextEditingController();
  String name = "";

  EdgeInsets _listContentPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.fromLTRB(
      12,
      12,
      12,
      12 + mediaQuery.padding.bottom + mediaQuery.viewInsets.bottom,
    );
  }

  String _formatRemovalError(Object error) {
    final raw = error.toString();
    const exceptionPrefix = 'Exception: ';
    if (raw.startsWith(exceptionPrefix)) {
      return raw.substring(exceptionPrefix.length);
    }
    return raw;
  }

  void _showRemovalError(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_formatRemovalError(error))));
  }

  void _submitTag() {
    name = controller.text.trim();
    if (name.isNotEmpty) {
      final createdTagName = name;
      setState(() {
        widget.c.addTag(createdTagName);
        controller.clear();
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EditTag(tag: createdTagName, collections: widget.c),
        ),
      );
    }
  }

  void _removeTag(String tagName) {
    try {
      setState(() {
        widget.c.removeTag(tagName);
      });
    } catch (error) {
      _showRemovalError(error);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tags = widget.c.getAllTagNames().toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return Scaffold(
      appBar: AppBar(title: const Text('Tags')),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          padding: _listContentPadding(context),
          children: [
            _PanelHero(
              title: 'Manage tags',
              subtitle:
                  'Keep book classification tidy so filtering and grouping stay useful.',
              trailingLabel: '${tags.length} tags',
              trailingIcon: Icons.sell_outlined,
            ),
            const SizedBox(height: 12),
            _PanelCard(
              child: tags.isEmpty
                  ? const ListTile(
                      title: Text('No tags yet'),
                      subtitle: Text('Add your first tag below.'),
                    )
                  : Column(
                      children: [
                        for (final t in tags)
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.sell_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            title: Text(t),
                            trailing: Wrap(
                              spacing: 6,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: 'Edit tag',
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditTag(
                                          tag: t,
                                          collections: widget.c,
                                        ),
                                      ),
                                    );
                                    if (!mounted) {
                                      return;
                                    }
                                    setState(() {});
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Delete tag',
                                  onPressed: () => _removeTag(t),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 12),
            _PanelCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Tag',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controller,
                      validator: widget.validator,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submitTag(),
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'Office, Camera, Seasonal...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _submitTag,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Tag'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailingLabel;
  final IconData trailingIcon;

  const _PanelHero({
    required this.title,
    required this.subtitle,
    required this.trailingLabel,
    required this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
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
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(trailingIcon, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(trailingLabel, style: theme.textTheme.labelLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  final Widget child;

  const _PanelCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      elevation: 0,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.04),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class EditTag extends StatefulWidget {
  final String tag;
  final Collection collections;

  const EditTag({super.key, required this.tag, required this.collections});

  @override
  State<EditTag> createState() => _EditTagState();
}

class _EditTagState extends State<EditTag> {
  late TextEditingController _controller;
  late String _currentTag;

  EdgeInsets _contentPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.fromLTRB(
      12,
      12,
      12,
      12 + mediaQuery.padding.bottom + mediaQuery.viewInsets.bottom,
    );
  }

  void _addOption() {
    final newOption = _controller.text.trim();
    if (newOption.isNotEmpty) {
      setState(() {
        widget.collections.addTagOption(_currentTag, newOption);
      });
      _controller.clear();
    }
  }

  String _formatError(Object error) {
    final raw = error.toString();
    const prefix = 'Exception: ';
    if (raw.startsWith(prefix)) {
      return raw.substring(prefix.length);
    }
    return raw;
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_formatError(error))));
  }

  Future<String?> _askForName({
    required String title,
    required String label,
    required String initialValue,
    required String saveLabel,
  }) async {
    final textController = TextEditingController(text: initialValue);
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: textController,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              Navigator.of(dialogContext).pop(textController.text.trim());
            },
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(textController.text.trim());
              },
              child: Text(saveLabel),
            ),
          ],
        );
      },
    );
    textController.dispose();
    return value;
  }

  Future<void> _renameTag() async {
    final newName = await _askForName(
      title: 'Rename Tag',
      label: 'Tag name',
      initialValue: _currentTag,
      saveLabel: 'Rename',
    );

    if (!mounted || newName == null) {
      return;
    }

    final trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed == _currentTag) {
      return;
    }

    try {
      setState(() {
        widget.collections.renameTag(_currentTag, trimmed);
        _currentTag = trimmed;
      });
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _renameOption(String option) async {
    final newOption = await _askForName(
      title: 'Rename Option',
      label: 'Option name',
      initialValue: option,
      saveLabel: 'Rename',
    );

    if (!mounted || newOption == null) {
      return;
    }

    final trimmed = newOption.trim();
    if (trimmed.isEmpty || trimmed == option) {
      return;
    }

    try {
      setState(() {
        widget.collections.renameTagOption(_currentTag, option, trimmed);
      });
    } catch (error) {
      _showError(error);
    }
  }

  @override
  void initState() {
    super.initState();
    _currentTag = widget.tag;
    _controller = TextEditingController(text: "");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortedOptions =
        (widget.collections.getTagOptions(_currentTag).toList())
          ..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTag),
        actions: [
          IconButton(
            icon: const Icon(Icons.drive_file_rename_outline),
            tooltip: 'Rename tag',
            onPressed: _renameTag,
          ),
          const SizedBox(width: 4),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          padding: _contentPadding(context),
          children: [
            Card(
              child: sortedOptions.isEmpty
                  ? const ListTile(title: Text('No options yet'))
                  : Column(
                      children: [
                        for (final option in sortedOptions)
                          ListTile(
                            title: Text(option),
                            trailing: Wrap(
                              spacing: 4,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.drive_file_rename_outline,
                                  ),
                                  tooltip: 'Rename option',
                                  onPressed: () => _renameOption(option),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  tooltip: 'Delete option',
                                  onPressed: () {
                                    setState(() {
                                      widget.collections.removeTagOption(
                                        _currentTag,
                                        option,
                                      );
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _controller,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _addOption(),
                        decoration: const InputDecoration(
                          labelText: 'New Option',
                          hintText: 'Enter a new option for the tag',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _addOption,
                      child: const Text('Add Option'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
