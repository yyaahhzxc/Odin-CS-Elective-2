import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_primitives.dart';

/// Screen displaying comprehensive details for a selected product.
class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  final Product? initialProduct;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _selectedVariantIndex = 0;
  int _quantity = 1;

  bool _showBanner = false;
  String _bannerMessage = '';
  Timer? _bannerTimer;

  Product? _fetchedProduct;
  bool _isLoadingProduct = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct == null &&
        ref.read(catalogProvider).findProductById(widget.productId) == null) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoadingProduct = true;
      _loadError = null;
    });

    try {
      final product =
          await ref.read(catalogProvider).findOrFetchProduct(widget.productId);
      if (mounted) {
        setState(() {
          _fetchedProduct = product;
          _isLoadingProduct = false;
        });
      }
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
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cart = ref.watch(cartProvider);
    final auth = ref.watch(authProvider);
    final catalog = ref.watch(catalogProvider);
    final isAdmin = auth.isAdmin;

    final liveProduct = catalog.findProductById(widget.productId) ??
        _fetchedProduct ??
        widget.initialProduct;

    if (liveProduct == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
          title: const Text('Product Details'),
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
                        _loadError != null
                            ? Icons.error_outline
                            : Icons.inventory_2_outlined,
                        size: 56,
                        color: _loadError != null
                            ? colorScheme.error
                            : colorScheme.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _loadError ?? 'Product not found.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      if (_loadError != null)
                        FilledButton.icon(
                          onPressed: _loadProduct,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        )
                      else
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

    final isFavorite = catalog.isFavorite(liveProduct.id);

    final hasVariants = liveProduct.variants.isNotEmpty;
    final safeVariantIndex =
        hasVariants ? _selectedVariantIndex.clamp(0, liveProduct.variants.length - 1) : 0;
    final activeVariant =
        hasVariants ? liveProduct.variants[safeVariantIndex] : null;

    final displayName = activeVariant != null
        ? '${liveProduct.name} - ${activeVariant.name}'
        : liveProduct.name;
    final unitPrice = activeVariant?.price ?? liveProduct.price;
    final displayPrice = activeVariant?.price != null
        ? '₽${AppTheme.formatPrice(activeVariant!.price!)}'
        : liveProduct.formattedPrice;
    final displayDescription =
        activeVariant?.description ?? liveProduct.description;
    final displayStock = activeVariant?.stock ?? liveProduct.stock;

    final String imagePath = (activeVariant?.imagePath != null &&
            activeVariant!.imagePath!.isNotEmpty)
        ? activeVariant.imagePath!
        : liveProduct.imagePath;

    final isNetworkImage = imagePath.startsWith('http');
    final hasRealImage = imagePath.isNotEmpty;
    final alreadyInCart = cart.quantityOfVariant(liveProduct, activeVariant);
    final remainingStock = (displayStock - alreadyInCart).clamp(0, displayStock);
    final effectiveQty = remainingStock > 0 ? _quantity.clamp(1, remainingStock) : 1;
    final totalPrice = unitPrice * effectiveQty;

    return Scaffold(
      appBar: AppBar(
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
          liveProduct.category,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (!isAdmin) ...[
            IconButton(
              icon: Badge(
                isLabelVisible: cart.isNotEmpty,
                backgroundColor: AppTheme.pogoValorRed,
                label: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutBack,
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: Tween<double>(begin: 0.6, end: 1.0).animate(animation),
                    child: child,
                  ),
                  child: Text(
                    '${cart.totalItemCount}',
                    key: ValueKey<int>(cart.totalItemCount),
                  ),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: colorScheme.primary,
                ),
              ),
              tooltip: 'Shopping Cart',
              onPressed: () {
                _bannerTimer?.cancel();
                context.push('/cart');
              },
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Product Image Showcase (Compact to avoid sprite pixelation)
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withAlpha(65),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppTheme.pogoTealPrimary.withAlpha(140),
                      width: 1.8,
                    ),
                  ),
                  child: Center(
                    child: Hero(
                      tag: 'product-hero-${liveProduct.id}',
                      child: hasVariants
                          ? AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              switchInCurve: Curves.easeOutCubic,
                              child: KeyedSubtree(
                                key: ValueKey<String>(imagePath),
                                child: _buildShowcaseImage(
                                  hasRealImage,
                                  isNetworkImage,
                                  imagePath,
                                ),
                              ),
                            )
                          : _buildShowcaseImage(
                              hasRealImage,
                              isNetworkImage,
                              imagePath,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2 & 3. Product Header & Pricing Container with distinct boundary outline
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge + Favorite toggle pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withAlpha(22),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: colorScheme.primary.withAlpha(110),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              liveProduct.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (!isAdmin)
                            Tooltip(
                              message: isFavorite
                                  ? 'Remove from Wishlist'
                                  : 'Add to Wishlist',
                              child: InkWell(
                                onTap: () =>
                                    catalog.toggleFavorite(liveProduct.id),
                                borderRadius: BorderRadius.circular(20),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOutCubic,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isFavorite
                                        ? AppTheme.pogoValorRed.withAlpha(22)
                                        : colorScheme.surfaceContainerHighest
                                            .withAlpha(90),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isFavorite
                                          ? AppTheme.pogoValorRed
                                          : colorScheme.outlineVariant,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AnimatedFavoriteIcon(
                                        isFavorite: isFavorite,
                                        size: 16,
                                        activeColor: AppTheme.pogoValorRed,
                                        inactiveColor:
                                            colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        isFavorite ? 'Saved' : 'Favorite',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w800,
                                          color: isFavorite
                                              ? AppTheme.pogoValorRed
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Product Name & Pricing
                      Text(
                        displayName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 6,
                        children: [
                          Text(
                            displayPrice,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.pogoTealPrimary,
                            ),
                          ),
                          Text(
                            '${liveProduct.soldCount} sold',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
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
                              border: Border.all(
                                color: displayStock > 10
                                    ? const Color(0xFF2E8B57).withAlpha(120)
                                    : AppTheme.pogoValorRed.withAlpha(120),
                              ),
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
                          if (alreadyInCart > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.pogoTealPrimary.withAlpha(22),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppTheme.pogoTealPrimary.withAlpha(90),
                                ),
                              ),
                              child: Text(
                                '$alreadyInCart in cart',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.pogoTealPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      ],
                    ),
                ),
                const SizedBox(height: 16),

                // 4. Product Variations (if applicable)
                if (hasVariants) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Variation:',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                            liveProduct.variants.length,
                            (index) {
                              final isSelected = safeVariantIndex == index;
                              final variant = liveProduct.variants[index];
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
                                      : colorScheme.outlineVariant,
                                  width: 1.4,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    final nextStock =
                                        variant.stock ?? liveProduct.stock;
                                    final nextInCart = cart.quantityOfVariant(
                                      liveProduct,
                                      variant,
                                    );
                                    final nextRemaining =
                                        (nextStock - nextInCart)
                                            .clamp(0, nextStock);
                                    setState(() {
                                      _selectedVariantIndex = index;
                                      _quantity = nextRemaining > 0
                                          ? _quantity.clamp(1, nextRemaining)
                                          : 1;
                                    });
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 5. Product Description & Specifications
                Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: 1.5,
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
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          displayDescription,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isAdmin) ...[
                  const SizedBox(height: 16),

                  // 6. Quantity Selector & Total Price Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quantity',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              remainingStock > 0
                                  ? '$remainingStock available to add'
                                  : 'Max stock in cart',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: remainingStock > 0
                                    ? colorScheme.onSurfaceVariant
                                    : AppTheme.pogoCoinGold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: colorScheme.outlineVariant,
                                  width: 1.4,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 17),
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(),
                                    onPressed: effectiveQty > 1
                                        ? () => setState(
                                              () => _quantity = effectiveQty - 1,
                                            )
                                        : null,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: AnimatedValueText(
                                      '$effectiveQty',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 17),
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(),
                                    onPressed: effectiveQty < remainingStock
                                        ? () => setState(
                                              () => _quantity = effectiveQty + 1,
                                            )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total Price',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedValueText(
                              '₽${AppTheme.formatPrice(totalPrice)}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Floating notification banner with slide-down + fade animation
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.35),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _showBanner
                  ? Material(
                      key: ValueKey<String>(_bannerMessage),
                      elevation: 4,
                      borderRadius: BorderRadius.circular(14),
                      color: AppTheme.pogoTealPrimary,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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
                    )
                  : const SizedBox.shrink(
                      key: ValueKey<String>('banner-hidden'),
                    ),
            ),
          ),
        ],
      ),

      // Sticky Bottom Purchasing Bar (or Admin Edit Bar)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant,
              width: 1.5,
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
          child: isAdmin
              ? SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () => context.push(
                      '/admin/product/edit/${liveProduct.id}',
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text(
                      'Edit Product (Admin)',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.add_shopping_cart, size: 19),
                    label: const Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: displayStock > 0
                        ? () {
                            if (!auth.isAuthenticated) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please sign in to add items to your cart.',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              context.go('/login');
                              return;
                            }

                            final beforeQty =
                                cart.quantityOfVariant(liveProduct, activeVariant);
                            final success = cart.addItem(
                              liveProduct,
                              activeVariant,
                              effectiveQty,
                            );
                            final addedQty =
                                cart.quantityOfVariant(liveProduct, activeVariant) -
                                    beforeQty;

                            if (!success || addedQty <= 0) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Maximum available stock ($displayStock) is already in your cart.',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            final variantNote = activeVariant != null
                                ? ' (${activeVariant.name})'
                                : '';

                            _bannerTimer?.cancel();
                            setState(() {
                              _bannerMessage =
                                  'Added $addedQty × ${liveProduct.name}$variantNote to cart';
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
        ),
      ),
    );
  }

  Widget _buildShowcaseImage(
    bool hasRealImage,
    bool isNetworkImage,
    String imagePath,
  ) {
    if (!hasRealImage) {
      return const Icon(
        Icons.catching_pokemon,
        size: 70,
        color: AppTheme.pogoTealPrimary,
      );
    }

    if (isNetworkImage) {
      return Image.network(
        imagePath,
        height: 130,
        // Match ProductCard cacheWidth so Hero transitions reuse the cached bitmap with no flash.
        cacheWidth: 256,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => const Icon(
          Icons.catching_pokemon,
          size: 70,
          color: AppTheme.pogoTealPrimary,
        ),
      );
    }

    return Image.asset(
      imagePath,
      height: 130,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => const Icon(
        Icons.catching_pokemon,
        size: 70,
        color: AppTheme.pogoTealPrimary,
      ),
    );
  }
}
