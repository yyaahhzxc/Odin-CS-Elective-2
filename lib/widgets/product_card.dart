import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../state/auth_state.dart';
import '../state/cart_state.dart';
import '../state/catalog_state.dart';
import '../theme/app_theme.dart';

/// Reusable product card component supporting both responsive grid and list layouts,
/// as well as strict Role-Based UI separation:
/// - Customer role: Shows "Add to Cart" action button (disabled if out of stock),
///   and never shows Admin management controls.
/// - Admin role: Replaces customer cart controls with Edit & Delete buttons,
///   triggering a confirmation dialog naming the product before deletion.
class ProductCard extends StatelessWidget {
  final Product product;
  final bool isGrid;

  const ProductCard({
    super.key,
    required this.product,
    this.isGrid = false,
  });

  void _handleAddToCart(BuildContext context, CartManager cart) {
    if (product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} is currently out of stock.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final added = cart.addItem(product, null, 1);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? 'Added ${product.name} to cart!'
              : 'Maximum available stock (${product.stock}) reached in cart.',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
        cart,
        catalog,
      );
    } else {
      return _buildListView(
        context,
        theme,
        colorScheme,
        hasImage,
        isNetworkImage,
        categoryAccentColor,
        isAdmin,
        cart,
        catalog,
      );
    }
  }

  /// Grid view product card with image pedestal, category badge, stock status, price, and role actions.
  Widget _buildGridView(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool hasImage,
    bool isNetworkImage,
    Color categoryAccentColor,
    bool isAdmin,
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
            color: colorScheme.outline.withAlpha(50),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Product Image Showcase with Category Pill
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withAlpha(50),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: _buildItemImage(hasImage, isNetworkImage, 74),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: categoryAccentColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: categoryAccentColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Product Details & Role Actions Section
            Padding(
              padding: const EdgeInsets.all(10),
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
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.pogoTealPrimary,
                        ),
                      ),
                      Text(
                        isOutOfStock
                            ? 'Out of stock'
                            : '${product.stock} in stock',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isOutOfStock
                              ? AppTheme.pogoValorRed
                              : AppTheme.pogoTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Role-specific controls: Admin Edit/Delete vs Customer Add to Cart
                  if (isAdmin)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: AppTheme.pogoTealPrimary,
                          ),
                          tooltip: 'Edit ${product.name}',
                          onPressed: () =>
                              context.go('/admin/product/edit/${product.id}'),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
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
                    )
                  else if (cart != null)
                    SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: OutlinedButton.icon(
                        onPressed: isOutOfStock
                            ? null
                            : () => _handleAddToCart(context, cart),
                        icon: const Icon(Icons.add_shopping_cart, size: 14),
                        label: Text(
                          isOutOfStock ? 'Out of Stock' : 'Add to Cart',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          foregroundColor: AppTheme.pogoTealPrimary,
                          side: BorderSide(
                            color: isOutOfStock
                                ? colorScheme.outlineVariant
                                : AppTheme.pogoTealPrimary.withAlpha(120),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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

  /// List view product card with horizontal layout, description, pricing breakdown, and role controls.
  Widget _buildListView(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool hasImage,
    bool isNetworkImage,
    Color categoryAccentColor,
    bool isAdmin,
    CartManager? cart,
    CatalogManager? catalog,
  ) {
    final isOutOfStock = product.stock <= 0;

    return InkWell(
      onTap: () => context.go('/product/${product.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withAlpha(50),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Product Image on subtle pedestal
            Container(
              width: 76,
              height: 76,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _buildItemImage(hasImage, isNetworkImage, 64),
              ),
            ),
            const SizedBox(width: 14),

            // Middle: Product Title, Category, Lore, and Availability
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: categoryAccentColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: categoryAccentColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.pogoTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: AppTheme.pogoTextSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.pogoTealPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 13,
                            color: isOutOfStock
                                ? AppTheme.pogoValorRed
                                : AppTheme.pogoTextSecondary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isOutOfStock
                                ? 'Out of stock'
                                : '${product.stock} in stock',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isOutOfStock
                                  ? AppTheme.pogoValorRed
                                  : AppTheme.pogoTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Right: Role-specific action controls (Admin Edit & Delete vs Customer Add to Cart)
            if (isAdmin)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppTheme.pogoTealPrimary,
                      size: 20,
                    ),
                    tooltip: 'Edit ${product.name}',
                    onPressed: () =>
                        context.go('/admin/product/edit/${product.id}'),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppTheme.pogoValorRed,
                      size: 20,
                    ),
                    tooltip: 'Delete ${product.name}',
                    onPressed: catalog == null
                        ? null
                        : () => _confirmAndDeleteProduct(context, catalog),
                  ),
                ],
              )
            else if (cart != null)
              IconButton(
                icon: Icon(
                  Icons.add_shopping_cart,
                  color: isOutOfStock
                      ? colorScheme.outline
                      : AppTheme.pogoTealPrimary,
                  size: 20,
                ),
                tooltip: isOutOfStock ? 'Out of Stock' : 'Add to Cart',
                onPressed: isOutOfStock
                    ? null
                    : () => _handleAddToCart(context, cart),
              )
            else
              Icon(
                Icons.chevron_right,
                color: colorScheme.outline,
                size: 20,
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
