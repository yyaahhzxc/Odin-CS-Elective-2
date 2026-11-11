import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/pogo_assets.dart';
import '../models/product.dart';
import '../state/cart_state.dart';
import '../theme/app_theme.dart';

/// Screen displaying details for a selected product modeled after the authentic
/// Pokémon GO Pokémon Summary / Detail interface (Image 2 reference):
/// - Outdoor habitat backdrop gradient (Radiant Sky Blue -> Field Grass Green)
/// - Top CP / Price readout (e.g. `₽200 CP`) with gold favorite star
/// - Prominent floating 3D item asset on the grass stage with soft grounding shadow
/// - Floating rounded white cards:
///   1. Header Card (Name, category pill, authentic 4-column stats row)
///   2. Resource & Action Card (PokéCoins, progress bars, quantity counter, and
///      dual-segment mint gradient "Add to Cart" capsule button)
///   3. Description & Lore Card (Moveset style with variant chips)
/// - Floating dismiss 'X' button at bottom-center
class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedVariantIndex = 0;
  int _quantity = 1;

  // Floating notification banner state
  bool _showBanner = false;
  String _bannerMessage = '';
  Timer? _bannerTimer;

  bool _isFavorite = false;

  @override
  void dispose() {
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cart = CartScope.of(context);

    // Active variant object
    final hasVariants = widget.product.variants.isNotEmpty;
    final activeVariant =
        hasVariants ? widget.product.variants[_selectedVariantIndex] : null;

    final displayName = activeVariant != null
        ? '${widget.product.name} - ${activeVariant.name}'
        : widget.product.name;
    final unitPrice = activeVariant?.price ?? widget.product.price;
    final displayPrice = activeVariant?.price != null
        ? '₽${AppTheme.formatPrice(activeVariant!.price!)}'
        : widget.product.formattedPrice;
    final displayDescription =
        activeVariant?.description ?? widget.product.description;
    final displayStock = activeVariant?.stock ?? widget.product.stock;

    final String imagePath = (activeVariant?.imagePath != null &&
            activeVariant!.imagePath!.isNotEmpty)
        ? activeVariant.imagePath!
        : widget.product.imagePath;

    final isNetworkImage = imagePath.startsWith('http');
    final hasRealImage = imagePath.isNotEmpty;

    final totalPrice = unitPrice * _quantity;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Natural Pokémon GO outdoor habitat backdrop gradient (Image 2)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4DBED6), // Radiant Sky Cyan
                  Color(0xFF75D8C1), // Mint Horizon
                  Color(0xFF89D448), // Lush Grass Green
                  Color(0xFFA2DF5B), // Vibrant Field Lime
                ],
                stops: [0.0, 0.28, 0.65, 1.0],
              ),
            ),
          ),

          // 2. Scrollable content: Top HUD, floating 3D model, stacked white cards
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 90),
              child: Column(
                children: [
                  // Top Navigation & HUD Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Circular back button
                        GestureDetector(
                          onTap: () {
                            _bannerTimer?.cancel();
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/');
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(210),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: AppTheme.pogoTealPrimary,
                              size: 22,
                            ),
                          ),
                        ),

                        // Center: CP / Price readout (like "825 CP" in Image 2)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$displayPrice CP',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Right actions: Favorite star & Trainer Bag button
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isFavorite = !_isFavorite;
                                });
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(210),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(25),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isFavorite ? Icons.star : Icons.star_border,
                                  color: AppTheme.pogoCoinGold,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Bag button with live counter badge
                            GestureDetector(
                              onTap: () {
                                _bannerTimer?.cancel();
                                context.go('/cart');
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(210),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(25),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Badge(
                                    isLabelVisible: cart.isNotEmpty,
                                    backgroundColor: AppTheme.pogoValorRed,
                                    label: Text('${cart.totalItemCount}'),
                                    child: const Icon(
                                      Icons.shopping_bag_outlined,
                                      color: AppTheme.pogoTealPrimary,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Hero 3D Item Stage: Floating unobstructed in nature (Image 2)
                  SizedBox(
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft grounding shadow on the field
                        Positioned(
                          bottom: 12,
                          child: Container(
                            width: 140,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(35),
                              borderRadius: BorderRadius.all(
                                Radius.elliptical(140, 20),
                              ),
                            ),
                          ),
                        ),
                        // 3D Item render
                        Center(
                          child: hasRealImage
                              ? (isNetworkImage
                                  ? Image.network(
                                      imagePath,
                                      height: 180,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.catching_pokemon,
                                        size: 110,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Image.asset(
                                      imagePath,
                                      height: 180,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.catching_pokemon,
                                        size: 110,
                                        color: Colors.white,
                                      ),
                                    ))
                              : const Icon(
                                  Icons.catching_pokemon,
                                  size: 110,
                                  color: Colors.white,
                                ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Floating White Rounded Card 1: Name, Badges & 4-Column Stats Row
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(18),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      child: Column(
                        children: [
                          // Item Name in bold charcoal with edit icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  displayName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.pogoTextPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.edit,
                                size: 14,
                                color: colorScheme.outline,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Top Badges Row (like TopIV / Lvl50 in Image 2)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF39C38), // Orange pill
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.product.category.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4AC490), // Green pill
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'POKÉMART OFFICIAL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // 4-Column Stats Row (Weight | Type | Sold | Stock) with vertical dividers
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatColumn(
                                icon: Icons.scale_outlined,
                                title: '0.25 kg',
                                subtitle: 'WEIGHT',
                              ),
                              _buildVerticalDivider(),
                              _buildStatColumn(
                                icon: Icons.category_outlined,
                                title: widget.product.category,
                                subtitle: 'POCKET',
                              ),
                              _buildVerticalDivider(),
                              _buildStatColumn(
                                icon: Icons.local_fire_department_outlined,
                                title: '${widget.product.soldCount}',
                                subtitle: 'SOLD',
                              ),
                              _buildVerticalDivider(),
                              _buildStatColumn(
                                icon: Icons.inventory_2_outlined,
                                title: '$displayStock',
                                subtitle: 'IN STOCK',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Floating White Rounded Card 2: Resources, Progress Bars & "Add to Cart" Capsule
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(18),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      child: Column(
                        children: [
                          // Top Resources Row (like Stardust / Candy in Image 2)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildResourceChip(
                                imageAsset: PogoAssets.btnCoinsSmall,
                                label: '325,976',
                                caption: 'POKÉCOINS',
                              ),
                              _buildVerticalDivider(),
                              _buildResourceChip(
                                icon: Icons.monetization_on,
                                iconColor: AppTheme.pogoCoinGold,
                                label: displayPrice,
                                caption: 'ITEM PRICE',
                              ),
                              _buildVerticalDivider(),
                              _buildResourceChip(
                                icon: Icons.backpack_outlined,
                                iconColor: AppTheme.pogoTealPrimary,
                                label: '${cart.quantityOf(widget.product)}',
                                caption: 'IN YOUR BAG',
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Level & HP Style Progress Bars (Image 2)
                          _buildProgressBar(
                            label: '$displayStock / 100 Available',
                            progress: (displayStock / 100).clamp(0.0, 1.0),
                            activeColor: const Color(0xFF4AC490),
                          ),
                          const SizedBox(height: 8),
                          _buildProgressBar(
                            label: '${cart.totalItemCount} / 50 Bag Capacity',
                            progress:
                                (cart.totalItemCount / 50).clamp(0.0, 1.0),
                            activeColor: AppTheme.pogoTealPrimary,
                          ),
                          const SizedBox(height: 16),

                          // Quantity Selector
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Order Quantity:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.pogoTextPrimary,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.pogoScaffoldBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppTheme.pogoTealPrimary
                                        .withAlpha(50),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 16),
                                      color: AppTheme.pogoTealPrimary,
                                      onPressed: _quantity > 1
                                          ? () => setState(() => _quantity--)
                                          : null,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text(
                                        '$_quantity',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          color: AppTheme.pogoTextPrimary,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 16),
                                      color: AppTheme.pogoTealPrimary,
                                      onPressed: _quantity < displayStock
                                          ? () => setState(() => _quantity++)
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Two-Segment Stadium Action Capsule: "POWER UP" style -> "Add to Cart"
                          GestureDetector(
                            onTap: () {
                              cart.addItem(
                                  widget.product, activeVariant, _quantity);
                              final variantNote = activeVariant != null
                                  ? ' (${activeVariant.name})'
                                  : '';

                              _bannerTimer?.cancel();
                              setState(() {
                                _bannerMessage =
                                    'Added $_quantity × ${widget.product.name}$variantNote to cart';
                                _showBanner = true;
                                _quantity = 1;
                              });

                              _bannerTimer =
                                  Timer(const Duration(seconds: 4), () {
                                if (mounted) {
                                  setState(() => _showBanner = false);
                                }
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: AppTheme.mintActionGradient,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withAlpha(160),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppTheme.pogoMintEnd.withAlpha(100),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Left segment: price total
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(50),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        bottomLeft: Radius.circular(30),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '₽${AppTheme.formatPrice(totalPrice)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Right segment: Action text
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        'Add to Cart',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 5. Floating White Rounded Card 3: Description, Lore & Variants
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(18),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Moveset / Description header
                          Row(
                            children: const [
                              Icon(
                                Icons.auto_stories_outlined,
                                size: 16,
                                color: AppTheme.pogoTealPrimary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'DESCRIPTION & SPECIFICATIONS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  color: AppTheme.pogoTextSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            displayDescription,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.45,
                              color: AppTheme.pogoTextPrimary,
                            ),
                          ),

                          // Variants pills
                          if (hasVariants) ...[
                            const SizedBox(height: 14),
                            const Text(
                              'Select Variation:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.pogoTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(
                                widget.product.variants.length,
                                (index) {
                                  final isSelected =
                                      _selectedVariantIndex == index;
                                  final variant =
                                      widget.product.variants[index];
                                  return ChoiceChip(
                                    selected: isSelected,
                                    label: Text(variant.name),
                                    labelStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.pogoTextPrimary,
                                    ),
                                    selectedColor: AppTheme.pogoTealPrimary,
                                    backgroundColor: AppTheme.pogoScaffoldBg,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _selectedVariantIndex = index;
                                        });
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating notification banner at top
          if (_showBanner)
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(20),
                color: AppTheme.pogoTealPrimary,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _bannerMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() => _showBanner = false);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 4. Floating dismiss 'X' button at bottom-center matching PoGO UI (Image 2)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _bannerTimer?.cancel();
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
                child: Container(
                  width: 52,
                  height: 52,
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
                      size: 28,
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

  Widget _buildStatColumn({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppTheme.pogoTealPrimary),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: AppTheme.pogoTextPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppTheme.pogoTextSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildResourceChip({
    String? imageAsset,
    IconData? icon,
    Color? iconColor,
    required String label,
    required String caption,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageAsset != null)
              Image.network(
                imageAsset,
                width: 15,
                height: 15,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.monetization_on,
                  size: 15,
                  color: AppTheme.pogoCoinGold,
                ),
              )
            else if (icon != null)
              Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppTheme.pogoTextPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          caption,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppTheme.pogoTextSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar({
    required String label,
    required double progress,
    required Color activeColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: activeColor,
          ),
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppTheme.pogoScaffoldBg,
            valueColor: AlwaysStoppedAnimation<Color>(activeColor),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.grey.withAlpha(60),
    );
  }
}
