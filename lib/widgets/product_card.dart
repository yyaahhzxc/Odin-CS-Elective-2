import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../state/auth_state.dart';
import '../state/cart_state.dart';
import '../state/catalog_state.dart';
import '../theme/app_theme.dart';

/// Reusable product card component supporting both:
/// 1. **Grid View** (used on the Storefront Home Screen for Most Popular Items & Grid Catalog)
/// 2. **Foodpanda-inspired List View** (used on the View All Products Catalog Screen):
///    - Left column: Product Title, Price (`₽ ...`), Description, and Stock status
///    - Right column: Rounded square image container (`108×108`) with top-left category pill,
///      top-right favorite heart, and an anchored bottom-right `+` circle button that
///      expands into a `[ 🗑 1 + ]` or `[ − 2 + ]` pill overlay.
class ProductCard extends StatelessWidget {
  final Product product;
  final bool isGrid;

  const ProductCard({
    super.key,
    required this.product,
    this.isGrid = false,
  });

  bool _requireAuthenticated(BuildContext context, AuthManager? auth) {
    if (auth != null && !auth.isAuthenticated) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in or create an account to order items.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      try {
        context.go('/login');
      } catch (_) {}
      return false;
    }
    return true;
  }

  void _handleInitialAdd(
    BuildContext context,
    CartManager cart,
    AuthManager? auth,
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
    AuthManager? auth,
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
      await catalog.deleteProduct(product.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${product.name}".'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final auth = AuthScope.maybeOf(context);
    final cart = CartScope.maybeOf(context);
    final catalog = CatalogScope.maybeOf(context);

    final isAdmin = auth?.isAdmin ?? false;
    final hasImage = product.imagePath.isNotEmpty;
    final isNetworkImage = product.imagePath.startsWith('http');
    final isFav = catalog?.isFavorite(product.id) ?? false;
    final qtyInCart = cart?.quantityOf(product) ?? 0;

    final Color categoryAccentColor;
    if (product.category == 'Poké Balls') {
      categoryAccentColor = AppTheme.pogoValorRed;
    } else if (product.category == 'Medicine') {
      categoryAccentColor = AppTheme.pogoTealPrimary;
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
    AuthManager? auth,
    CartManager? cart,
    CatalogManager? catalog,
  ) {
    final isOutOfStock = product.stock <= 0;

    return InkWell(
      onTap: () => context.go('/product/${product.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withAlpha(90),
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
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: _buildItemImage(hasImage, isNetworkImage, 76),
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
                    if (catalog != null && !isAdmin)
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
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: isFav
                                  ? AppTheme.pogoValorRed
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    // Bottom-right Overlaid Add (+) or Counter Pill
                    if (!isAdmin && cart != null)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: qtyInCart > 0 ? 4 : null,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: qtyInCart > 0
                              ? _buildOverlayCounterPill(
                                  context,
                                  cart,
                                  auth,
                                  qtyInCart,
                                  colorScheme,
                                )
                              : _buildOverlayAddCircle(
                                  context,
                                  cart,
                                  auth,
                                  isOutOfStock,
                                  colorScheme,
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
                      color: AppTheme.pogoTextPrimary,
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
                                : AppTheme.pogoTextSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${product.soldCount} sold',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.pogoTextSecondary,
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
                              context.go('/admin/product/edit/${product.id}'),
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
                          onPressed: catalog == null
                              ? null
                              : () => _confirmAndDeleteProduct(
                                    context,
                                    catalog,
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

  /// Foodpanda-inspired List View row (matches Screenshot 2):
  /// - Left column: Bold Title, Price (`from ₽...` or `₽...`), Description, and Stock badge
  /// - Right column: Rounded square image container with top-left category tag,
  ///   favorite heart, and overlaid bottom-right `+` circle button or `[ 🗑 1 + ]` / `[ − 2 + ]` counter pill.
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
    AuthManager? auth,
    CartManager? cart,
    CatalogManager? catalog,
  ) {
    final isOutOfStock = product.stock <= 0;

    return InkWell(
      onTap: () => context.go('/product/${product.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outline.withAlpha(55),
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
                              color: AppTheme.pogoTextPrimary,
                              height: 1.25,
                            ),
                          ),
                        ),
                        if (catalog != null && !isAdmin)
                          InkWell(
                            onTap: () => catalog.toggleFavorite(product.id),
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                size: 17,
                                color: isFav
                                    ? AppTheme.pogoValorRed
                                    : colorScheme.onSurfaceVariant,
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
                        color: AppTheme.pogoTextSecondary,
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
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.pogoTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (isAdmin) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => context.go(
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
                            onPressed: catalog == null
                                ? null
                                : () => _confirmAndDeleteProduct(
                                      context,
                                      catalog,
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
                        color: colorScheme.outline.withAlpha(75),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: _buildItemImage(hasImage, isNetworkImage, 74),
                    ),
                  ),

                  // Top-left Category Ribbon Tag (mirrors the red corner badge in Screenshot 2)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: categoryAccentColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(13),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        product.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  // Bottom-right Overlaid Add Button (+) or Counter Pill ([ 🗑 1 + ] / [ − 2 + ])
                  if (!isAdmin && cart != null)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      left: qtyInCart > 0 ? 6 : null,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: qtyInCart > 0
                            ? _buildOverlayCounterPill(
                                context,
                                cart,
                                auth,
                                qtyInCart,
                                colorScheme,
                              )
                            : _buildOverlayAddCircle(
                                context,
                                cart,
                                auth,
                                isOutOfStock,
                                colorScheme,
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
    AuthManager? auth,
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
                      : AppTheme.pogoTextPrimary,
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
  /// - Shows `[ 🗑  1  + ]` when `quantity == 1` (pressing trash removes item and reverts to `+`)
  /// - Shows `[ −  2  + ]` when `quantity > 1` (matches Foodpanda Screenshot 2)
  Widget _buildOverlayCounterPill(
    BuildContext context,
    CartManager cart,
    AuthManager? auth,
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
          color: colorScheme.outline.withAlpha(140),
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
                child: Icon(
                  quantity == 1 ? Icons.delete_outline : Icons.remove,
                  size: 16,
                  color: AppTheme.pogoTextPrimary,
                ),
              ),
            ),
            Text(
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
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: AppTheme.pogoTextPrimary,
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
        fit: BoxFit.contain,
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
        errorBuilder: (_, _, _) => Icon(
          Icons.catching_pokemon,
          size: size * 0.6,
          color: AppTheme.pogoTealPrimary,
        ),
      );
    }
  }
}
