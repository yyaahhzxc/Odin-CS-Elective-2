import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../state/auth_state.dart';
import '../state/cart_state.dart';
import '../state/catalog_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/product_card.dart';

/// Home & Catalog Screen implementing the two-screen flow:
///
/// 1. **Storefront Home View** (`_isViewingAllProducts == false`):
///    - Simple, clean Hero banner displaying **"Welcome to PokéMart"**
///    - Proceeds immediately to the **Most Popular Products** section in a 2-column Grid
///    - Prominent **"View All Products"** button to open the full catalog
///    - Displays the floating stadium **Bottom Navigation Bar** (`Home`, `Cart` / `Orders`, `Profile`)
///
/// 2. **View All Products Catalog View** (`_isViewingAllProducts == true`):
///    - Back arrow to return to the Storefront Home + rounded Search bar (`Search items...`)
///    - Classic Filter, Favorites, Sort By, and Price Range toolbar with collapsible panels
///    - Conditional product count badge (shown only when actively filtering)
///    - Foodpanda-style List rows (or Grid toggle) where each item has its image on the right
///      with an overlaid `+` circle button that transforms into `[ 🗑 1 + ]` / `[ − 2 + ]`
///    - Simplified pagination (`1`, `2`, clickable/editable `...`, `Last`)
///    - Hides the main bottom navigation bar and instead displays the sticky **"View your cart"**
///      bottom bar **only when `cart.isNotEmpty`**, leading to Cart & Checkout.
class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;
  final bool initialShowAllProducts;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
    this.initialShowAllProducts = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool _isViewingAllProducts;

  // In the "View All Products" screen, Foodpanda-style List view is default
  bool _isGridViewInCatalog = false;

  // Collapsible toolbar panels state
  bool _isFilterExpanded = false;
  bool _isSortExpanded = false;
  bool _isPriceExpanded = false;

  // Local drag values for smooth slider interaction before triggering backend query
  RangeValues? _sliderValues;

  // Manual text controllers for editing price bounds directly and search query
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;
  late final TextEditingController _searchController;

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
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openAllProductsView() {
    setState(() {
      _isViewingAllProducts = true;
    });
    _scrollToTop();
  }

  void _returnToStorefrontHome() {
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
    final minParsed = double.tryParse(_minPriceController.text) ?? 0.0;
    final maxParsed = double.tryParse(_maxPriceController.text) ?? 5000.0;

    final validMin = minParsed.clamp(0.0, 5000.0);
    final validMax = maxParsed.clamp(validMin, 5000.0);

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

    final catalog = CatalogScope.of(context);
    final cart = CartScope.maybeOf(context);
    final auth = AuthScope.maybeOf(context);
    final isAdmin = auth?.isAdmin ?? false;
    final hasCartItems = (cart?.isNotEmpty ?? false) && !isAdmin;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // Storefront Home shows the floating stadium Bottom Navigation Bar;
      // View All Products hides the navbar and shows "View your cart" ONLY when cart has items.
      bottomNavigationBar: _isViewingAllProducts
          ? (hasCartItems && cart != null
              ? _buildViewCartBottomBar(context, cart)
              : null)
          : AppBottomNav(
              currentIndex: 0,
              onHomeTap: _isViewingAllProducts ? _returnToStorefrontHome : null,
            ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.pogoTealPrimary,
              foregroundColor: Colors.white,
              onPressed: () => context.go('/admin/product/add'),
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Product',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            )
          : null,
      appBar: _isViewingAllProducts
          ? _buildAllProductsAppBar(context, theme, colorScheme, catalog)
          : _buildStorefrontAppBar(theme, colorScheme),
      body: _isViewingAllProducts
          ? _buildAllProductsBody(context, theme, colorScheme, catalog)
          : _buildStorefrontHomeBody(
              context,
              theme,
              colorScheme,
              catalog,
              cart,
              isAdmin,
            ),
    );
  }

  // ===========================================================================
  // 1. STOREFRONT HOME VIEW (SIMPLE HERO + MOST POPULAR PRODUCTS GRID)
  // ===========================================================================

  PreferredSizeWidget _buildStorefrontAppBar(
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              style: theme.appBarTheme.titleTextStyle,
              children: const [
                TextSpan(
                  text: 'POKÉ',
                  style: TextStyle(
                    color: AppTheme.pogoTealPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -0.2,
                  ),
                ),
                TextSpan(
                  text: 'MART',
                  style: TextStyle(
                    color: AppTheme.pogoTextPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
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
        // Only Theme mode toggle remains in the top-right AppBar
        IconButton(
          icon: Icon(
            widget.isDarkMode
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            color: AppTheme.pogoTealPrimary,
            size: 22,
          ),
          tooltip: widget.isDarkMode ? 'Day Mode' : 'Night Mode',
          onPressed: widget.onToggleTheme,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStorefrontHomeBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    CatalogManager catalog,
    CartManager? cart,
    bool isAdmin,
  ) {
    final popularItems = catalog.popularProducts.isNotEmpty
        ? catalog.popularProducts
        : catalog.products.take(6).toList();

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A. Simple, Clean Hero Banner: Only "Welcome to PokéMart"
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppTheme.pogoTealPrimary,
                  AppTheme.pogoMintEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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

          // B. Most Popular Products Grid Header + "View All" Action Button
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
                          color: AppTheme.pogoTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Top trainer essentials ranked by popularity',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.pogoTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _openAllProductsView,
                  icon: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.pogoTealPrimary,
                    ),
                  ),
                  label: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppTheme.pogoTealPrimary,
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.pogoTealPrimary.withAlpha(20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // C. Most Popular Products in 2-Column Grid Form
          if (catalog.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.pogoTealPrimary,
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
                  backgroundColor: AppTheme.pogoTealPrimary,
                  foregroundColor: Colors.white,
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
              catalog.setSearchQuery(val);
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
        IconButton(
          icon: Icon(
            widget.isDarkMode
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            color: AppTheme.pogoTealPrimary,
            size: 21,
          ),
          tooltip: widget.isDarkMode ? 'Day Mode' : 'Night Mode',
          onPressed: widget.onToggleTheme,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildAllProductsBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    CatalogManager catalog,
  ) {
    final activeSliderValues = _sliderValues ?? catalog.priceRange;

    return SingleChildScrollView(
      controller: _scrollController,
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
                        color: colorScheme.outline.withAlpha(70),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () =>
                              setState(() => _isGridViewInCatalog = false),
                          borderRadius: BorderRadius.circular(7),
                          child: Container(
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
                                    : AppTheme.pogoTextSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                        InkWell(
                          onTap: () =>
                              setState(() => _isGridViewInCatalog = true),
                          borderRadius: BorderRadius.circular(7),
                          child: Container(
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
                                    : AppTheme.pogoTextSecondary,
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
                    label: catalog.selectedCategory == 'All'
                        ? 'Filter'
                        : catalog.selectedCategory,
                    icon: Icons.filter_list,
                    isExpanded: _isFilterExpanded,
                    isActive: catalog.selectedCategory != 'All' ||
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
                    child: Container(
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
                              : colorScheme.outline.withAlpha(70),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            catalog.onlyFavorites
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 14,
                            color: catalog.onlyFavorites
                                ? AppTheme.pogoValorRed
                                : colorScheme.onSurface,
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
                        catalog.priceRange.end < 5000,
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

          // 2. Collapsible Category & Favorites Filter Panel
          if (_isFilterExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withAlpha(70),
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
                        if (catalog.selectedCategory != 'All' ||
                            catalog.onlyFavorites)
                          GestureDetector(
                            onTap: () {
                              catalog.setCategory('All');
                              catalog.setOnlyFavorites(false);
                            },
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
                          checkmarkColor: Colors.white,
                          onSelected: (selected) =>
                              catalog.setOnlyFavorites(selected),
                        ),
                        ...catalog.categories.map((category) {
                          final isSelected =
                              catalog.selectedCategory == category;
                          return ChoiceChip(
                            selected: isSelected,
                            label: Text(category),
                            labelStyle: TextStyle(
                              fontSize: 11.5,
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
                                  : colorScheme.outline.withAlpha(80),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                catalog.setCategory(category);
                              }
                            },
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // 3. Collapsible Sort By Panel (including Favorites First)
          if (_isSortExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withAlpha(70),
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
                        _buildSortChip('popular', 'Popular', catalog),
                        _buildSortChip(
                          'favorites',
                          'Favorites First',
                          catalog,
                        ),
                        _buildSortChip(
                          'price_asc',
                          'Price: Low to High',
                          catalog,
                        ),
                        _buildSortChip(
                          'price_desc',
                          'Price: High to Low',
                          catalog,
                        ),
                        _buildSortChip('name_asc', 'Name: A–Z', catalog),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // 4. Collapsible Price Range Panel
          if (_isPriceExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Card(
                elevation: 0,
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.outline.withAlpha(70),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Price Range Filter (₽0 – ₽5,000)',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '₽${AppTheme.formatPrice(activeSliderValues.start)} - ₽${AppTheme.formatPrice(activeSliderValues.end)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.pogoTealPrimary,
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
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Min Price (₽)',
                                labelStyle: const TextStyle(fontSize: 12),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _maxPriceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Max Price (₽)',
                                labelStyle: const TextStyle(fontSize: 12),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.pogoTealPrimary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => _applyManualPrice(catalog),
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                        _searchController.clear();
                        setState(() => _sliderValues = null);
                        _syncPriceControllers(const RangeValues(0, 5000));
                        catalog.resetFilters();
                      },
                      child: const Text('Reset Filters'),
                    ),
                  ],
                ),
              ),
            )
          else if (_isGridViewInCatalog)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth >= 700 ? 4 : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: catalog.products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
          else
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

          // Simplified Pagination Bar: `<` `1` `2` `...` (clickable & editable) `Last` `>`
          if (catalog.totalPages > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: _buildSimplifiedPagination(catalog, theme, colorScheme),
            ),
        ],
      ),
    );
  }

  /// Sticky bottom "View your cart" bar:
  /// - Left: Circular count badge (`( 3 )`)
  /// - Center: `View your cart`
  /// - Right: Formatted running total (`₽ 273.00`)
  /// Only rendered when `cart.isNotEmpty`. Tapping it leads to `/cart` for Checkout.
  Widget _buildViewCartBottomBar(BuildContext context, CartManager cart) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
        child: Material(
          color: AppTheme.pogoTealPrimary,
          borderRadius: BorderRadius.circular(14),
          elevation: 6,
          shadowColor: Colors.black.withAlpha(60),
          child: InkWell(
            onTap: () => context.go('/cart'),
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
                      border: Border.all(color: Colors.white, width: 1.6),
                    ),
                    child: Center(
                      child: Text(
                        '${cart.totalItemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  // Center: "View your cart" (clean single line without subtitle)
                  const Text(
                    'View your cart',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 0.2,
                    ),
                  ),

                  // Right: Running Cart Total
                  Text(
                    cart.formattedTotal,
                    style: const TextStyle(
                      color: Colors.white,
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isActive || isExpanded
              ? AppTheme.pogoTealPrimary.withAlpha(20)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive || isExpanded
                ? AppTheme.pogoTealPrimary
                : colorScheme.outline.withAlpha(70),
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
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              size: 16,
              color: isActive || isExpanded
                  ? AppTheme.pogoTealPrimary
                  : colorScheme.onSurface.withAlpha(140),
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
  ) {
    final isSelected = catalog.sortBy == sortValue;
    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected ? Colors.white : null,
      ),
      selectedColor: AppTheme.pogoTealPrimary,
      onSelected: (selected) {
        if (selected) {
          catalog.setSortBy(sortValue);
        }
      },
    );
  }

  /// Simplified Pagination Navigator: `<` `1` `2` `...` (clickable & editable custom page input) `lastPage` `>`
  Widget _buildSimplifiedPagination(
    CatalogManager catalog,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final total = catalog.totalPages;
    final current = catalog.currentPage;
    final isMiddlePage = current > 2 && current < total;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous Button
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
        const SizedBox(width: 6),

        // Page 1
        _buildPagePill(
          label: '1',
          isCurrent: current == 1,
          colorScheme: colorScheme,
          onTap: () {
            catalog.goToPage(1);
            _scrollToTop();
          },
        ),

        // Page 2 (if at least 2 pages)
        if (total >= 2) ...[
          const SizedBox(width: 6),
          _buildPagePill(
            label: '2',
            isCurrent: current == 2,
            colorScheme: colorScheme,
            onTap: () {
              catalog.goToPage(2);
              _scrollToTop();
            },
          ),
        ],

        // Editable '...' Pill (serves as custom page navigator)
        if (total > 3) ...[
          const SizedBox(width: 6),
          InkWell(
            onTap: () => _showCustomPageInputDialog(context, catalog),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isMiddlePage
                    ? AppTheme.pogoTealPrimary
                    : colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isMiddlePage
                      ? AppTheme.pogoTealPrimary
                      : colorScheme.outline.withAlpha(110),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  isMiddlePage ? '$current • ...' : '...',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isMiddlePage ? Colors.white : colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],

        // Last Page (if total >= 3)
        if (total >= 3) ...[
          const SizedBox(width: 6),
          _buildPagePill(
            label: '$total',
            isCurrent: current == total,
            colorScheme: colorScheme,
            onTap: () {
              catalog.goToPage(total);
              _scrollToTop();
            },
          ),
        ],

        const SizedBox(width: 6),

        // Next Button
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
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isCurrent ? AppTheme.pogoTealPrimary : colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrent
                ? AppTheme.pogoTealPrimary
                : colorScheme.outline.withAlpha(110),
            width: 1.2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isCurrent ? Colors.white : colorScheme.onSurface,
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

  void _showCustomPageInputDialog(
    BuildContext context,
    CatalogManager catalog,
  ) {
    final pageController = TextEditingController(
      text: '${catalog.currentPage}',
    );
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Go to Page'),
        content: TextField(
          controller: pageController,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Enter page number (1 – ${catalog.totalPages})',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onSubmitted: (val) {
            final parsed = int.tryParse(val.trim());
            if (parsed != null &&
                parsed >= 1 &&
                parsed <= catalog.totalPages) {
              Navigator.of(dialogCtx).pop();
              catalog.goToPage(parsed);
              _scrollToTop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = int.tryParse(pageController.text.trim());
              if (parsed != null &&
                  parsed >= 1 &&
                  parsed <= catalog.totalPages) {
                Navigator.of(dialogCtx).pop();
                catalog.goToPage(parsed);
                _scrollToTop();
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }
}
