import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../providers/app_providers.dart';
import '../state/catalog_state.dart';
import '../theme/app_theme.dart';

/// Opens the Admin Category Management modal dialog (add, rename, delete).
Future<void> showAdminCategoriesDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const AdminCategoriesDialog(),
  );
}

/// Dialog allowing Admins to view, add, rename, and delete product categories.
class AdminCategoriesDialog extends ConsumerStatefulWidget {
  const AdminCategoriesDialog({super.key});

  @override
  ConsumerState<AdminCategoriesDialog> createState() =>
      _AdminCategoriesDialogState();
}

class _AdminCategoriesDialogState
    extends ConsumerState<AdminCategoriesDialog> {
  final _addFormKey = GlobalKey<FormState>();
  final _newCategoryController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isBusy = false;
  String? _errorMessage;

  @override
  void dispose() {
    _newCategoryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleAdd(CatalogManager catalog) async {
    if (!_addFormKey.currentState!.validate()) return;
    final name = _newCategoryController.text.trim();
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      await catalog.addCategory(name);
      if (mounted) {
        _newCategoryController.clear();
        setState(() => _isBusy = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBusy = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _handleRename(
    CatalogManager catalog,
    CategoryRecord category,
  ) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _RenameCategoryDialog(initialName: category.name),
    );

    if (newName == null || newName.isEmpty || newName == category.name) {
      return;
    }

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      await catalog.updateCategory(
        id: category.id,
        oldName: category.name,
        newName: newName,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _handleDelete(
    CatalogManager catalog,
    CategoryRecord category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete the category "${category.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.pogoValorRed,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      await catalog.deleteCategory(category.id);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final auth = ref.watch(authProvider);
    final catalog = ref.watch(catalogProvider);

    if (!auth.isAdmin) {
      return AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text('Only administrators can manage categories.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    }

    final categories = catalog.categoryRecords;

    return AlertDialog(
      title: const Text('Manage Categories'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withAlpha(180),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Form(
              key: _addFormKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _newCategoryController,
                      enabled: !_isBusy,
                      decoration: const InputDecoration(
                        hintText: 'New category name',
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter a name';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _handleAdd(catalog),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isBusy ? null : () => _handleAdd(catalog),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: categories.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('No categories found.')),
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: categories.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            cat.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: AppTheme.pogoTealPrimary,
                                ),
                                tooltip: 'Rename ${cat.name}',
                                onPressed: _isBusy
                                    ? null
                                    : () => _handleRename(catalog, cat),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: AppTheme.pogoValorRed,
                                ),
                                tooltip: 'Delete ${cat.name}',
                                onPressed: _isBusy
                                    ? null
                                    : () => _handleDelete(catalog, cat),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isBusy ? null : () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

class _RenameCategoryDialog extends StatefulWidget {
  final String initialName;

  const _RenameCategoryDialog({required this.initialName});

  @override
  State<_RenameCategoryDialog> createState() => _RenameCategoryDialogState();
}

class _RenameCategoryDialogState extends State<_RenameCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename Category'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Category Name',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Category name is required';
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
