import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

/// Product card designed with authentic Pokémon GO UI conventions:
/// - 22px rounded white card with subtle mint shadow
/// - Circular asset pedestal with concentric ring accents
/// - High-resolution 3D datamined PokeMiners model render
/// - PoGO category pill with pocket accent
/// - PokéDollar price tag and quick "+" action circle
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
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

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: colorScheme.outline, width: 1.5),
      ),
      child: InkWell(
        onTap: () {
          context.go('/product/${product.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product image: 1:1 ratio with PoGO circular pedestal
              AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withAlpha(160),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withAlpha(70),
                      width: 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Concentric subtle circular pedestal ring (as seen in PoGO Shop)
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(180),
                          border: Border.all(
                            color: categoryAccentColor.withAlpha(40),
                            width: 2,
                          ),
                        ),
                      ),
                      Center(
                        child: hasImage
                            ? (isNetworkImage
                                ? Image.network(
                                    product.imagePath,
                                    width: 76,
                                    height: 76,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.catching_pokemon,
                                        size: 40,
                                        color: AppTheme.pogoTealPrimary,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    product.imagePath,
                                    width: 76,
                                    height: 76,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.catching_pokemon,
                                        size: 40,
                                        color: AppTheme.pogoTealPrimary,
                                      );
                                    },
                                  ))
                            : const Icon(
                                Icons.catching_pokemon,
                                size: 40,
                                color: AppTheme.pogoTealPrimary,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // PoGO rounded category pill badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: categoryAccentColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: categoryAccentColor.withAlpha(60),
                    width: 1,
                  ),
                ),
                child: Text(
                  product.category.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: categoryAccentColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Product name (capped at 2 lines)
              SizedBox(
                height: 32,
                child: Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Price and stock status row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.formattedPrice,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.pogoTealPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: product.stock > 0
                              ? AppTheme.pogoMintEnd
                              : AppTheme.pogoValorRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '× ${product.stock}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface.withAlpha(160),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
