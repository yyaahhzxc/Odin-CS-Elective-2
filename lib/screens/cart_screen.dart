import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/cart_item.dart';
import '../state/cart_state.dart';

/// Screen displaying the items in the customer's shopping cart.
///
/// Implemented as a [StatefulWidget] to handle interactive user operations,
/// including incrementing or decrementing quantities, item removals,
/// and triggering real-time recalculation of running totals.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cart = CartScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear Cart',
              onPressed: () => _confirmClearCart(context, cart),
            ),
        ],
      ),
      body: cart.isEmpty
          ? _buildEmptyCart(context, theme, colorScheme)
          : LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth >= 700;

                if (isTablet) {
                  // Tablet & Desktop 2-column layout (items left, summary right)
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1050),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cart items column
                            Expanded(
                              flex: 3,
                              child: ListView.separated(
                                itemCount: cart.items.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = cart.items[index];
                                  return _CartItemCard(
                                    item: item,
                                    onIncrement: () =>
                                        cart.incrementQuantity(item.id),
                                    onDecrement: () =>
                                        _handleDecrement(cart, item),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 24),

                            // Sticky Order summary card column
                            Expanded(
                              flex: 2,
                              child: _OrderSummaryCard(
                                cart: cart,
                                onCheckout: () => context.go('/checkout'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  // Mobile single-column layout with bottom checkout bar
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: cart.items.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = cart.items[index];
                            return _CartItemCard(
                              item: item,
                              onIncrement: () =>
                                  cart.incrementQuantity(item.id),
                              onDecrement: () => _handleDecrement(cart, item),
                            );
                          },
                        ),
                      ),
                      // Bottom summary container for mobile
                      _MobileCheckoutBar(
                        cart: cart,
                        onCheckout: () => context.go('/checkout'),
                      ),
                    ],
                  );
                }
              },
            ),
    );
  }

  /// Displays an empty state presentation when no items reside in the cart.
  Widget _buildEmptyCart(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.remove_shopping_cart_outlined,
                size: 72,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your cart is empty',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Looks like you haven\'t added any CSSEC merchandise yet.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Browse Catalog'),
              onPressed: () => context.go('/'),
            ),
          ],
        ),
      ),
    );
  }

  /// Prompts the user with a confirmation dialog before wiping all cart items.
  void _confirmClearCart(BuildContext context, CartManager cart) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Shopping Cart'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              cart.clearCart();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  /// Handles decrementing item quantity, prompting confirmation if about to reach 0.
  void _handleDecrement(CartManager cart, CartItem item) {
    if (item.quantity > 1) {
      cart.decrementQuantity(item.id);
    } else {
      _confirmRemoveItem(context, cart, item);
    }
  }

  /// Prompts the user before removing an item from the cart when quantity reaches 0.
  void _confirmRemoveItem(
    BuildContext context,
    CartManager cart,
    CartItem item,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text(
          'Are you sure you want to remove ${item.displayName} from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              cart.removeItem(item.id);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

/// Reusable card displaying an individual cart item.
///
/// Uses [StatelessWidget] since it displays external properties and delegates
/// interactive mutations to callback closures.
class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CartItemCard({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasImage = item.imagePath.isNotEmpty;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Square thumbnail image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 72,
                height: 72,
                color: colorScheme.surfaceContainerHighest.withAlpha(80),
                child: hasImage
                    ? Image.asset(
                        item.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.shopping_bag_outlined,
                          size: 32,
                          color: colorScheme.primary,
                        ),
                      )
                    : Icon(
                        Icons.shopping_bag_outlined,
                        size: 32,
                        color: colorScheme.primary,
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // Product metadata (Title, variant, unit price)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (item.variant != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Variant: ${item.variant!.name}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${item.formattedUnitPrice} each',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Subtotal: ${item.formattedSubtotal}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Stateful quantity counter controls (+ or -)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 16),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    onPressed: onDecrement,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    onPressed: item.quantity < item.availableStock
                        ? onIncrement
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Order summary card displayed on tablet & desktop layouts.
class _OrderSummaryCard extends StatelessWidget {
  final CartManager cart;
  final VoidCallback onCheckout;

  const _OrderSummaryCard({
    required this.cart,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Order Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Total Items:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  '${cart.totalItemCount}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Running Subtotal:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  cart.formattedTotal,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Proceed to Checkout'),
                onPressed: onCheckout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sticky bottom checkout bar for mobile screen viewports.
class _MobileCheckoutBar extends StatelessWidget {
  final CartManager cart;
  final VoidCallback onCheckout;

  const _MobileCheckoutBar({
    required this.cart,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(18),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${cart.totalItemCount} ${cart.totalItemCount == 1 ? "item" : "items"}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    cart.formattedTotal,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Proceed to Checkout'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onPressed: onCheckout,
            ),
          ],
        ),
      ),
    );
  }
}
