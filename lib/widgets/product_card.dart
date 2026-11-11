import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

/// Product card/tile designed with authentic Pokémon GO UI conventions:
/// - List View: Matches the PoGO Items (Bag) list view (Image 1 left) with
///   3D item asset, translucent quantity chip (x9), bold title, lore description,
///   and right-aligned price and bag action.
/// - Grid View: Matches the PoGO Items 3-column grid view (Image 1 right) with
///   top-right action icon, centered 3D asset, bottom-left quantity chip, and
///   centered item title and price.
class ProductCard extends StatelessWidget {
  final Product product;
  final bool isGrid;

  const ProductCard({
    super.key,
    required this.product,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasImage = product.imagePath.isNotEmpty;
    final isNetworkImage = product.imagePath.startsWith('http');

    // Distinct accent color depending on Bag Pocket category (PoGO style)
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
      return _buildGridView(context, theme, colorScheme, hasImage, isNetworkImage, categoryAccentColor);
    } else {
      return _buildListView(context, theme, colorScheme, hasImage, isNetworkImage, categoryAccentColor);
    }
  }

  /// 3-Column Grid View item matching the authentic PoGO Bag grid layout (Image 1 right).
  Widget _buildGridView(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool hasImage,
    bool isNetworkImage,
    Color categoryAccentColor,
  ) {
    return InkWell(
      onTap: () => context.go('/product/${product.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withAlpha(60),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top action bar (trash/cart icon at top right)
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                Icons.delete_outline,
                size: 16,
                color: AppTheme.pogoTextSecondary.withAlpha(160),
              ),
            ),

            // Item graphic with bottom-left quantity pill (e.g. x500)
            SizedBox(
              width: 68,
              height: 68,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildItemImage(hasImage, isNetworkImage, 60),
                  Positioned(
                    bottom: 0,
                    left: 2,
                    child: _buildQuantityPill(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Item Name centered underneath (bold, matching PoGO Lato)
            Text(
              product.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.pogoTextPrimary,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 2),

            // Price readout
            Text(
              product.formattedPrice,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppTheme.pogoTealPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// List View item matching the authentic PoGO Bag list layout (Image 1 left).
  Widget _buildListView(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool hasImage,
    bool isNetworkImage,
    Color categoryAccentColor,
  ) {
    return InkWell(
      onTap: () => context.go('/product/${product.id}'),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outline.withAlpha(70),
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
            // Left: 3D Item graphic with bottom-left quantity chip (x9)
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildItemImage(hasImage, isNetworkImage, 64),
                  Positioned(
                    bottom: 2,
                    left: 2,
                    child: _buildQuantityPill(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Middle: Name and Lore description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.pogoTextPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: categoryAccentColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            color: categoryAccentColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: AppTheme.pogoTextSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.formattedPrice,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.pogoTealPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Right: Trash / Action icon (as in PoGO bag)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppTheme.pogoTextSecondary,
                size: 20,
              ),
              tooltip: 'Item Options',
              onPressed: () => context.go('/product/${product.id}'),
            ),
          ],
        ),
      ),
    );
  }

  /// Translucent quantity chip matching PoGO bag items (e.g. x9, x500, x440).
  Widget _buildQuantityPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.black.withAlpha(25),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        'x${product.stock}',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppTheme.pogoTextPrimary,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  /// Builds the 3D item image render.
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
