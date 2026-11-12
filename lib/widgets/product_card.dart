import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

/// Reusable product card component supporting both responsive grid and list layouts.
/// Follows modern e-commerce UI conventions with crisp typography, stock indicators,
/// category badges, and distinct pricing hierarchy.
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
      );
    } else {
      return _buildListView(
        context,
        theme,
        colorScheme,
        hasImage,
        isNetworkImage,
        categoryAccentColor,
      );
    }
  }

  /// Grid view product card with image pedestal, category badge, stock status, and price.
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
                padding: const EdgeInsets.all(12),
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
                      child: _buildItemImage(hasImage, isNetworkImage, 82),
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

            // Product Details Section
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.pogoTealPrimary,
                        ),
                      ),
                      Text(
                        '${product.stock} in stock',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.pogoTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// List view product card with horizontal layout, description, and pricing breakdown.
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
                            color: AppTheme.pogoTextSecondary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${product.stock} in stock',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.pogoTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Right: Navigation arrow icon
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
