import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';

/// Screen displaying details for a selected product.
///
/// Implemented as a [StatefulWidget] to manage the selected variant,
/// multiple image views (e.g. front and back angles), and the quantity counter.
///
/// Features a responsive layout:
/// - Tablet / Desktop (>= 700px): 2-column side-by-side layout (Shopee style)
/// - Mobile (< 700px): Single-column vertical layout
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

      // body: responsive layout (2-column for tablet/desktop, 1-column for mobile)
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 700;

          if (isTablet) {
            // Tablet / Desktop 2-column layout (Shopee e-commerce style)
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1050),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Square Highlight Image + Thumbnail Gallery
                      SizedBox(
                        width: 380,
                        child: _buildImageGallery(
                          context,
                          colorScheme,
                          activeVariant,
                          activeImages,
                          currentImageIndex,
                          hasVariants,
                        ),
                      ),
                      const SizedBox(width: 32),

                      // Right Column: Product Information & Action Buttons
                      Expanded(
                        child: _buildProductDetails(
                          context,
                          theme,
                          colorScheme,
                          activeVariant,
                          displayName,
                          displayPrice,
                          displayDescription,
                          displayStock,
                          hasVariants,
                          isTablet: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            // Mobile single-column layout
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: _buildImageGallery(
                        context,
                        colorScheme,
                        activeVariant,
                        activeImages,
                        currentImageIndex,
                        hasVariants,
                      ),
                    ),
                  ),
                  _buildProductDetails(
                    context,
                    theme,
                    colorScheme,
                    activeVariant,
                    displayName,
                    displayPrice,
                    displayDescription,
                    displayStock,
                    hasVariants,
                    isTablet: false,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  /// Builds the square highlight image and the thumbnail strip underneath.
  Widget _buildImageGallery(
    BuildContext context,
    ColorScheme colorScheme,
    ProductVariant? activeVariant,
    List<String> activeImages,
    int currentImageIndex,
    bool hasVariants,
  ) {
    final activeImagePath = activeImages.isNotEmpty
        ? activeImages[currentImageIndex]
        : widget.product.imagePath;
    final hasRealImage = activeImagePath.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main square image
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: AspectRatio(
            aspectRatio: 1.0, // forced 1:1 square ratio
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(80),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Product image if available, else clean placeholder icon
                  hasRealImage
                      ? Image.asset(
                          activeImagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                size: 80,
                                color: colorScheme.primary,
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 80,
                            color: colorScheme.primary,
                          ),
                        ),

                  // Active variant badge
                  if (activeVariant != null)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withAlpha(220),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.outlineVariant,
                          ),
                        ),
                        child: Text(
                          '${activeVariant.name} (${activeVariant.id})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                  // Angle index indicator if multiple images exist
                  if (activeImages.length > 1)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withAlpha(220),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: colorScheme.outlineVariant,
                          ),
                        ),
                        child: Text(
                          '${currentImageIndex + 1}/${activeImages.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Thumbnails row under the main picture
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
                      final thumbPath = activeImages[index];

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
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                thumbPath.isNotEmpty
                                    ? Image.asset(
                                        thumbPath,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Center(
                                            child: Icon(
                                              Icons.photo_outlined,
                                              size: 18,
                                              color: isSelected
                                                  ? colorScheme.primary
                                                  : colorScheme
                                                      .onSurfaceVariant,
                                            ),
                                          );
                                        },
                                      )
                                    : Center(
                                        child: Icon(
                                          Icons.photo_outlined,
                                          size: 18,
                                          color: isSelected
                                              ? colorScheme.primary
                                              : colorScheme
                                                  .onSurfaceVariant,
                                        ),
                                      ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    color:
                                        colorScheme.surface.withAlpha(210),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    child: Text(
                                      label,
                                      textAlign: TextAlign.center,
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
                          final isSelected = _selectedVariantIndex == index;
                          final variant = widget.product.variants[index];
                          final variantImage = variant.allImages.isNotEmpty
                              ? variant.allImages.first
                              : widget.product.imagePath;

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
                                clipBehavior: Clip.antiAlias,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    variantImage.isNotEmpty
                                        ? Image.asset(
                                            variantImage,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Center(
                                                child: Icon(
                                                  Icons.image_outlined,
                                                  size: 20,
                                                  color: isSelected
                                                      ? colorScheme.primary
                                                      : colorScheme
                                                          .onSurfaceVariant,
                                                ),
                                              );
                                            },
                                          )
                                        : Center(
                                            child: Icon(
                                              Icons.image_outlined,
                                              size: 20,
                                              color: isSelected
                                                  ? colorScheme.primary
                                                  : colorScheme
                                                      .onSurfaceVariant,
                                            ),
                                          ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        color:
                                            colorScheme.surface.withAlpha(210),
                                        padding:
                                            const EdgeInsets.symmetric(vertical: 2),
                                        child: Text(
                                          variant.name,
                                          textAlign: TextAlign.center,
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
      ],
    );
  }

  /// Builds the right-hand (or bottom) product information and action buttons.
  Widget _buildProductDetails(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    ProductVariant? activeVariant,
    String displayName,
    String displayPrice,
    String displayDescription,
    int displayStock,
    bool hasVariants, {
    required bool isTablet,
  }) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 8.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category tag
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
          const SizedBox(height: 10),

          // Product title
          Text(
            displayName,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 26 : 22,
            ),
          ),
          const SizedBox(height: 8),

          // Rating and Sold count row (Shopee style)
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              const Text(
                '5.0',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 8),
              Text(
                '|',
                style: TextStyle(color: colorScheme.outlineVariant),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.product.soldCount} Sold',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Price and stock banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(50),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayPrice,
                  style: TextStyle(
                    fontSize: isTablet ? 28 : 24,
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
          ),

          // Variant buttons section
          if (hasVariants) ...[
            const SizedBox(height: 20),
            Text(
              'Color / Variation',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
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
                        horizontal: 16,
                        vertical: 12,
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

          const Divider(height: 32),

          // Description
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

          const Divider(height: 32),

          // Quantity selector
          Row(
            children: [
              Text(
                'Quantity',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 24),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
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

          const SizedBox(height: 28),

          // Add to Cart button
          SizedBox(
            width: isTablet ? 300 : double.infinity,
            height: 48,
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
    );
  }
}
