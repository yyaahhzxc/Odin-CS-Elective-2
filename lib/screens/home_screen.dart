import 'package:flutter/material.dart';
import '../data/product_data.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

/// home Screen displays the product browsing catalog
///
/// implemented as a [StatefulWidget] to manage the selected category filter
/// ('All', 'Apparel', 'Accessories') when the user interacts with the filter chips

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
  // default category
  String _selectedCategory = 'All';

  final List<String> _categories = const ['All', 'Apparel', 'Accessories'];

  /// for product filtering, states are all, apparel, and accessories
  List<Product> get _filteredProducts {
    if (_selectedCategory == 'All') {
      return mockProducts;
    }
    return mockProducts
        .where((product) => product.category == _selectedCategory)
        .toList();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // appbar, contains title on top left and theme toggle
      appBar: AppBar(
        title: const Text('CSShop'),
        actions: [
          // Light/Dark mode toggle button
          IconButton(
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            tooltip: widget.isDarkMode
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),

      // main body na part na jud like legit
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// hero section(?) i think ang tawag not sure
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CSShop - The CSSEC Merch Store',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Official merchandise channel of the Computer Studies Student Executive Council for S.Y. 2026-2027',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            // Category Filter Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Products',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_filteredProducts.length} items',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Horizontal category chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(category),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                            ),
                            selectedColor: colorScheme.primary,
                            checkmarkColor: colorScheme.onPrimary,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                });
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

            // Responsive Product Grid
            // Uses LayoutBuilder to adjust columns based on screen width:
            // - Phone (< 600px): 2 columns
            // - Tablet (600px - 900px): 3 columns
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

                  // Dynamically calculate aspect ratio so the card always has enough
                  // height for the 1:1 square image PLUS the text details on any screen size
                  final totalSpacing = (crossAxisCount - 1) * 12;
                  final cardWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;
                  final cardHeight = cardWidth + 96; // square image + details + padding
                  final childAspectRatio = cardWidth / cardHeight;

                  // GridView.builder renders the list of product cards in a responsive grid
                  return GridView.builder(
                    shrinkWrap: true, // lets the grid take only the height it needs inside SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(), // disables internal grid scrolling so the outer SingleChildScrollView handles scrolling
                    itemCount: _filteredProducts.length, // total number of products to show
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount, // number of columns (calculated above from screen width)
                      crossAxisSpacing: 12, // horizontal gap between cards
                      mainAxisSpacing: 12, // vertical gap between cards
                      childAspectRatio: childAspectRatio, // dynamic ratio guarantees zero overflow on any device
                    ),
                    itemBuilder: (context, index) {
                      // builds each individual product card widget
                      final product = _filteredProducts[index];
                      return ProductCard(product: product);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
