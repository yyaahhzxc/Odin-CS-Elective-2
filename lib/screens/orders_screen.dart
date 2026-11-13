import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/order.dart';
import '../state/auth_state.dart';
import '../state/order_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';

/// Unified Orders Screen serving two role-authorized modes:
/// 1. Customer Order History (`isAdminMode == false`):
///    Lists only the customer's own orders, newest first, with status, date, total, and items.
/// 2. Admin Order List (`isAdminMode == true`):
///    Lists all customer orders across the store and allows Admins to update order status.
class OrdersScreen extends StatefulWidget {
  final bool isAdminMode;

  const OrdersScreen({
    super.key,
    this.isAdminMode = false,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const List<String> _orderStatuses = [
    'pending',
    'processing',
    'done',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  void _loadOrders() {
    final orderManager = OrderScope.maybeOf(context);
    final auth = AuthScope.maybeOf(context);
    if (orderManager == null) return;

    if (widget.isAdminMode || (auth?.isAdmin ?? false)) {
      orderManager.fetchAllOrders();
    } else {
      final userId = auth?.currentUser?.id ?? 'guest';
      orderManager.fetchCustomerOrders(userId);
    }
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = months[(dt.month - 1).clamp(0, 11)];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$m ${dt.day}, ${dt.year} • $hour:$min $amPm';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'done':
        return const Color(0xFF2E8B57);
      case 'processing':
        return AppTheme.pogoTealPrimary;
      case 'pending':
        return AppTheme.pogoCoinGold;
      case 'cancelled':
        return AppTheme.pogoValorRed;
      default:
        return AppTheme.pogoTealPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final auth = AuthScope.maybeOf(context);
    final orderManager = OrderScope.maybeOf(context);

    final isAdmin = auth?.isAdmin ?? false;
    final effectiveAdminMode = widget.isAdminMode && isAdmin;

    // Permission-denied guard if a customer attempts to access `/admin/orders`
    if (widget.isAdminMode && !isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Permission Denied')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 60, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  'Admin Permission Required',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Customers can only view their own Order History.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => context.go('/orders'),
                  child: const Text('Go to My Orders'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final orders = orderManager?.orders ?? const <OrderRecord>[];
    final isLoading = orderManager?.isLoading ?? false;
    final errorMsg = orderManager?.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: Text(effectiveAdminMode ? 'Admin Order List' : 'Order History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Orders',
            onPressed: _loadOrders,
          ),
        ],
      ),
      bottomNavigationBar: effectiveAdminMode
          ? const AppBottomNav(currentIndex: 1)
          : null,
      body: Builder(
        builder: (context) {
          if (isLoading && orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (errorMsg != null && orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 52,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      errorMsg,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _loadOrders,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 68,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      effectiveAdminMode
                          ? 'No Customer Orders Yet'
                          : 'No Past Orders Yet',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      effectiveAdminMode
                          ? 'Customer orders placed through checkout will appear here.'
                          : 'Your completed PokéMart orders and itemized receipts will appear here.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.storefront_outlined),
                      label: const Text('Return to Catalog'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final badgeColor = _statusColor(order.status);

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: Order Number, Date, and Status Badge / Admin Status Dropdown
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.orderNumber,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.pogoTealPrimary,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatDate(order.createdAt),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (effectiveAdminMode &&
                                      order.userEmail.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Customer: ${order.userEmail}',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ],
                              ),

                              // Status indicator or Admin status editor
                              if (effectiveAdminMode && orderManager != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeColor.withAlpha(25),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: badgeColor.withAlpha(80),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _orderStatuses.contains(
                                            order.status.toLowerCase(),
                                          )
                                          ? order.status.toLowerCase()
                                          : 'done',
                                      isDense: true,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: badgeColor,
                                      ),
                                      items: _orderStatuses
                                          .map(
                                            (s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(s.toUpperCase()),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (newStatus) {
                                        if (newStatus != null) {
                                          orderManager.updateOrderStatus(
                                            order.id,
                                            newStatus,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeColor.withAlpha(25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    order.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: badgeColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const Divider(height: 24),

                          // Itemized Snapshot Lines
                          ...order.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.quantity}x ${item.productName} (@ ${item.formattedUnitPrice})',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Text(
                                    item.formattedSubtotal,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 24),

                          // Order Total Footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order Total',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                order.formattedTotal,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.pogoTealPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

