import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../providers/app_providers.dart';
import '../state/catalog_state.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_categories_dialog.dart';

/// Admin-only Product Form Screen supporting product creation and pre-filled editing.
class AdminProductFormScreen extends ConsumerStatefulWidget {
  final String? productId;
  final Product? existingProduct;

  const AdminProductFormScreen({
    super.key,
    this.productId,
    this.existingProduct,
  });

  bool get isEditing =>
      existingProduct != null ||
      (productId != null && productId!.isNotEmpty);

  @override
  ConsumerState<AdminProductFormScreen> createState() =>
      _AdminProductFormScreenState();
}

class _AdminProductFormScreenState
    extends ConsumerState<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _imageUrlController;
  late String _selectedCategory;

  Product? _loadedProduct;
  bool _isLoadingProduct = false;
  String? _loadError;

  Uint8List? _pickedImageBytes;
  String? _pickedImageName;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final catalog = ref.read(catalogProvider);
    final initialProduct = widget.existingProduct ??
        (widget.productId != null
            ? catalog.findProductById(widget.productId!)
            : null);

    _loadedProduct = initialProduct;
    _nameController = TextEditingController(text: initialProduct?.name ?? '');
    _descriptionController = TextEditingController(
      text: initialProduct?.description ?? '',
    );
    _priceController = TextEditingController(
      text: initialProduct != null
          ? initialProduct.price.toStringAsFixed(2)
          : '',
    );
    _stockController = TextEditingController(
      text: initialProduct != null ? initialProduct.stock.toString() : '',
    );
    _imageUrlController = TextEditingController(
      text: initialProduct?.imagePath ?? '',
    );

    final available = catalog.editableCategories;
    if (initialProduct != null && initialProduct.category.isNotEmpty) {
      _selectedCategory = initialProduct.category;
    } else if (available.isNotEmpty) {
      _selectedCategory = available.first;
    } else {
      _selectedCategory = 'Poké Balls';
    }

    if (widget.isEditing && initialProduct == null && widget.productId != null) {
      _fetchExistingProduct();
    }
  }

  Future<void> _fetchExistingProduct() async {
    setState(() {
      _isLoadingProduct = true;
      _loadError = null;
    });

    try {
      final fetched = await ref
          .read(catalogProvider)
          .findOrFetchProduct(widget.productId!);
      if (!mounted) return;

      if (fetched == null) {
        setState(() {
          _loadError = 'Product not found.';
          _isLoadingProduct = false;
        });
        return;
      }

      setState(() {
        _loadedProduct = fetched;
        _nameController.text = fetched.name;
        _descriptionController.text = fetched.description;
        _priceController.text = fetched.price.toStringAsFixed(2);
        _stockController.text = fetched.stock.toString();
        _imageUrlController.text = fetched.imagePath;
        if (fetched.category.isNotEmpty) {
          _selectedCategory = fetched.category;
        }
        _isLoadingProduct = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e.toString().replaceFirst('Exception: ', '');
          _isLoadingProduct = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage(CatalogManager catalog) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      setState(() {
        _pickedImageBytes = bytes;
        _pickedImageName = file.name;
        _isSubmitting = true;
      });

      final uploadedUrl = await catalog.uploadProductImage(
        bytes: bytes,
        fileName: file.name,
      );

      if (mounted) {
        setState(() {
          _imageUrlController.text = uploadedUrl;
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded to Supabase Storage.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pickedImageBytes = null;
          _pickedImageName = null;
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Image upload failed: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _openManageCategories(CatalogManager catalog) async {
    await showAdminCategoriesDialog(context);
    if (!mounted) return;
    final updatedCats = ref.read(catalogProvider).editableCategories;
    if (updatedCats.isNotEmpty && !updatedCats.contains(_selectedCategory)) {
      setState(() {
        _selectedCategory = updatedCats.first;
      });
    }
  }

  Future<void> _submit(CatalogManager catalog) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final price = double.parse(_priceController.text.trim());
      final stock = int.parse(_stockController.text.trim());
      final imageUrl = _imageUrlController.text.trim().isNotEmpty
          ? _imageUrlController.text.trim()
          : 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/pokeball_sprite.png';
      final resolvedCategoryId = catalog.categoryIdForName(_selectedCategory);

      if (widget.isEditing && _loadedProduct != null) {
        final updated = _loadedProduct!.copyWith(
          name: name,
          description: description,
          price: price,
          stock: stock,
          category: _selectedCategory,
          categoryId: resolvedCategoryId,
          imagePath: imageUrl,
        );
        await catalog.updateProduct(updated);
      } else {
        final slug = name
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
            .replaceAll(RegExp(r'^-|-$'), '');
        final id =
            '${slug.isEmpty ? 'item' : slug}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

        final created = Product(
          id: id,
          name: name,
          description: description,
          price: price,
          stock: stock,
          category: _selectedCategory,
          categoryId: resolvedCategoryId,
          imagePath: imageUrl,
          soldCount: 0,
        );
        await catalog.addProduct(created);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Updated "$name" successfully.'
                  : 'Added "$name" to PokéMart catalog.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save product: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final catalog = ref.watch(catalogProvider);
    final auth = ref.watch(authProvider);

    // Permission-denied guard for non-admin users navigating directly
    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Permission Denied')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.gpp_bad_outlined,
                  size: 64,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Admin Access Required',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Only administrators are permitted to add or edit catalog products.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Return to Catalog'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (widget.isEditing && _loadedProduct == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Product'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go('/');
              }
            },
          ),
        ),
        body: Center(
          child: _isLoadingProduct
              ? const CircularProgressIndicator(
                  color: AppTheme.pogoTealPrimary,
                )
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 52,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _loadError ?? 'Product not found.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => context.go('/'),
                        child: const Text('Return to Catalog'),
                      ),
                    ],
                  ),
                ),
        ),
      );
    }

    final availableCategories = catalog.editableCategories.toSet().toList();
    if (availableCategories.isEmpty) {
      availableCategories.add(_selectedCategory);
    } else if (!availableCategories.contains(_selectedCategory)) {
      availableCategories.add(_selectedCategory);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Product' : 'Add Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.isEditing
                            ? 'Modify Product Details'
                            : 'Create New PokéMart Item',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All fields are validated before saving to Supabase PostgreSQL.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 1. Product Name (Required)
                      Text(
                        'Product Name *',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Luxury Ball',
                          prefixIcon: Icon(Icons.catching_pokemon, size: 20),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Product name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 2. Category Selector + Manage Categories
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Category *',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _openManageCategories(catalog),
                            icon: const Icon(Icons.category_outlined, size: 16),
                            label: const Text('Manage Categories'),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        key: ValueKey<String>(
                          'cat-$_selectedCategory-${availableCategories.join('|')}',
                        ),
                        initialValue: _selectedCategory,
                        items: availableCategories
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCategory = val);
                          }
                        },
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.category_outlined, size: 20),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. Price (>= 0) & Stock (Whole number >= 0)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price (₽) *',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _priceController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: const InputDecoration(
                                    hintText: '0.00',
                                    prefixIcon: Icon(
                                      Icons.payments_outlined,
                                      size: 20,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Price is required';
                                    }
                                    final parsed = double.tryParse(
                                      value.trim(),
                                    );
                                    if (parsed == null || parsed < 0) {
                                      return 'Must be a number >= 0';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Stock Quantity *',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _stockController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                    prefixIcon: Icon(
                                      Icons.inventory_2_outlined,
                                      size: 20,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Stock is required';
                                    }
                                    final parsed = int.tryParse(value.trim());
                                    if (parsed == null || parsed < 0) {
                                      return 'Whole number >= 0';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 4. Description
                      Text(
                        'Description *',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText:
                              'Describe the item effect and trainer utility...',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 5. Image Storage Upload or URL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Product Image (Supabase Storage / URL)',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: _isSubmitting
                                ? null
                                : () => _pickAndUploadImage(catalog),
                            icon: const Icon(
                              Icons.cloud_upload_outlined,
                              size: 16,
                            ),
                            label: Text(
                              _pickedImageName != null
                                  ? 'Change Image'
                                  : 'Upload Image',
                            ),
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          hintText: 'https://...',
                          prefixIcon: Icon(Icons.image_outlined, size: 20),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      if (_pickedImageBytes != null ||
                          _imageUrlController.text.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          height: 100,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withAlpha(50),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: _pickedImageBytes != null
                                ? Image.memory(
                                    _pickedImageBytes!,
                                    fit: BoxFit.contain,
                                  )
                                : (_imageUrlController.text
                                        .trim()
                                        .startsWith('http')
                                    ? Image.network(
                                        _imageUrlController.text.trim(),
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, _, _) => const Icon(
                                          Icons.catching_pokemon,
                                          size: 48,
                                          color: AppTheme.pogoTealPrimary,
                                        ),
                                      )
                                    : Image.asset(
                                        _imageUrlController.text.trim(),
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, _, _) => const Icon(
                                          Icons.catching_pokemon,
                                          size: 48,
                                          color: AppTheme.pogoTealPrimary,
                                        ),
                                      )),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Submit Action
                      FilledButton.icon(
                        onPressed:
                            _isSubmitting ? null : () => _submit(catalog),
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                widget.isEditing
                                    ? Icons.save_outlined
                                    : Icons.add_circle_outline,
                              ),
                        label: Text(
                          widget.isEditing ? 'Save Changes' : 'Add Product',
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
