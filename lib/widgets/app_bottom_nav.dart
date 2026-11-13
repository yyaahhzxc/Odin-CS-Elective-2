import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../state/auth_state.dart';
import '../state/cart_state.dart';
import '../theme/app_theme.dart';

/// Floating stadium-rounded bottom navigation bar inspired by Foodpanda's
/// primary navigation dock (`Home`, `Cart` / `Orders`, `Profile`).
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final VoidCallback? onHomeTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    this.onHomeTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cart = CartScope.maybeOf(context);
    final auth = AuthScope.maybeOf(context);
    final isAdmin = auth?.isAdmin ?? false;
    final isAuthenticated = auth?.isAuthenticated ?? false;
    final cartCount = cart?.totalItemCount ?? 0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: colorScheme.outline.withAlpha(70),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(18),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Home Tab
              Expanded(
                child: _NavDockItem(
                  icon: currentIndex == 0
                      ? Icons.storefront
                      : Icons.storefront_outlined,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                  onTap: () {
                    if (onHomeTap != null) {
                      onHomeTap!();
                      return;
                    }
                    if (currentIndex == 0) return;
                    try {
                      context.go('/');
                    } catch (_) {}
                  },
                ),
              ),

              // 2. Cart (or Orders for Admin) Tab
              Expanded(
                child: isAdmin
                    ? _NavDockItem(
                        icon: currentIndex == 1
                            ? Icons.assignment
                            : Icons.assignment_outlined,
                        label: 'Orders',
                        isSelected: currentIndex == 1,
                        onTap: () {
                          if (currentIndex == 1) return;
                          try {
                            context.go('/admin/orders');
                          } catch (_) {}
                        },
                      )
                    : _NavDockItem(
                        icon: currentIndex == 1
                            ? Icons.shopping_bag
                            : Icons.shopping_bag_outlined,
                        label: 'Cart',
                        badgeCount: cartCount,
                        isSelected: currentIndex == 1,
                        onTap: () {
                          if (currentIndex == 1) return;
                          try {
                            context.go('/cart');
                          } catch (_) {}
                        },
                      ),
              ),

              // 3. Profile / Account Tab
              Expanded(
                child: _NavDockItem(
                  icon: isAuthenticated || currentIndex == 2
                      ? Icons.account_circle
                      : Icons.account_circle_outlined,
                  label: 'Profile',
                  isSelected: currentIndex == 2,
                  onTap: () {
                    if (currentIndex == 2) return;
                    try {
                      context.go('/login');
                    } catch (_) {}
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavDockItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavDockItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = AppTheme.pogoTealPrimary;
    final inactiveColor = colorScheme.onSurfaceVariant;

    Widget iconWidget = Icon(
      icon,
      size: 22,
      color: isSelected ? activeColor : inactiveColor,
    );

    if (badgeCount > 0) {
      iconWidget = Badge(
        backgroundColor: AppTheme.pogoValorRed,
        label: Text(
          '$badgeCount',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontSize: 10,
          ),
        ),
        child: iconWidget,
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withAlpha(24)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
