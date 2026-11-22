import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../state/cart_state.dart';
import '../state/catalog_state.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_categories_dialog.dart';
import '../widgets/animated_primitives.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/product_card.dart';

/// Home and Catalog screen displaying the storefront popular items and full searchable catalog.
class HomeScreen extends ConsumerStatefulWidget {
  final bool initialShowAllProducts;

  const HomeScreen({
    super.key,
    this.initialShowAllProducts = false,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late bool _isViewingAllProducts;

  bool _isGridViewInCatalog = false;

  bool _isFilterExpanded = false;
  bool _isSortExpanded = false;
  bool _isPriceExpanded = false;

  RangeValues? _sliderValues;

  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;
  late final TextEditingController _searchController;
  Timer? _searchDebounce;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _isViewingAllProducts = widget.initialShowAllProducts;
    _minPriceController = TextEditingController(text: '0');
    _maxPriceController = TextEditingController(text: '5000');
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _resetAllProductsState() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _isGridViewInCatalog = false;
    _isFilterExpanded = false;
    _isSortExpanded = false;
    _isPriceExpanded = false;
    _sliderValues = null;
    final catalog = ref.read(catalogProvider);
    catalog.resetFilters();
    _syncPriceControllers(RangeValues(0, catalog.maxCatalogPrice));
  }

  void _openAllProductsView() {
    _resetAllProductsState();
    setState(() {
      _isViewingAllProducts = true;
    });
    _scrollToTop();
  }

  void _returnToStorefrontHome() {
    _resetAllProductsState();
    setState(() {
      _isViewingAllProducts = false;
    });
    _scrollToTop();
  }

  void _syncPriceControllers(RangeValues range) {
    _minPriceController.text = range.start.round().toString();
    _maxPriceController.text = range.end.round().toString();
  }

  void _applyManualPrice(CatalogManager catalog) {
    final sliderMax = catalog.maxCatalogPrice;
    final minParsed = double.tryParse(_minPriceController.text) ?? 0.0;
    final maxParsed = double.tryParse(_maxPriceController.text) ?? sliderMax;

    final validMin = minParsed.clamp(0.0, sliderMax);
    final validMax = maxParsed.clamp(validMin, sliderMax);

    final newRange = RangeValues(validMin, validMax);
    setState(() {
      _sliderValues = null;
      _syncPriceControllers(newRange);
    });
    catalog.setPriceRange(newRange);
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'popular':
        return 'Popular';
      case 'favorites':
        return 'Favorites';
      case 'price_asc':
        return 'Price: Low to High';
      case 'price_desc':
        return 'Price: High to Low';
      case 'name_asc':
        return 'Name: A–Z';
      default:
        return 'Popular';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final catalog = ref.watch(catalogProvider);
    final cart = ref.watch(cartProvider);
    final auth = ref.watch(authProvider);
    final isAdmin = auth.isAdmin;
    final hasCartItems = cart.isNotEmpty && !isAdmin;

    return PopScope(
      canPop: !_isViewingAllProducts,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isViewingAllProducts) {
          _returnToStorefrontHome();
        }
      },
      child: Scaffold(
      bottomNavigationBar: _isViewingAllProducts
          ? AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1.0,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: hasCartItems
                  ? KeyedSubtree(
                      key: const ValueKey<String>('sticky-cart-bar'),
                      child: _buildViewCartBottomBar(context, cart, colorScheme),
                    )
                  : const SizedBox.shrink(
                      key: ValueKey<String>('empty-cart-bar'),
                    ),
            )
          : AppBottomNav(
              currentIndex: 0,
              onHomeTap: _isViewingAllProducts ? _returnToStorefrontHome : null,
            ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              onPressed: () => context.push('/admin/product/add'),
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Product',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            )
          : null,
      appBar: _isViewingAllProducts
          ? _buildAllProductsAppBar(context, theme, colorScheme, catalog)
          : _buildStorefrontAppBar(theme, colorScheme, isAdmin),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _isViewingAllProducts
            ? KeyedSubtree(
                key: const ValueKey<String>('all-products-view'),
                child: _buildAllProductsBody(
                  context,
                  theme,
                  colorScheme,
                  catalog,
                ),
              )
            : KeyedSubtree(
                key: const ValueKey<String>('storefront-home-view'),
                child: _buildStorefrontHomeBody(
                  context,
                  theme,
                  colorScheme,
                  catalog,
                ),
              ),
      ),
      ),
    );
  }

  // ===========================================================================
  // 1. STOREFRONT HOME VIEW (SIMPLE HERO + MOST POPULAR PRODUCTS GRID)
  // ===========================================================================

  Widget _buildOutlinedLogoPart({
    required String text,
    required Color outlineColor,
    required Color fillColor,
    String? fontFamily = 'PokemonSolid',
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 22,
    double letterSpacing = 0.8,
  }) {
    final baseStyle = TextStyle(
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      height: 1.1,
    );
    return Stack(
      children: [
        Text(
          text,
          style: baseStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.5
              ..strokeJoin = StrokeJoin.round
              ..color = outlineColor,
          ),
        ),
        Text(
          text,
          style: baseStyle.copyWith(color: fillColor),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildStorefrontAppBar(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isAdmin,
  ) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOutlinedLogoPart(
                text: 'Poké',
                outlineColor: const Color(0xFF2A75BB),
                fillColor: const Color(0xFFFFCB05),
              ),
              const SizedBox(width: 2),
              _buildOutlinedLogoPart(
                text: 'MART',
                outlineColor: const Color(0xFF2A75BB),
                fillColor: AppTheme.pogoMintEnd,
                fontFamily: 'Bauhaus93',
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.2,
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
                'PokéMart Official Store',
                style: TextStyle(fontSize: 0.1, color: Colors.transparent),
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (isAdmin)
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Manage Categories',
            onPressed: () => showAdminCategoriesDialog(context),
          ),
        _buildThemeToggleButton(theme, colorScheme),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildThemeToggleButton(ThemeData theme, ColorScheme colorScheme) {
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppTheme.pogoCoinGold : colorScheme.primary;
    final tintBg = isDark
        ? AppTheme.pogoCoinGold.withAlpha(28)
        : colorScheme.primary.withAlpha(24);

    return IconButton(
      style: IconButton.styleFrom(backgroundColor: tintBg),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        transitionBuilder: (child, animation) => RotationTransition(
          turns: Tween<double>(begin: 0.75, end: 1.0).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey<bool>(isDark),
          color: accentColor,
          size: 21,
        ),
      ),
      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      onPressed: () {
        final current = ref.read(themeModeProvider);
        ref.read(themeModeProvider.notifier).state =
            current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      },
    );
  }

  Widget _buildStorefrontHomeBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    CatalogManager catalog,
  ) {
    final popularItems = catalog.popularProducts.isNotEmpty
        ? catalog.popularProducts
        : catalog.products.take(6).toList();

    return RefreshIndicator(
      color: AppTheme.pogoTealPrimary,
      onRefresh: catalog.fetchCatalog,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              gradient: AppTheme.mintActionGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.pogoTealPrimary.withAlpha(40),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Welcome to PokéMart',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),

          // Most Popular Products Header + View All Action Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Most Popular Products',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Top trainer essentials ranked by popularity',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _openAllProductsView,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                    minimumSize: const Size(0, 40),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Most Popular Products Grid
          if (catalog.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
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
          else if (popularItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text('No products available')),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth >= 700 ? 4 : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: popularItems.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.80,
                    ),
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: popularItems[index],
                        isGrid: true,
                      );
                    },
                  );
                },
              ),
            ),

          // D. Prominent Full-Width "View All Products" CTA Button at the bottom of Popular Grid
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _openAllProductsView,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                icon: const Icon(Icons.view_list_rounded, size: 20),
                label: const Text(
                  'View All Products',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  // ===========================================================================
  // 2. VIEW ALL PRODUCTS CATALOG SCREEN
  // ===========================================================================

  PreferredSizeWidget _buildAllProductsAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    CatalogManager catalog,
  ) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Back to Home',
        onPressed: _returnToStorefrontHome,
      ),
      titleSpacing: 0,
      // Pill-shaped Search Bar inside the top header
      title: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: SizedBox(
          height: 40,
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {});
              _searchDebounce?.cancel();
              _searchDebounce = Timer(const Duration(milliseconds: 250), () {
                if (mounted) {
                  catalog.setSearchQuery(val);
                }
              });
            },
            decoration: InputDecoration(
              hintText: 'Search items...',
              hintStyle: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: const Icon(
                Icons.search,
                size: 19,
                color: AppTheme.pogoTealPrimary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _searchDebounce?.cancel();
                        _searchController.clear();
                        catalog.setSearchQuery('');
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withAlpha(75),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(
                  color: AppTheme.pogoTealPrimary.withAlpha(120),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(
                  color: AppTheme.pogoTealPrimary,
                  width: 1.8,
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        _buildThemeToggleButton(theme, colorScheme),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAllProductsBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    CatalogManager catalog,
  ) {
    final sliderMax = catalog.maxCatalogPrice;
    final rawRange = _sliderValues ?? catalog.priceRange;
    final clampedStart = rawRange.start.clamp(0.0, sliderMax);
    final clampedEnd = rawRange.end.clamp(clampedStart, sliderMax);
    final activeSliderValues = RangeValues(clampedStart, clampedEnd);

    return RefreshIndicator(
      color: AppTheme.pogoTealPrimary,
      onRefresh: catalog.fetchCatalog,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Classic Toolbar: View Mode, Filter, Favorites, Sort By, Price Range & Conditional Filter Count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // A. View Mode Toggle [ List | Grid ]
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withAlpha(90),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () =>
                              setState(() => _isGridViewInCatalog = false),
                          borderRadius: BorderRadius.circular(7),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: !_isGridViewInCatalog
                                  ? AppTheme.pogoTealPrimary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              'List',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: !_isGridViewInCatalog
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                        InkWell(
                          onTap: () =>
                              setState(() => _isGridViewInCatalog = true),
                          borderRadius: BorderRadius.circular(7),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _isGridViewInCatalog
                                  ? AppTheme.pogoTealPrimary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              'Grid',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _isGridViewInCatalog
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // B. Collapsible Category Filter Button
                  _buildToolbarPill(
                    label: catalog.selectedCategories.isEmpty
                        ? 'Filter'
                        : (catalog.selectedCategories.length == 1
                            ? catalog.selectedCategories.first
                            : 'Filter (${catalog.selectedCategories.length})'),
                    icon: Icons.filter_list,
                    isExpanded: _isFilterExpanded,
                    isActive: catalog.selectedCategories.isNotEmpty ||
                        catalog.onlyFavorites,
                    colorScheme: colorScheme,
                    onTap: () {
                      setState(() {
                        _isFilterExpanded = !_isFilterExpanded;
                        if (_isFilterExpanded) {
                          _isSortExpanded = false;
                          _isPriceExpanded = false;
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 8),

                  // C. Quick Favorites Filter Toggle Pill
                  InkWell(
                    onTap: () =>
                        catalog.setOnlyFavorites(!catalog.onlyFavorites),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: catalog.onlyFavorites
                            ? AppTheme.pogoValorRed.withAlpha(22)
                            : colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: catalog.onlyFavorites
                              ? AppTheme.pogoValorRed
                              : colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedFavoriteIcon(
                            isFavorite: catalog.onlyFavorites,
                            size: 14,
                            activeColor: AppTheme.pogoValorRed,
                            inactiveColor: colorScheme.onSurface,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Favorites',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: catalog.onlyFavorites
                                  ? AppTheme.pogoValorRed
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // D. Collapsible Sort By Pill
                  _buildToolbarPill(
                    label: 'Sort: ${_getSortLabel(catalog.sortBy)}',
                    icon: Icons.swap_vert,
                    isExpanded: _isSortExpanded,
                    isActive: catalog.sortBy != 'popular',
                    colorScheme: colorScheme,
                    onTap: () {
                      setState(() {
                        _isSortExpanded = !_isSortExpanded;
                        if (_isSortExpanded) {
                          _isFilterExpanded = false;
                          _isPriceExpanded = false;
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 8),

                  // E. Collapsible Price Range Pill
                  _buildToolbarPill(
                    label: 'Price Range',
                    icon: Icons.tune,
                    isExpanded: _isPriceExpanded,
                    isActive: catalog.priceRange.start > 0 ||
                        catalog.priceRange.end < sliderMax,
                    colorScheme: colorScheme,
                    onTap: () {
                      setState(() {
                        _isPriceExpanded = !_isPriceExpanded;
                        if (_isPriceExpanded) {
                          _syncPriceControllers(activeSliderValues);
                          _isFilterExpanded = false;
                          _isSortExpanded = false;
                        }
                      });
                    },
                  ),

                  // Conditional Product Count Badge (ONLY shown when actively filtering)
                  if (catalog.isFiltering) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.pogoTealPrimary.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${catalog.totalCount} Products Available',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.pogoTealPrimary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 2. Collapsible Toolbar Panels (Filter / Sort / Price Range)
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _isFilterExpanded
                  ? Padding(
                      key: const ValueKey<String>('panel-filter'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Filter by Category & Favorites',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (catalog.selectedCategories.isNotEmpty ||
                                    catalog.onlyFavorites)
                                  GestureDetector(
                                    onTap: catalog.clearCategoryFilters,
                                    child: const Text(
                                      'Reset',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.pogoValorRed,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                FilterChip(
                                  selected: catalog.selectedCategories.isEmpty &&
                                      !catalog.onlyFavorites,
                                  label: const Text('All'),
                                  labelStyle: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: catalog.selectedCategories.isEmpty &&
                                            !catalog.onlyFavorites
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: catalog.selectedCategories.isEmpty &&
                                            !catalog.onlyFavorites
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurface,
                                  ),
                                  selectedColor: colorScheme.primary,
                                  backgroundColor: colorScheme.surface,
                                  checkmarkColor: colorScheme.onPrimary,
                                  side: BorderSide(
                                    color: catalog.selectedCategories.isEmpty &&
                                            !catalog.onlyFavorites
                                        ? colorScheme.primary
                                        : colorScheme.outlineVariant,
                                  ),
                                  onSelected: (_) =>
                                      catalog.clearCategoryFilters(),
                                ),
                                FilterChip(
                                  selected: catalog.onlyFavorites,
                                  avatar: Icon(
                                    catalog.onlyFavorites
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 15,
                                    color: catalog.onlyFavorites
                                        ? Colors.white
                                        : AppTheme.pogoValorRed,
                                  ),
                                  label: const Text('Favorites Only'),
                                  labelStyle: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: catalog.onlyFavorites
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: catalog.onlyFavorites
                                        ? Colors.white
                                        : colorScheme.onSurface,
                                  ),
                                  selectedColor: AppTheme.pogoValorRed,
                                  backgroundColor: colorScheme.surface,
                                  checkmarkColor: Colors.white,
                                  onSelected: (selected) =>
                                      catalog.setOnlyFavorites(selected),
                                ),
                                ...catalog.editableCategories.map((category) {
                                  final isSelected = catalog.selectedCategories
                                      .contains(category);
                                  return FilterChip(
                                    selected: isSelected,
                                    label: Text(category),
                                    labelStyle: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurface,
                                    ),
                                    selectedColor: colorScheme.primary,
                                    backgroundColor: colorScheme.surface,
                                    checkmarkColor: colorScheme.onPrimary,
                                    side: BorderSide(
                                      color: isSelected
                                          ? colorScheme.primary
                                          : colorScheme.outlineVariant,
                                    ),
                                    onSelected: (_) =>
                                        catalog.toggleCategory(category),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : _isSortExpanded
                      ? Padding(
                          key: const ValueKey<String>('panel-sort'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.outlineVariant,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sort Products By',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildSortChip(
                                      'popular',
                                      'Popular',
                                      catalog,
                                      colorScheme,
                                    ),
                                    _buildSortChip(
                                      'favorites',
                                      'Favorites First',
                                      catalog,
                                      colorScheme,
                                    ),
                                    _buildSortChip(
                                      'price_asc',
                                      'Price: Low to High',
                                      catalog,
                                      colorScheme,
                                    ),
                                    _buildSortChip(
                                      'price_desc',
                                      'Price: High to Low',
                                      catalog,
                                      colorScheme,
                                    ),
                                    _buildSortChip(
                                      'name_asc',
                                      'Name: A–Z',
                                      catalog,
                                      colorScheme,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      : _isPriceExpanded
                          ? Padding(
                              key: const ValueKey<String>('panel-price'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: Card(
                                  elevation: 0,
                                  color: colorScheme.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: colorScheme.outlineVariant,
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Price Range Filter (₽0 – ₽${AppTheme.formatPrice(sliderMax)})',
                                              style: theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            Text(
                                              '₽${AppTheme.formatPrice(activeSliderValues.start)} - ₽${AppTheme.formatPrice(activeSliderValues.end)}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w900,
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        RangeSlider(
                                          values: activeSliderValues,
                                          min: 0,
                                          max: sliderMax,
                                          divisions: 50,
                                          activeColor: colorScheme.primary,
                                          inactiveColor:
                                              colorScheme.outline.withAlpha(120),
                                          labels: RangeLabels(
                                            '₽${activeSliderValues.start.round()}',
                                            '₽${activeSliderValues.end.round()}',
                                          ),
                                          onChanged: (values) {
                                            setState(() {
                                              _sliderValues = values;
                                              _syncPriceControllers(values);
                                            });
                                          },
                                          onChangeEnd: (values) {
                                            setState(() {
                                              _sliderValues = null;
                                            });
                                            catalog.setPriceRange(values);
                                          },
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: _minPriceController,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: 'Min Price (₽)',
                                                  labelStyle:
                                                      const TextStyle(fontSize: 12),
                                                  isDense: true,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: TextField(
                                                controller: _maxPriceController,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: 'Max Price (₽)',
                                                  labelStyle:
                                                      const TextStyle(fontSize: 12),
                                                  isDense: true,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    colorScheme.primary,
                                                foregroundColor:
                                                    colorScheme.onPrimary,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () =>
                                                  _applyManualPrice(catalog),
                                              child: const Text('Apply'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(
                              key: ValueKey<String>('panel-none'),
                            ),
            ),
          ),

          // Product List / Grid Content
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
                      catalog.onlyFavorites
                          ? Icons.favorite_border
                          : Icons.inventory_2_outlined,
                      size: 54,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      catalog.onlyFavorites
                          ? 'No favorite items match your filters'
                          : 'No items found within this range',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        _searchDebounce?.cancel();
                        _searchController.clear();
                        setState(() => _sliderValues = null);
                        _syncPriceControllers(
                          RangeValues(0, catalog.maxCatalogPrice),
                        );
                        catalog.resetFilters();
                      },
                      child: const Text('Reset Filters'),
                    ),
                  ],
                ),
              ),
            )
          else
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _isGridViewInCatalog
                  ? Padding(
                      key: ValueKey<String>(
                        'catalog-grid-${catalog.currentPage}',
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount =
                              constraints.maxWidth >= 700 ? 4 : 2;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: catalog.products.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.80,
                            ),
                            itemBuilder: (context, index) {
                              final product = catalog.products[index];
                              return ProductCard(
                                product: product,
                                isGrid: true,
                              );
                            },
                          );
                        },
                      ),
                    )
                  : ListView.builder(
                      key: ValueKey<String>(
                        'catalog-list-${catalog.currentPage}',
                      ),
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
            ),

          // Simplified Pagination Bar: `<` `1` `2` `...` (clickable & editable) `Last` `>`
          if (catalog.totalPages > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: _buildSimplifiedPagination(catalog, theme, colorScheme),
            ),
        ],
      ),
      ),
    );
  }

  /// Sticky bottom "View your cart" bar:
  /// - Left: Circular count badge (`( 3 )`)
  /// - Center: `View your cart`
  /// - Right: Formatted running total (`₽ 273.00`)
  /// Only rendered when `cart.isNotEmpty`. Tapping it leads to `/cart` for Checkout.
  Widget _buildViewCartBottomBar(
    BuildContext context,
    CartManager cart,
    ColorScheme colorScheme,
  ) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
        child: Material(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(14),
          elevation: 6,
          shadowColor: Colors.black.withAlpha(60),
          child: InkWell(
            onTap: () => context.push('/cart'),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Circular item count badge
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.onPrimary,
                        width: 1.6,
                      ),
                    ),
                    child: Center(
                      child: AnimatedValueText(
                        '${cart.totalItemCount}',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  // Center: "View your cart" (clean single line without subtitle)
                  Text(
                    'View your cart',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 0.2,
                    ),
                  ),

                  // Right: Running Cart Total
                  AnimatedValueText(
                    cart.formattedTotal,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarPill({
    required String label,
    required IconData icon,
    required bool isExpanded,
    required bool isActive,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isActive || isExpanded
              ? AppTheme.pogoTealPrimary.withAlpha(20)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive || isExpanded
                ? AppTheme.pogoTealPrimary
                : colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive || isExpanded
                  ? AppTheme.pogoTealPrimary
                  : colorScheme.onSurface,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: isActive || isExpanded
                    ? AppTheme.pogoTealPrimary
                    : colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: isActive || isExpanded
                    ? AppTheme.pogoTealPrimary
                    : colorScheme.onSurface.withAlpha(140),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip(
    String sortValue,
    String label,
    CatalogManager catalog,
    ColorScheme colorScheme,
  ) {
    final isSelected = catalog.sortBy == sortValue;
    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
      ),
      selectedColor: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      side: BorderSide(
        color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
      ),
      onSelected: (selected) {
        if (selected) {
          catalog.setSortBy(sortValue);
        }
      },
    );
  }

  /// Pagination navigator displaying first/last pages, neighbors around the current
  /// page, and inline editable `'...'` slots.
  Widget _buildSimplifiedPagination(
    CatalogManager catalog,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final total = catalog.totalPages;
    final current = catalog.currentPage;

    final List<Object> tokens = [];
    if (total <= 5) {
      for (var i = 1; i <= total; i++) {
        tokens.add(i);
      }
    } else {
      tokens.add(1);
      final start = (current - 1).clamp(2, total - 1);
      final end = (current + 1).clamp(2, total - 1);

      if (start > 3) {
        tokens.add('left');
      } else if (start == 3) {
        tokens.add(2);
      }

      for (var p = start; p <= end; p++) {
        tokens.add(p);
      }

      if (end < total - 2) {
        tokens.add('right');
      } else if (end == total - 2) {
        tokens.add(total - 1);
      }
      tokens.add(total);
    }

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: [
          IconButton.outlined(
            icon: const Icon(Icons.chevron_left, size: 20),
            tooltip: 'Previous Page',
            onPressed: catalog.hasPreviousPage
                ? () {
                    catalog.previousPage();
                    _scrollToTop();
                  }
                : null,
          ),
          for (final token in tokens)
            if (token is int)
              _buildPagePill(
                label: '$token',
                isCurrent: current == token,
                colorScheme: colorScheme,
                onTap: () {
                  catalog.goToPage(token);
                  _scrollToTop();
                },
              )
            else
              _InlineEllipsisPageInput(
                key: ValueKey<String>('ellipsis-$token'),
                totalPages: total,
                colorScheme: colorScheme,
                onSubmitPage: (page) {
                  catalog.goToPage(page);
                  _scrollToTop();
                },
              ),
          IconButton.outlined(
            icon: const Icon(Icons.chevron_right, size: 20),
            tooltip: 'Next Page',
            onPressed: catalog.hasNextPage
                ? () {
                    catalog.nextPage();
                    _scrollToTop();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPagePill({
    required String label,
    required bool isCurrent,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isCurrent ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrent
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: 1.2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isCurrent ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }
}

/// Inline editable `'...'` pagination control allowing direct page-number entry.
class _InlineEllipsisPageInput extends StatefulWidget {
  final int totalPages;
  final ColorScheme colorScheme;
  final ValueChanged<int> onSubmitPage;

  const _InlineEllipsisPageInput({
    super.key,
    required this.totalPages,
    required this.colorScheme,
    required this.onSubmitPage,
  });

  @override
  State<_InlineEllipsisPageInput> createState() =>
      _InlineEllipsisPageInputState();
}

class _InlineEllipsisPageInputState extends State<_InlineEllipsisPageInput> {
  bool _isEditing = false;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      _commitAndClose();
    }
  }

  void _startEditing() {
    _controller.clear();
    setState(() => _isEditing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isEditing) {
        _focusNode.requestFocus();
      }
    });
  }

  void _commitAndClose() {
    final parsed = int.tryParse(_controller.text.trim());
    if (mounted) {
      setState(() {
        _isEditing = false;
        _controller.clear();
      });
    }
    if (parsed != null && parsed >= 1 && parsed <= widget.totalPages) {
      widget.onSubmitPage(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return Container(
        width: 52,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: widget.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.colorScheme.primary,
            width: 1.6,
          ),
        ),
        child: Center(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.go,
            maxLength: widget.totalPages.toString().length,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: widget.colorScheme.onSurface,
            ),
            decoration: const InputDecoration(
              counterText: '',
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: '#',
            ),
            onSubmitted: (_) => _commitAndClose(),
          ),
        ),
      );
    }

    return InkWell(
      onTap: _startEditing,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: widget.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.colorScheme.outlineVariant,
            width: 1.2,
          ),
        ),
        child: Center(
          child: Text(
            '...',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: widget.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
