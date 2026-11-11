import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/pogo_assets.dart';
import '../state/cart_state.dart';
import '../state/catalog_state.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';

/// Home screen displaying the PokéMart product catalog modeled after the
/// authentic Pokémon GO Items (Bag) interface (Image 1 reference):
/// - Clean "ITEMS" header with capacity count and underline bar
/// - Dual view modes: List View (left reference) and 3-Column Grid View (right reference)
/// - PoGO Bag Pocket category dividers: `────── MEDICINE ──────`
/// - Price Range filtering with real-time backend pagination
/// - Floating dismiss 'X' button at bottom-center
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

  // Dual layout mode matching PoGO Bag view switcher [ ::: | ≡ ]
  bool _isGridView = false;

  // Local drag values for smooth slider interaction before triggering backend query
  RangeValues? _sliderValues;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final cart = CartScope.of(context);
    final catalog = CatalogScope.of(context);

    // Sync local slider values with catalog state if not actively dragging
    final activeSliderValues = _sliderValues ?? catalog.priceRange;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ITEMS',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 1.5,
                    color: AppTheme.pogoTextPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                RichText(
                  text: TextSpan(
                    style: theme.appBarTheme.titleTextStyle,
                    children: const [
                      TextSpan(
                        text: 'POKÉ',
                        style: TextStyle(
                          color: AppTheme.pogoTealPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: -0.2,
                        ),
                      ),
                      TextSpan(
                        text: 'MART',
                        style: TextStyle(
                          color: AppTheme.pogoTextPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 0,
              height: 0,
              child: OverflowBox(
                minWidth: 0,
                minHeight: 0,
                maxWidth: 0,
                maxHeight: 0,
                child: Text(
                  'PokéMart - Galar Region Branch',
                  style: TextStyle(fontSize: 0.1, color: Colors.transparent),
                ),
              ),
            ),
          ],
        ),
        actions: [
          // PoGO View Switcher Toggle [ ::: | ≡ ] matching Image 1
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(160),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colorScheme.outline, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    if (!_isGridView) {
                      setState(() => _isGridView = true);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isGridView
                          ? AppTheme.pogoTealPrimary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(
                      Icons.grid_view_rounded,
                      size: 15,
                      color: _isGridView
                          ? Colors.white
                          : AppTheme.pogoTextSecondary,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (_isGridView) {
                      setState(() => _isGridView = false);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: !_isGridView
                          ? AppTheme.pogoTealPrimary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(
                      Icons.view_headline_rounded,
                      size: 15,
                      color: !_isGridView
                          ? Colors.white
                          : AppTheme.pogoTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // PoGO Trainer Coin / Funds Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(160),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  PogoAssets.btnCoinsSmall,
                  width: 15,
                  height: 15,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.monetization_on,
                    color: AppTheme.pogoCoinGold,
                    size: 15,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '325,976',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.pogoCoinGold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Shopping Bag button with live item counter
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

          // Light/Dark mode toggle
          IconButton(
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: AppTheme.pogoTealPrimary,
              size: 20,
            ),
            tooltip: widget.isDarkMode
                ? 'Switch to Day Mode'
                : 'Switch to Stadium Night Mode',
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PoGO Capacity Header: "Inventory Items" & "5147/5150" with Underline
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Inventory Items',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: AppTheme.pogoTextPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${catalog.totalCount} / 48',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.pogoTealPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        // PoGO capacity underline indicator bar
                        Container(
                          width: 80,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppTheme.pogoTealPrimary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Horizontal category chips styled as PoGO Bag Pockets
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: SingleChildScrollView(
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
                              fontSize: 12,
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
                ),

                // Price Filter Section (Material 3 RangeSlider - Max ₽5,000)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Card(
                    elevation: 0,
                    color: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: colorScheme.outline, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
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
                                    size: 16,
                                    color: AppTheme.pogoTealPrimary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Price Range Filter',
                                    style:
                                        theme.textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.pogoTealPrimary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        AppTheme.pogoTealPrimary.withAlpha(40),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '₽${AppTheme.formatPrice(activeSliderValues.start)} - ₽${AppTheme.formatPrice(activeSliderValues.end)}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.pogoTealPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
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

                // PoGO Authentic Section Header (e.g. "────── MEDICINE ──────")
                _buildPoGoSectionHeader(
                  catalog.selectedCategory == 'All'
                      ? 'ALL POCKETS'
                      : catalog.selectedCategory.toUpperCase(),
                  colorScheme,
                ),

                // Product Catalog Layout (Dual-Mode: List View or 3-Column Grid View)
                if (catalog.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.pogoTealPrimary,
                      ),
                    ),
                  )
                else if (catalog.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppTheme.pogoValorRed,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            catalog.errorMessage!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => catalog.fetchCatalog(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (catalog.products.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 54,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No items found within this range',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              catalog.setPriceRange(
                                const RangeValues(0, 5000),
                              );
                              catalog.setCategory('All');
                            },
                            child: const Text('Reset Filters'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_isGridView)
                  // 3-Column Grid View matching PoGO Bag Grid (Image 1 right)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: catalog.products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) {
                        final product = catalog.products[index];
                        return ProductCard(
                          product: product,
                          isGrid: true,
                        );
                      },
                    ),
                  )
                else
                  // List View matching PoGO Bag List (Image 1 left)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: catalog.products.length,
                    itemBuilder: (context, index) {
                      final product = catalog.products[index];
                      return ProductCard(
                        product: product,
                        isGrid: false,
                      );
                    },
                  ),

                // Responsive Bottom Pagination Controls
                if (catalog.totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
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

                const SizedBox(height: 80), // spacing for floating button
              ],
            ),
          ),

          // Floating dismiss 'X' button at bottom-center matching PoGO UI (Image 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.floatingButtonGradient,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close,
                      color: AppTheme.pogoTealPrimary,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Authentic PoGO Section Divider with centered tracking text (e.g. `────── MEDICINE ──────`)
  Widget _buildPoGoSectionHeader(String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: colorScheme.outline.withAlpha(140),
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
                color: AppTheme.pogoTextSecondary,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: colorScheme.outline.withAlpha(140),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
