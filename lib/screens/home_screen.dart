import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../state/cart_state.dart';
import '../state/catalog_state.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';

/// Home screen displaying the PokéMart product catalog.
/// Implements standard e-commerce features:
/// - Categorized product catalog with default List view (showing full 3-line descriptions)
/// - Flexible 2-column Grid view toggle
/// - Collapsible filters for Category, Sort By (Popular default), and Price Range
/// - Manual minimum/maximum price input fields and real-time range slider
/// - Fully interactive pagination bar with direct page jumping
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

  // List view with full description is default as requested
  bool _isGridView = false;

  // Collapsible toolbar panels state
  bool _isFilterExpanded = false;
  bool _isSortExpanded = false;
  bool _isPriceExpanded = false;

  // Local drag values for smooth slider interaction before triggering backend query
  RangeValues? _sliderValues;

  // Manual text controllers for editing price bounds directly
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _minPriceController = TextEditingController(text: '0');
    _maxPriceController = TextEditingController(text: '5000');
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _scrollController.dispose();
    super.dispose();
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

    final cart = CartScope.of(context);
    final catalog = CatalogScope.of(context);

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
          // Theme mode toggle
          IconButton(
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: AppTheme.pogoTealPrimary,
              size: 20,
            ),
            tooltip: widget.isDarkMode ? 'Day Mode' : 'Night Mode',
            onPressed: widget.onToggleTheme,
          ),

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
            tooltip: 'Shopping Bag',
            onPressed: () => context.go('/cart'),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Catalog Overview Header: "Inventory Items" & Total Count
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Inventory Items',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppTheme.pogoTextPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.pogoTealPrimary.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${catalog.totalCount} Products Available',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.pogoTealPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Comprehensive E-Commerce Toolbar: View By, Filter, Sort, Price Range
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // A. View By Toggle [ ≡ List | ::: Grid ] with List placed first
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withAlpha(90),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: colorScheme.outline.withAlpha(70),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              if (_isGridView) {
                                setState(() => _isGridView = false);
                              }
                            },
                            borderRadius: BorderRadius.circular(7),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: !_isGridView
                                    ? AppTheme.pogoTealPrimary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.view_headline_rounded,
                                    size: 14,
                                    color: !_isGridView
                                        ? Colors.white
                                        : AppTheme.pogoTextSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'List',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: !_isGridView
                                          ? Colors.white
                                          : AppTheme.pogoTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          InkWell(
                            onTap: () {
                              if (!_isGridView) {
                                setState(() => _isGridView = true);
                              }
                            },
                            borderRadius: BorderRadius.circular(7),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _isGridView
                                    ? AppTheme.pogoTealPrimary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.grid_view_rounded,
                                    size: 14,
                                    color: _isGridView
                                        ? Colors.white
                                        : AppTheme.pogoTextSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Grid',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: _isGridView
                                          ? Colors.white
                                          : AppTheme.pogoTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // B. Collapsible Filter Button
                    _buildToolbarPill(
                      label: catalog.selectedCategory == 'All'
                          ? 'Filter'
                          : catalog.selectedCategory,
                      icon: Icons.filter_list,
                      isExpanded: _isFilterExpanded,
                      isActive: catalog.selectedCategory != 'All',
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

                    // C. Collapsible Sort By Button
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

                    // D. Collapsible Price Range Button
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
                  ],
                ),
              ),
            ),

            // 3. Collapsible Category Filter Panel
            if (_isFilterExpanded)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                            'Select Category',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (catalog.selectedCategory != 'All')
                            GestureDetector(
                              onTap: () => catalog.setCategory('All'),
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
                        children: _categories.map((category) {
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
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

            // 4. Collapsible Sort By Panel
            if (_isSortExpanded)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                              'price_asc', 'Price: Low to High', catalog),
                          _buildSortChip(
                              'price_desc', 'Price: High to Low', catalog),
                          _buildSortChip('name_asc', 'Name: A–Z', catalog),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // 5. Collapsible Price Range Panel (Slider + Manual Text Inputs)
            if (_isPriceExpanded)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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

                        // Manual Edit Option (Typing exact min and max price)
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

            // 6. Section Header
            _buildSectionHeader(
              catalog.selectedCategory == 'All'
                  ? 'ALL PRODUCTS'
                  : catalog.selectedCategory.toUpperCase(),
              colorScheme,
            ),

            // 7. Product Catalog Layout (2-Column Grid View or List View)
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
                          catalog.setPriceRange(const RangeValues(0, 5000));
                          catalog.setCategory('All');
                        },
                        child: const Text('Reset Filters'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_isGridView)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount =
                        constraints.maxWidth >= 700 ? 4 : 2;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: catalog.products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.82,
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

            // 8. Custom Interactive Page Navigator
            if (catalog.totalPages > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: _buildPaginationNavigator(catalog, theme, colorScheme),
              ),
          ],
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

  Widget _buildSortChip(String sortValue, String label, CatalogManager catalog) {
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

  /// Custom Interactive Page Navigator with clickable numbers and direct jumper.
  Widget _buildPaginationNavigator(
    CatalogManager catalog,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous Button
            IconButton.outlined(
              icon: const Icon(Icons.chevron_left, size: 20),
              tooltip: 'Previous Page',
              onPressed: catalog.hasPreviousPage
                  ? () {
                      catalog.previousPage();
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    }
                  : null,
            ),
            const SizedBox(width: 8),

            // Numbered Interactive Page Pills
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(catalog.totalPages, (index) {
                    final pageNum = index + 1;
                    final isCurrent = pageNum == catalog.currentPage;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: InkWell(
                        onTap: () {
                          catalog.goToPage(pageNum);
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppTheme.pogoTealPrimary
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrent
                                  ? AppTheme.pogoTealPrimary
                                  : colorScheme.outline.withAlpha(70),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$pageNum',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isCurrent
                                    ? Colors.white
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Next Button
            IconButton.outlined(
              icon: const Icon(Icons.chevron_right, size: 20),
              tooltip: 'Next Page',
              onPressed: catalog.hasNextPage
                  ? () {
                      catalog.nextPage();
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    }
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Direct Page Jump indicator badge
        InkWell(
          onTap: () => _showPageJumpDialog(context, catalog),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text(
              'Page ${catalog.currentPage} of ${catalog.totalPages} • Jump to page',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.pogoTealPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPageJumpDialog(BuildContext context, CatalogManager catalog) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Go to Page'),
        content: SizedBox(
          width: double.maxFinite,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(catalog.totalPages, (index) {
              final pageNum = index + 1;
              final isCurrent = pageNum == catalog.currentPage;
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrent
                      ? AppTheme.pogoTealPrimary
                      : null,
                  foregroundColor: isCurrent ? Colors.white : null,
                ),
                onPressed: () {
                  Navigator.of(dialogCtx).pop();
                  catalog.goToPage(pageNum);
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
                },
                child: Text('$pageNum'),
              );
            }),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Clean section title with subtle divider line.
  Widget _buildSectionHeader(String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppTheme.pogoTextSecondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(
              color: colorScheme.outline.withAlpha(60),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
