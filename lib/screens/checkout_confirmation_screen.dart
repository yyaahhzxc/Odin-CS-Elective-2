import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/cart_item.dart';
import '../state/cart_state.dart';
import '../theme/app_theme.dart';

/// Screen displaying the final checkout confirmation and itemized order receipt.
///
/// Implemented as a [StatefulWidget] to snapshot order contents from [CartManager]
/// upon arrival and safely clear the active shopping cart lifecycle.
///
/// Conforms to the exam requirement:
/// "Displays simple summary of: Cart items, Subtotal per item, Total, Confirmation message;
/// Reachable only after at least one item is in the cart."
class CheckoutConfirmationScreen extends StatefulWidget {
  const CheckoutConfirmationScreen({super.key});

  @override
  State<CheckoutConfirmationScreen> createState() =>
      _CheckoutConfirmationScreenState();
}

class _CheckoutConfirmationScreenState
    extends State<CheckoutConfirmationScreen> {
  List<CartItem> _purchasedItems = [];
  double _totalAmount = 0.0;
  late final String _orderNumber;
  late final DateTime _orderTimestamp;

  @override
  void initState() {
    super.initState();
    _orderNumber =
        'CSSEC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    _orderTimestamp = DateTime.now();

    // Snapshot cart items and clear the active cart
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cart = CartScope.maybeOf(context);
      if (cart != null && cart.isNotEmpty) {
        setState(() {
          _purchasedItems = List<CartItem>.from(cart.items);
          _totalAmount = cart.totalAmount;
        });
        cart.clearCart();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout Confirmation'),
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: 'Back to Shop',
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Confirmation check icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(25),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary.withAlpha(80),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),

                // Confirmation headline & message
                Text(
                  'Order Placed Successfully!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thank you for your order! Your CSSEC merch order has been placed successfully. Please present your Order ID at the CSSEC Council booth for pickup.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),

                // Static itemized order summary receipt card
                _OrderReceiptCard(
                  orderNumber: _orderNumber,
                  orderDate: _orderTimestamp,
                  items: _purchasedItems,
                  totalAmount: _totalAmount,
                ),

                const SizedBox(height: 28),

                // Return to catalog action button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Continue Shopping'),
                    onPressed: () => context.go('/'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Static presentation card displaying the itemized receipt.
///
/// Uses [StatelessWidget] since it displays immutable order snapshot data.
class _OrderReceiptCard extends StatelessWidget {
  final String orderNumber;
  final DateTime orderDate;
  final List<CartItem> items;
  final double totalAmount;

  const _OrderReceiptCard({
    required this.orderNumber,
    required this.orderDate,
    required this.items,
    required this.totalAmount,
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
          children: [
            // Order metadata header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ID',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      orderNumber,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Pickup Location',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'CSSEC Merch Booth',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 28),

            // Itemized line items
            Text(
              'Purchased Items',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No item details available.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          width: 44,
                          height: 44,
                          color: colorScheme.surfaceContainerHighest
                              .withAlpha(80),
                          child: item.imagePath.isNotEmpty
                              ? Image.asset(
                                  item.imagePath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 20,
                                    color: colorScheme.primary,
                                  ),
                                )
                              : Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Item details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (item.variant != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Variant: ${item.variant!.name}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            const SizedBox(height: 2),
                            Text(
                              '${item.formattedUnitPrice} × ${item.quantity}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Subtotal per item
                      Text(
                        item.formattedSubtotal,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),

            const Divider(height: 28),

            // Order Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount Paid:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₱${AppTheme.formatPrice(totalAmount)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
