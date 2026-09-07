import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/product_data.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_confirmation_screen.dart';
import '../screens/home_screen.dart';
import '../screens/product_detail_screen.dart';
import '../state/cart_state.dart';

/// Navigation 2.0 router configuration utilizing [GoRouter].
///
/// Configures declarative URL-based routing for the entire application,
/// including route guards and native slide page transitions.
class AppRouter {
  AppRouter._();

  /// Constructs the application [GoRouter] instance with injected state dependencies.
  static GoRouter createRouter({
    required VoidCallback onToggleTheme,
    required bool Function() isDarkModeGetter,
    required CartManager cartManager,
  }) {
    return GoRouter(
      initialLocation: '/',
      routes: [
        // Route: Home Screen (Product Catalog)
        GoRoute(
          path: '/',
          pageBuilder: (context, state) {
            return MaterialPage(
              key: state.pageKey,
              child: HomeScreen(
                onToggleTheme: onToggleTheme,
                isDarkMode: isDarkModeGetter(),
              ),
            );
          },
        ),

        // Route: Product Details with slide transition
        GoRoute(
          path: '/product/:id',
          pageBuilder: (context, state) {
            final productId = state.pathParameters['id'];

            // Locate the product matching the route parameter
            final product = mockProducts.firstWhere(
              (p) => p.id == productId,
              orElse: () => mockProducts.first,
            );

            return _buildSlideTransition(
              state: state,
              child: ProductDetailScreen(product: product),
            );
          },
        ),

        // Route: Shopping Cart Screen
        GoRoute(
          path: '/cart',
          pageBuilder: (context, state) {
            return _buildSlideTransition(
              state: state,
              child: const CartScreen(),
            );
          },
        ),

        // Route: Checkout Confirmation Screen (Reachable only when cart has items)
        GoRoute(
          path: '/checkout',
          redirect: (context, state) {
            // Guard: Automatically redirect back to cart if attempted with empty cart
            if (cartManager.isEmpty) {
              return '/cart';
            }
            return null;
          },
          pageBuilder: (context, state) {
            return _buildSlideTransition(
              state: state,
              child: const CheckoutConfirmationScreen(),
            );
          },
        ),
      ],

      // Fallback screen for unknown routes
      errorBuilder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Page Not Found')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('404 - Requested screen does not exist.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Return to Shop'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Helper generating a natural right-to-left [SlideTransition] page.
  static CustomTransitionPage<void> _buildSlideTransition({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: Curves.easeInOut),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
