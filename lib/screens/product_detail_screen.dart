import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';

/// Screen displaying details for a selected product.
///
/// Implemented as a [StatefulWidget] to manage the selected variant,
/// multiple image views (e.g. front and back angles), and the quantity counter.
class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // tracks the currently selected variant index
  int _selectedVariantIndex = 0;

  // tracks the currently selected image index (for front, back, etc.)
  int _selectedImageIndex = 0;

  // item quantity
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // active variant object
    final hasVariants = widget.product.variants.isNotEmpty;
    final activeVariant =
        hasVariants ? widget.product.variants[_selectedVariantIndex] : null;

    // active images: uses variant-specific images if provided, else falls back to product images
    final activeImages = activeVariant?.allImages.isNotEmpty == true
        ? activeVariant!.allImages
        : widget.product.allImages;

    // safe image index bounds check
    final currentImageIndex =
        _selectedImageIndex < activeImages.length ? _selectedImageIndex : 0;

    // active display values: uses variant-specific values if defined, else inherits from base product
    final displayName = activeVariant != null
        ? '${widget.product.name} - ${activeVariant.name}'
        : widget.product.name;
    final displayPrice = activeVariant?.price != null
        ? '₱${activeVariant!.price!.toStringAsFixed(0)}'
        : widget.product.formattedPrice;
    final displayDescription =
        activeVariant?.description ?? widget.product.description;
    final displayStock = activeVariant?.stock ?? widget.product.stock;

    // appbar
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Menu',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),

      // body body
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // main pic: uses AspectRatio 1.0 so it is ALWAYS a perfect square on mobile and tablet
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 420, // keeps it neat and square on tablet/desktop screens
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: AspectRatio(
                    aspectRatio: 1.0, // forced square 1:1 ratio
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withAlpha(80),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 80,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          // indicator showing the active variant name & sub-id
                          if (activeVariant != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: colorScheme.primary.withAlpha(80),
                                ),
                              ),
                              child: Text(
                                '${activeVariant.name} (${activeVariant.id})',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          if (activeImages.length > 1) ...[
                            const SizedBox(height: 6),
                            Text(
                              'View ${currentImageIndex + 1} of ${activeImages.length}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // thumbnail pics row under the main picture
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4.0),
                  child: SizedBox(
                    height: 64,
                    child: activeImages.length > 1
                        ? ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: activeImages.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final isSelected = currentImageIndex == index;
                              final label = index == 0
                                  ? 'Front'
                                  : (index == 1 ? 'Back' : 'View ${index + 1}');

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImageIndex = index;
                                  });
                                },
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest
                                          .withAlpha(80),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? colorScheme.primary
                                            : colorScheme.outlineVariant,
                                        width: isSelected ? 2.5 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.photo_outlined,
                                          size: 18,
                                          color: isSelected
                                              ? colorScheme.primary
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          label,
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? colorScheme.primary
                                                : colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : (hasVariants
                            ? ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.product.variants.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final isSelected =
                                      _selectedVariantIndex == index;
                                  final variant =
                                      widget.product.variants[index];

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedVariantIndex = index;
                                        _selectedImageIndex = 0;
                                      });
                                    },
                                    child: AspectRatio(
                                      aspectRatio: 1.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: colorScheme
                                              .surfaceContainerHighest
                                              .withAlpha(80),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isSelected
                                                ? colorScheme.primary
                                                : colorScheme.outlineVariant,
                                            width: isSelected ? 2.5 : 1,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.image_outlined,
                                              size: 20,
                                              color: isSelected
                                                  ? colorScheme.primary
                                                  : colorScheme
                                                      .onSurfaceVariant,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              variant.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: isSelected
                                                    ? colorScheme.primary
                                                    : colorScheme
                                                        .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : const SizedBox.shrink()),
                  ),
                ),
              ),
            ),

            // product info section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // category tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.product.category.toUpperCase(),
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // product title (shows base name or active variant name)
                  Text(
                    displayName,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // price and stock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        displayPrice,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withAlpha(80),
                          ),
                        ),
                        child: Text(
                          '$displayStock in stock',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // variant buttons section
                  if (hasVariants) ...[
                    const Divider(height: 28),
                    Text(
                      'Variation',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(
                        widget.product.variants.length,
                        (index) {
                          final isSelected = _selectedVariantIndex == index;
                          final variant = widget.product.variants[index];

                          return OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? colorScheme.primary.withAlpha(25)
                                  : null,
                              side: BorderSide(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.outlineVariant,
                                width: isSelected ? 2 : 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedVariantIndex = index;
                                _selectedImageIndex = 0; // reset image to first angle
                              });
                            },
                            child: Text(
                              variant.name,
                              style: TextStyle(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const Divider(height: 28),

                  // description
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    displayDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),

                  const Divider(height: 28),

                  // quantity selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantity',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: _quantity > 1
                                  ? () {
                                      setState(() {
                                        _quantity--;
                                      });
                                    }
                                  : null,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: _quantity < displayStock
                                  ? () {
                                      setState(() {
                                        _quantity++;
                                      });
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // add to cart button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart_outlined),
                      label: const Text('Add to Cart'),
                      onPressed: () {
                        final variantNote = activeVariant != null
                            ? ' (${activeVariant.name} - ${activeVariant.id})'
                            : '';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added $_quantity x ${widget.product.name}$variantNote to cart',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
