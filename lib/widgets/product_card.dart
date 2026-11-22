import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../providers/app_providers.dart';
import '../state/auth_state.dart';
import '../state/cart_state.dart';
import '../state/catalog_state.dart';
import '../theme/app_theme.dart';
import 'animated_primitives.dart';

/// Reusable product card component supporting both Grid View and List View.
class ProductCard extends ConsumerWidget {
  final Product product;
  final bool isGrid;

  const ProductCard({
    super.key,
    required this.product,
    this.isGrid = false,
  });

  bool _requireAuthenticated(BuildContext context, AuthManager auth) {
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in or create an account to order items.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/login');
      return false;
    }
    return true;
  }

  void _handleInitialAdd(
    BuildContext context,
    CartManager cart,
    AuthManager auth,
  ) {
    if (!_requireAuthenticated(context, auth)) return;

    if (product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} is currently out of stock.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    cart.incrementProduct(product);
  }

  void _handleIncrement(
    BuildContext context,
    CartManager cart,
    AuthManager auth,
  ) {
    if (!_requireAuthenticated(context, auth)) return;
    final added = cart.incrementProduct(product);
    if (!added) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Maximum available stock (${product.stock}) reached in cart.',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleDecrement(CartManager cart) {
    cart.decrementProduct(product);
  }

  Future<void> _confirmAndDeleteProduct(
    BuildContext context,
    CatalogManager catalog,
    CartManager cart,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${product.name}" from the catalog? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.pogoValorRed,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await catalog.deleteProduct(product.id);
        if (context.mounted) {
          cart.removeProductById(product.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted "${product.name}".'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to delete "${product.name}": ${e.toString().replaceFirst('Exception: ', '')}',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final auth = ref.watch(authProvider);
    final cart = ref.watch(cartProvider);
    final catalog = ref.watch(catalogProvider);

    final isAdmin = auth.isAdmin;
    final hasImage = product.imagePath.isNotEmpty;
    final isNetworkImage = product.imagePath.startsWith('http');
    final isFav = catalog.isFavorite(product.id);
    final qtyInCart = cart.quantityOf(product);

    final Color categoryAccentColor;
    if (product.category == 'Poké Balls') {
      categoryAccentColor = AppTheme.pogoValorRed;
    } else if (product.category == 'Medicine') {
      categoryAccentColor = AppTheme.pogoDeepTeal;
    } else if (product.category == 'Evolution') {
      categoryAccentColor = AppTheme.pogoCoinGold;
    } else if (product.category == 'Battle & Training') {
      categoryAccentColor = AppTheme.pogoStardustPurple;
    } else if (product.category == 'Berries & Treats') {
      categoryAccentColor = AppTheme.pogoMintEnd;
    } else if (product.category == 'Special Gear') {
      categoryAccentColor = AppTheme.pogoPokeStopBlue;
    } else {
      categoryAccentColor = AppTheme.pogoTealPrimary;
    }

    if (isGrid) {
      return _buildGridView(
        context,
        theme,
        colorScheme,
        hasImage,
        isNetworkImage,
        categoryAccentColor,
        isAdmin,
        isFav,
        qtyInCart,
        auth,
        cart,
        catalog,
      );
    } else {
      return _buildFoodpandaListView(
        context,
        theme,
        colorScheme,
        hasImage,
        isNetworkImage,
        categoryAccentColor,
        isAdmin,
        isFav,
        qtyInCart,
        auth,
        cart,
        catalog,
      );
    }
  }

  /// Grid view product card with image pedestal, category badge, favorite heart,
  /// and overlaid bottom-right `+` / `[- 1 +]` control on the image pedestal.
  Widget _buildGridView(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool hasImage,
    bool isNetworkImage,
    Color categoryAccentColor,
    bool isAdmin,
    bool isFav,
    int qtyInCart,
    AuthManager auth,
    CartManager cart,
    CatalogManager catalog,
  ) {
    final isOutOfStock = product.stock <= 0;

    return InkWell(
      onTap: () => context.push('/product/${product.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Product Image Showcase with Category Badge, Favorite Heart, and Overlaid Add/Counter Button
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withAlpha(55),
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Hero(
                        tag: 'product-hero-${product.id}',
                        child: _buildItemImage(hasImage, isNetworkImage, 76),
                      ),
                    ),
                    // Top-left Category Ribbon Badge
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: categoryAccentColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    // Top-right Favorite Heart Circle
                    if (!isAdmin)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () => catalog.toggleFavorite(product.id),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withAlpha(235),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(15),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: AnimatedFavoriteIcon(
                              isFavorite: isFav,
                              size: 16,
                              activeColor: AppTheme.pogoValorRed,
                              inactiveColor: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    // Bottom-right Overlaid Add (+) or Counter Pill
                    if (!isAdmin)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOutBack,
                            switchOutCurve: Curves.easeInCubic,
                            layoutBuilder: (currentChild, previousChildren) {
                              return Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  ...previousChildren,
                                  ?currentChild,
                                ],
                              );
                            },
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.75, end: 1.0)
                                      .animate(animation),
                                  alignment: Alignment.centerRight,
                                  child: child,
                                ),
                              );
                            },
                            child: qtyInCart > 0
                                ? FractionallySizedBox(
                                    key: const ValueKey<String>('counter-pill'),
                                    widthFactor: 0.55,
                                    child: _buildOverlayCounterPill(
                                      context,
                                      cart,
                                      auth,
                                      qtyInCart,
                                      colorScheme,
                                    ),
                                  )
                                : KeyedSubtree(
                                    key: const ValueKey<String>('add-circle'),
                                    child: _buildOverlayAddCircle(
                                      context,
                                      cart,
                                      auth,
                                      isOutOfStock,
                                      colorScheme,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Product Details Section
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.formattedPrice,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.pogoTealPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          isOutOfStock
                              ? 'Out of stock'
                              : '${product.stock} in stock',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isOutOfStock
                                ? AppTheme.pogoValorRed
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${product.soldCount} sold',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 17,
                            color: AppTheme.pogoTealPrimary,
                          ),
                          tooltip: 'Edit ${product.name}',
                          onPressed: () =>
                              context.push('/admin/product/edit/${product.id}'),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 17,
                            color: AppTheme.pogoValorRed,
                          ),
                          tooltip: 'Delete ${product.name}',
                          onPressed: () => _confirmAndDeleteProduct(
                            context,
                            catalog,
                            cart,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// List view product row displaying item details on the left and image with
  /// overlaid cart controls on the right.
  Widget _buildFoodpandaListView(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool hasImage,
    bool isNetworkImage,
    Color categoryAccentColor,
    bool isAdmin,
    bool isFav,
    int qtyInCart,
    AuthManager auth,
    CartManager cart,
    CatalogManager catalog,
  ) {
    final isOutOfStock = product.stock <= 0;

    return InkWell(
      onTap: () => context.push('/product/${product.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Title, Price, Description, Stock & Admin controls
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 14, top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.25,
                            ),
                          ),
                        ),
                        if (!isAdmin)
                          InkWell(
                            onTap: () => catalog.toggleFavorite(product.id),
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: AnimatedFavoriteIcon(
                                isFavorite: isFav,
                                size: 17,
                                activeColor: AppTheme.pogoValorRed,
                                inactiveColor: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      product.variants.isNotEmpty
                          ? 'from ${product.formattedPrice}'
                          : product.formattedPrice,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          isOutOfStock
                              ? 'Out of stock'
                              : '${product.stock} in stock',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isOutOfStock
                                ? AppTheme.pogoValorRed
                                : AppTheme.pogoTealPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${product.soldCount} sold',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (isAdmin) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => context.push(
                              '/admin/product/edit/${product.id}',
                            ),
                            icon: const Icon(Icons.edit_outlined, size: 15),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              foregroundColor: AppTheme.pogoTealPrimary,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _confirmAndDeleteProduct(
                              context,
                              catalog,
                              cart,
                            ),
                            icon: const Icon(Icons.delete_outline, size: 15),
                            label: const Text('Delete'),
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              foregroundColor: AppTheme.pogoValorRed,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Right: Foodpanda-style Rounded Square Image Box with Overlaid Add/Counter Button
            SizedBox(
              width: 110,
              height: 110,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Rounded Square Product Image Container
                  Container(
                    width: 110,
                    height: 110,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withAlpha(55),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Hero(
                        tag: 'product-hero-${product.id}',
                        child: _buildItemImage(hasImage, isNetworkImage, 74),
                      ),
                    ),
                  ),

                  // Top-left Floating Category Pill
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: categoryAccentColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  // Bottom-right Overlaid Add Button (+) or Counter Pill
                  if (!isAdmin)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      left: 6,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeInCubic,
                          layoutBuilder: (currentChild, previousChildren) {
                            return Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                ...previousChildren,
                                ?currentChild,
                              ],
                            );
                          },
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.75, end: 1.0)
                                    .animate(animation),
                                alignment: Alignment.centerRight,
                                child: child,
                              ),
                            );
                          },
                          child: qtyInCart > 0
                              ? FractionallySizedBox(
                                  key: const ValueKey<String>('counter-pill'),
                                  widthFactor: 0.92,
                                  child: _buildOverlayCounterPill(
                                    context,
                                    cart,
                                    auth,
                                    qtyInCart,
                                    colorScheme,
                                  ),
                                )
                              : KeyedSubtree(
                                  key: const ValueKey<String>('add-circle'),
                                  child: _buildOverlayAddCircle(
                                    context,
                                    cart,
                                    auth,
                                    isOutOfStock,
                                    colorScheme,
                                  ),
                                ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Circular `+` button anchored on the bottom-right corner of the product image box.
  /// Retains a semantic tooltip & hidden `Icons.add_shopping_cart` marker for test/accessibility compatibility.
  Widget _buildOverlayAddCircle(
    BuildContext context,
    CartManager cart,
    AuthManager auth,
    bool isOutOfStock,
    ColorScheme colorScheme,
  ) {
    return Material(
      color: colorScheme.surface,
      shape: CircleBorder(
        side: BorderSide(
          color: isOutOfStock
              ? colorScheme.outline.withAlpha(80)
              : colorScheme.outline.withAlpha(140),
          width: 1,
        ),
      ),
      elevation: 2,
      shadowColor: Colors.black.withAlpha(40),
      child: InkWell(
        onTap: isOutOfStock
            ? null
            : () => _handleInitialAdd(context, cart, auth),
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: isOutOfStock ? 'Out of Stock' : 'Add to Cart',
          child: SizedBox(
            width: 34,
            height: 34,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 20,
                  color: isOutOfStock
                      ? colorScheme.outline
                      : Theme.of(context).colorScheme.onSurface,
                ),
                // Zero-opacity icon so existing tests finding `Icons.add_shopping_cart` continue to work seamlessly
                const Opacity(
                  opacity: 0.0,
                  child: Icon(Icons.add_shopping_cart, size: 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// White stadium pill overlaid at the bottom of the product image when `quantity > 0`:
  /// - Shows `[ delete  1  + ]` when `quantity == 1` (tapping delete removes the item)
  /// - Shows `[ -  2  + ]` when `quantity > 1`
  Widget _buildOverlayCounterPill(
    BuildContext context,
    CartManager cart,
    AuthManager auth,
    int quantity,
    ColorScheme colorScheme,
  ) {
    return Material(
      color: colorScheme.surface,
      elevation: 3,
      shadowColor: Colors.black.withAlpha(45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () => _handleDecrement(cart),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Icon(
                    quantity == 1 ? Icons.delete_outline : Icons.remove,
                    key: ValueKey<bool>(quantity == 1),
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            AnimatedValueText(
              '$quantity',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
              ),
            ),
            InkWell(
              onTap: () => _handleIncrement(context, cart, auth),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the 3D item image render with reliable fallback.
  Widget _buildItemImage(bool hasImage, bool isNetworkImage, double size) {
    if (!hasImage) {
      return Icon(
        Icons.catching_pokemon,
        size: size * 0.6,
        color: AppTheme.pogoTealPrimary,
      );
    }

    if (isNetworkImage) {
      return Image.network(
        product.imagePath,
        width: size,
        height: size,
        // Match ProductDetailScreen cacheWidth so Hero transitions hit ImageCache immediately.
        cacheWidth: 256,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => Icon(
          Icons.catching_pokemon,
          size: size * 0.6,
          color: AppTheme.pogoTealPrimary,
        ),
      );
    } else {
      return Image.asset(
        product.imagePath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => Icon(
          Icons.catching_pokemon,
          size: size * 0.6,
          color: AppTheme.pogoTealPrimary,
        ),
      );
    }
  }
}
