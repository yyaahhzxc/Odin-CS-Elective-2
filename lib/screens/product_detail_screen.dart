import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../state/cart_state.dart';
import '../theme/app_theme.dart';

/// Screen displaying comprehensive details for a selected product.
/// Implements standard e-commerce conventions: hero product image showcase,
/// clear pricing hierarchy, variant selection, stock indicators, and an anchored
/// bottom purchasing bar.
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
  int _selectedVariantIndex = 0;
  int _quantity = 1;

  // Floating notification banner state
  bool _showBanner = false;
  String _bannerMessage = '';
  Timer? _bannerTimer;

  bool _isFavorite = false;

  @override
  void dispose() {
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cart = CartScope.of(context);

    final hasVariants = widget.product.variants.isNotEmpty;
    final activeVariant =
        hasVariants ? widget.product.variants[_selectedVariantIndex] : null;

    final displayName = activeVariant != null
        ? '${widget.product.name} - ${activeVariant.name}'
        : widget.product.name;
    final unitPrice = activeVariant?.price ?? widget.product.price;
    final displayPrice = activeVariant?.price != null
        ? '₽${AppTheme.formatPrice(activeVariant!.price!)}'
        : widget.product.formattedPrice;
    final displayDescription =
        activeVariant?.description ?? widget.product.description;
    final displayStock = activeVariant?.stock ?? widget.product.stock;

    final String imagePath = (activeVariant?.imagePath != null &&
            activeVariant!.imagePath!.isNotEmpty)
        ? activeVariant.imagePath!
        : widget.product.imagePath;

    final isNetworkImage = imagePath.startsWith('http');
    final hasRealImage = imagePath.isNotEmpty;
    final totalPrice = unitPrice * _quantity;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            _bannerTimer?.cancel();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(
          widget.product.category,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? AppTheme.pogoValorRed : colorScheme.onSurface,
            ),
            tooltip: _isFavorite ? 'Remove from Wishlist' : 'Add to Wishlist',
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: cart.isNotEmpty,
              backgroundColor: AppTheme.pogoValorRed,
              label: Text('${cart.totalItemCount}'),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: AppTheme.pogoTealPrimary,
              ),
            ),
            tooltip: 'Shopping Cart',
            onPressed: () {
              _bannerTimer?.cancel();
              context.go('/cart');
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Product Image Showcase
                Container(
                  width: double.infinity,
                  height: 260,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withAlpha(50),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.outline.withAlpha(50),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: hasRealImage
                        ? (isNetworkImage
                            ? Image.network(
                                imagePath,
                                height: 200,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.catching_pokemon,
                                  size: 100,
                                  color: AppTheme.pogoTealPrimary,
                                ),
                              )
                            : Image.asset(
                                imagePath,
                                height: 200,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.catching_pokemon,
                                  size: 100,
                                  color: AppTheme.pogoTealPrimary,
                                ),
                              ))
                        : const Icon(
                            Icons.catching_pokemon,
                            size: 100,
                            color: AppTheme.pogoTealPrimary,
                          ),
                  ),
                ),
                const SizedBox(height: 18),

                // 2. Category badge & Authenticity Chip
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.pogoTealPrimary.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.product.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.pogoTealPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4AC490).withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'POKÉMART OFFICIAL',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2E8B57),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 3. Product Name & Pricing
                Text(
                  displayName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppTheme.pogoTextPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      displayPrice,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.pogoTealPrimary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      '${widget.product.soldCount} sold',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.pogoTextSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: displayStock > 10
                            ? const Color(0xFF4AC490).withAlpha(25)
                            : AppTheme.pogoValorRed.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        displayStock > 0
                            ? '$displayStock in stock'
                            : 'Out of stock',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: displayStock > 10
                              ? const Color(0xFF2E8B57)
                              : AppTheme.pogoValorRed,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 4. Product Variations (if applicable)
                if (hasVariants) ...[
                  Text(
                    'Select Variation:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.pogoTextPrimary,
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
                        return ChoiceChip(
                          selected: isSelected,
                          label: Text(variant.name),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : colorScheme.onSurface,
                          ),
                          selectedColor: AppTheme.pogoTealPrimary,
                          backgroundColor: colorScheme.surface,
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.pogoTealPrimary
                                : colorScheme.outline.withAlpha(80),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedVariantIndex = index;
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // 5. Product Description & Specifications
                Card(
                  elevation: 0,
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: colorScheme.outline.withAlpha(60),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product Description',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.pogoTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          displayDescription,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: AppTheme.pogoTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating notification banner
          if (_showBanner)
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(14),
                color: AppTheme.pogoTealPrimary,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _bannerMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          setState(() => _showBanner = false);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      // Sticky Bottom Purchasing Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: colorScheme.outline.withAlpha(60),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Quantity Selector
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorScheme.outline.withAlpha(80),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      onPressed: _quantity < displayStock
                          ? () => setState(() => _quantity++)
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Total Price Preview
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Price',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.pogoTextSecondary,
                    ),
                  ),
                  Text(
                    '₽${AppTheme.formatPrice(totalPrice)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.pogoTealPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Add to Cart Action Button
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.pogoTealPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  onPressed: displayStock > 0
                      ? () {
                          cart.addItem(
                            widget.product,
                            activeVariant,
                            _quantity,
                          );
                          final variantNote = activeVariant != null
                              ? ' (${activeVariant.name})'
                              : '';

                          _bannerTimer?.cancel();
                          setState(() {
                            _bannerMessage =
                                'Added $_quantity × ${widget.product.name}$variantNote to cart';
                            _showBanner = true;
                            _quantity = 1;
                          });

                          _bannerTimer = Timer(const Duration(seconds: 4), () {
                            if (mounted) {
                              setState(() => _showBanner = false);
                            }
                          });
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
