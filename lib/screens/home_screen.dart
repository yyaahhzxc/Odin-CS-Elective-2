import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/pogo_assets.dart';
import '../state/cart_state.dart';
import '../state/catalog_state.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';

/// Home screen displaying the PokéMart product catalog with Supabase-backed
/// price range filtering and offset pagination.
///
/// Designed with authentic Pokémon GO (PoGO / Niantic) UI conventions:
/// - Signature Teal-to-Mint horizon gradient banner
/// - Trainer HUD header with PokéCoin gold balance and concentric Bag button
/// - PoGO Bag Pocket category pill tabs
/// - High-resolution 3D item pedestals with real-time pagination
class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _categories = const [
    'All',
    'Poké Balls',
    'Medicine',
    'Evolution',
    'Berries & Treats',
    'Battle & Training',
    'Special Gear',
  ];

  // Local drag values for smooth slider interaction before triggering backend query
  RangeValues? _sliderValues;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final cart = CartScope.of(context);
    final catalog = CatalogScope.of(context);

    // Sync local slider values with catalog state if not actively dragging
    final activeSliderValues = _sliderValues ?? catalog.priceRange;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppTheme.pogoTealPrimary.withAlpha(25),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.pogoTealPrimary.withAlpha(50),
                  width: 1.5,
                ),
              ),
              child: Image.network(
                PogoAssets.btnShop,
                width: 22,
                height: 22,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.catching_pokemon,
                  color: AppTheme.pogoTealPrimary,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                style: theme.appBarTheme.titleTextStyle,
                children: const [
                  TextSpan(
                    text: 'POKÉ',
                    style: TextStyle(
                      color: AppTheme.pogoTealPrimary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  TextSpan(
                    text: 'MART',
                    style: TextStyle(
                      color: AppTheme.pogoTextPrimary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // PoGO Trainer Coin / Funds Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(160),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colorScheme.outline, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  PogoAssets.btnCoinsSmall,
                  width: 16,
                  height: 16,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.monetization_on,
                    color: AppTheme.pogoCoinGold,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '325,976',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.pogoCoinGold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Shopping Bag button (matching PoGO Rucksack Button master symbol)
          IconButton(
            icon: Badge(
              isLabelVisible: cart.isNotEmpty,
              backgroundColor: AppTheme.pogoValorRed,
              label: Text(
                '${cart.totalItemCount}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: AppTheme.pogoTealPrimary,
              ),
            ),
            tooltip: 'Trainer Bag / Cart',
            onPressed: () => context.go('/cart'),
          ),

          // Light/Dark mode toggle button
          IconButton(
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: AppTheme.pogoTealPrimary,
            ),
            tooltip: widget.isDarkMode
                ? 'Switch to Day Mode'
                : 'Switch to Stadium Night Mode',
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PoGO Signature Mint-to-Teal Horizon Hero Banner
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppTheme.horizonHeroGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.pogoTealPrimary.withAlpha(40),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Faint circular Poké Ball watermark in background
                    Positioned(
                      right: -25,
                      bottom: -25,
                      child: Icon(
                        Icons.catching_pokemon,
                        size: 140,
                        color: Colors.white.withAlpha(30),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(220),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: AppTheme.pogoTealPrimary,
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'POKÉMON GO ADVENTURE MART',
                                  style: TextStyle(
                                    color: AppTheme.pogoTealPrimary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'PokéMart - Galar Region Branch',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Catch, heal, evolve, and power up your team with official supplies.',
                            style: TextStyle(
                              color: Colors.white.withAlpha(230),
                              fontSize: 12.5,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // PoGO Limited-Time Special Boxes Showcase (Official PokeMiners Datamined Assets)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.card_giftcard,
                        size: 16,
                        color: AppTheme.pogoTealPrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'LIMITED-TIME BOXES',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.pogoTealPrimary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 98,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildEventBoxCard(
                          theme: theme,
                          colorScheme: colorScheme,
                          title: 'Great Box',
                          coins: 480,
                          badge: 'HOT',
                          imageUrl: PogoAssets.boxGreat,
                        ),
                        const SizedBox(width: 10),
                        _buildEventBoxCard(
                          theme: theme,
                          colorScheme: colorScheme,
                          title: 'Ultra Box',
                          coins: 1480,
                          badge: 'BEST VALUE',
                          imageUrl: PogoAssets.boxUltra,
                        ),
                        const SizedBox(width: 10),
                        _buildEventBoxCard(
                          theme: theme,
                          colorScheme: colorScheme,
                          title: 'Adventure Box',
                          coins: 1480,
                          badge: 'EXPLORER',
                          imageUrl: PogoAssets.boxAdventure,
                        ),
                        const SizedBox(width: 10),
                        _buildEventBoxCard(
                          theme: theme,
                          colorScheme: colorScheme,
                          title: 'Special Box',
                          coins: 280,
                          badge: 'STARTER',
                          imageUrl: PogoAssets.boxSpecial,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Price Filter Section (Material 3 RangeSlider - Max ₽5,000)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Card(
                elevation: 0,
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: BorderSide(color: colorScheme.outline, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.tune,
                                size: 18,
                                color: AppTheme.pogoTealPrimary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Price Range Filter',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.pogoTealPrimary.withAlpha(20),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppTheme.pogoTealPrimary.withAlpha(40),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '₽${AppTheme.formatPrice(activeSliderValues.start)} - ₽${AppTheme.formatPrice(activeSliderValues.end)}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppTheme.pogoTealPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      RangeSlider(
                        values: activeSliderValues,
                        min: 0,
                        max: 5000,
                        divisions: 50,
                        activeColor: AppTheme.pogoTealPrimary,
                        inactiveColor: colorScheme.outline.withAlpha(120),
                        labels: RangeLabels(
                          '₽${activeSliderValues.start.round()}',
                          '₽${activeSliderValues.end.round()}',
                        ),
                        onChanged: (values) {
                          setState(() {
                            _sliderValues = values;
                          });
                        },
                        onChangeEnd: (values) {
                          setState(() {
                            _sliderValues = null;
                          });
                          catalog.setPriceRange(values);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Category Filter & Counter Bar (PoGO Bag Pockets)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Inventory Items',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${catalog.totalCount} items • Page ${catalog.currentPage} of ${catalog.totalPages}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Horizontal category chips styled as PoGO Bag Pockets
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        final isSelected =
                            catalog.selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(category),
                            labelStyle: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : colorScheme.onSurface,
                            ),
                            selectedColor: AppTheme.pogoTealPrimary,
                            backgroundColor: colorScheme.surface,
                            checkmarkColor: Colors.white,
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.pogoTealPrimary
                                  : colorScheme.outline,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                catalog.setCategory(category);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Main Catalog View (Loading / Error / Empty / Grid)
            if (catalog.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.pogoTealPrimary),
                  ),
                ),
              )
            else if (catalog.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: colorScheme.errorContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: colorScheme.onErrorContainer,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          catalog.errorMessage!,
                          style: TextStyle(color: colorScheme.onErrorContainer),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: catalog.fetchCatalog,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.pogoTealPrimary,
                          ),
                          child: const Text('Retry Connection'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (catalog.products.isEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off,
                        size: 48,
                        color: AppTheme.pogoCoinGold,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No items in inventory matching criteria',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try adjusting your price range or selecting another pocket.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _sliderValues = null;
                          });
                          catalog.setPriceRange(const RangeValues(0, 5000));
                          catalog.setCategory('All');
                        },
                        child: const Text('Reset Filters'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final int crossAxisCount;
                    if (constraints.maxWidth < 600) {
                      crossAxisCount = 2;
                    } else if (constraints.maxWidth < 900) {
                      crossAxisCount = 3;
                    } else {
                      crossAxisCount = 4;
                    }

                    final totalSpacing = (crossAxisCount - 1) * 12;
                    final cardWidth =
                        (constraints.maxWidth - totalSpacing) / crossAxisCount;
                    final cardHeight = cardWidth + 108;
                    final childAspectRatio = cardWidth / cardHeight;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: catalog.products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        final product = catalog.products[index];
                        return ProductCard(product: product);
                      },
                    );
                  },
                ),
              ),

            // Backend Pagination Controls Footer
            if (!catalog.isLoading && catalog.products.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: catalog.hasPreviousPage
                          ? () => catalog.previousPage()
                          : null,
                      icon: const Icon(Icons.chevron_left, size: 18),
                      label: const Text('Previous'),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'Page ${catalog.currentPage} of ${catalog.totalPages}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: catalog.hasNextPage
                          ? () => catalog.nextPage()
                          : null,
                      icon: const Icon(Icons.chevron_right, size: 18),
                      label: const Text('Next'),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Builds a promotional PoGO Event Box card with authentic 3D box graphics from PokeMiners.
  Widget _buildEventBoxCard({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required String title,
    required int coins,
    required String badge,
    required String imageUrl,
  }) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outline, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.pogoScaffoldBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.pogoTealPrimary.withAlpha(35),
                width: 1.5,
              ),
            ),
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.card_giftcard,
                color: AppTheme.pogoTealPrimary,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppTheme.pogoValorRed.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: AppTheme.pogoValorRed,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Image.network(
                      PogoAssets.btnCoinsSmall,
                      width: 13,
                      height: 13,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.monetization_on,
                        size: 13,
                        color: AppTheme.pogoCoinGold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$coins',
                      style: const TextStyle(
                        color: AppTheme.pogoCoinGold,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
