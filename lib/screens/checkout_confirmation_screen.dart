import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/order.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_primitives.dart';

/// Screen displaying the database-authoritative checkout confirmation and itemized order receipt.
class CheckoutConfirmationScreen extends ConsumerWidget {
  const CheckoutConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final order = ref.watch(orderProvider).lastPlacedOrder;

    if (order == null) {
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 56,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No recent order found',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Return to PokéMart'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                PopIn(
                  duration: const Duration(milliseconds: 460),
                  beginScale: 0.5,
                  child: Container(
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
                ),
                const SizedBox(height: 20),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 110),
                  duration: const Duration(milliseconds: 320),
                  child: Column(
                    children: [
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
                        'Thank you for your order! Your PokéMart order has been placed successfully. Please present your Order ID at the Pokémon Center Mart counter for pickup.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 190),
                  duration: const Duration(milliseconds: 340),
                  offsetY: 16,
                  child: _OrderReceiptCard(order: order),
                ),

                const SizedBox(height: 28),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 260),
                  duration: const Duration(milliseconds: 320),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PressScale(
                        pressedScale: 0.97,
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppTheme.mintActionGradient,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.pogoMintEnd.withAlpha(80),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            icon: const Icon(Icons.catching_pokemon),
                            label: const Text(
                              'Return to PokéMart',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            onPressed: () => context.go('/'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () => context.go('/orders'),
                          icon: const Icon(Icons.receipt_long_outlined),
                          label: const Text('View Order History'),
                        ),
                      ),
                    ],
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

/// Static presentation card displaying the itemized database order receipt.
class _OrderReceiptCard extends StatelessWidget {
  final OrderRecord order;

  const _OrderReceiptCard({required this.order});

  Widget _buildReceiptLineRow({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required OrderItemRecord item,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 44,
            height: 44,
            color: colorScheme.surfaceContainerHighest.withAlpha(80),
            child: item.imageUrl.isNotEmpty
                ? (item.imageUrl.startsWith('http')
                    ? Image.network(
                        item.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.catching_pokemon,
                          size: 20,
                          color: AppTheme.swordPrimary,
                        ),
                      )
                    : Image.asset(
                        item.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.catching_pokemon,
                          size: 20,
                          color: AppTheme.swordPrimary,
                        ),
                      ))
                : const Icon(
                    Icons.catching_pokemon,
                    size: 20,
                    color: AppTheme.swordPrimary,
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
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
        Text(
          item.formattedSubtotal,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

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
                      order.orderNumber,
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
                      'Pokémon Center Mart',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 28),

            Text(
              'Purchased Items',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (order.items.isEmpty)
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
                itemCount: order.items.length,
                separatorBuilder: (context, index) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  return _buildReceiptLineRow(
                    theme: theme,
                    colorScheme: colorScheme,
                    item: order.items[index],
                  );
                },
              ),

            const Divider(height: 28),

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
                  order.formattedTotal,
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
