import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../state/auth_state.dart';
import '../state/catalog_state.dart';
import '../theme/app_theme.dart';

/// Admin-only Product Form Screen supporting both Adding a new product
/// and Editing any field of an existing product (pre-filled with current values).
///
/// Conforms to Exam Admin Requirements:
/// - Add a product with name, description, price, stock quantity, category, and an image.
/// - Edit any field of an existing product, with the form pre-filled with its current values.
/// - Validate input: a name is required, price is a number of zero or more,
///   and stock is a whole number of zero or more.
class AdminProductFormScreen extends StatefulWidget {
  final Product? existingProduct;

  const AdminProductFormScreen({
    super.key,
    this.existingProduct,
  });

  bool get isEditing => existingProduct != null;

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _imageUrlController;
  late String _selectedCategory;

  Uint8List? _pickedImageBytes;
  String? _pickedImageName;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(
      text: p != null ? p.price.toStringAsFixed(2) : '',
    );
    _stockController = TextEditingController(
      text: p != null ? p.stock.toString() : '',
    );
    _imageUrlController = TextEditingController(text: p?.imagePath ?? '');
    _selectedCategory = p?.category.isNotEmpty == true
        ? p!.category
        : 'Poké Balls';
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
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick image: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _promptAddCategory(CatalogManager catalog) async {
    final controller = TextEditingController();
    final newCat = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            hintText: 'e.g. Key Items',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (newCat != null && newCat.isNotEmpty) {
      await catalog.addCategory(newCat);
      if (mounted) {
        setState(() {
          _selectedCategory = newCat;
        });
      }
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

      if (widget.isEditing) {
        final updated = widget.existingProduct!.copyWith(
          name: name,
          description: description,
          price: price,
          stock: stock,
          category: _selectedCategory,
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
            content: Text('Failed to save product: $e'),
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
    final catalog = CatalogScope.of(context);
    final auth = AuthScope.maybeOf(context);

    // Permission-denied guard if a non-admin navigates here directly
    if (auth != null && !auth.isAdmin) {
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

    final availableCategories = catalog.editableCategories.toSet().toList();
    if (!availableCategories.contains(_selectedCategory)) {
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

                      // 2. Category Selector + Add Category
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
                            onPressed: () => _promptAddCategory(catalog),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('New Category'),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
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
                          Text(
                            'Product Image (Supabase Storage / URL)',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
                                : Image.network(
                                    _imageUrlController.text.trim(),
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.catching_pokemon,
                                      size: 48,
                                      color: AppTheme.pogoTealPrimary,
                                    ),
                                  ),
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

