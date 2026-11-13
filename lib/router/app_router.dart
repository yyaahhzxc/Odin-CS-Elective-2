import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/product_data.dart';
import '../screens/admin_product_form_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_confirmation_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/product_detail_screen.dart';
import '../state/cart_state.dart';
import '../state/catalog_state.dart';
import '../state/order_state.dart';

/// Navigation 2.0 router configuration utilizing [GoRouter].
///
/// Configures declarative URL-based routing for the entire application,
/// including route guards for Customer & Admin flows and slide page transitions.
class AppRouter {
  AppRouter._();

  /// Constructs the application [GoRouter] instance with injected state dependencies.
  static GoRouter createRouter({
    required VoidCallback onToggleTheme,
    required bool Function() isDarkModeGetter,
    required CartManager cartManager,
    CatalogManager? catalogManager,
    OrderManager? orderManager,
  }) {
    return GoRouter(
      initialLocation: '/',
      routes: [
        // Route: Home Screen (Product Catalog - Customer & Admin Views)
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
            final productId = state.pathParameters['id'] ?? '';

            // Locate the product from live CatalogManager first, falling back to mockProducts
            final liveProduct = catalogManager?.findProductById(productId);
            final product = liveProduct ??
                mockProducts.firstWhere(
                  (p) => p.id == productId,
                  orElse: () => mockProducts.first,
                );

            return _buildSlideTransition(
              state: state,
              child: ProductDetailScreen(product: product),
            );
          },
        ),

        // Route: Shopping Cart Screen (Customer)
        GoRoute(
          path: '/cart',
          pageBuilder: (context, state) {
            return _buildSlideTransition(
              state: state,
              child: const CartScreen(),
            );
          },
        ),

        // Route: Checkout Confirmation Screen
        GoRoute(
          path: '/checkout',
          redirect: (context, state) {
            // Allow access if cart has items OR if an order was just placed
            if (cartManager.isEmpty && orderManager?.lastPlacedOrder == null) {
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

        // Route: Customer Order History Screen
        GoRoute(
          path: '/orders',
          pageBuilder: (context, state) {
            return _buildSlideTransition(
              state: state,
              child: const OrdersScreen(isAdminMode: false),
            );
          },
        ),

        // Route: Admin Order List Screen
        GoRoute(
          path: '/admin/orders',
          pageBuilder: (context, state) {
            return _buildSlideTransition(
              state: state,
              child: const OrdersScreen(isAdminMode: true),
            );
          },
        ),

        // Route: Admin Add Product Form
        GoRoute(
          path: '/admin/product/add',
          pageBuilder: (context, state) {
            return _buildSlideTransition(
              state: state,
              child: const AdminProductFormScreen(),
            );
          },
        ),

        // Route: Admin Edit Product Form (Pre-filled with existing product values)
        GoRoute(
          path: '/admin/product/edit/:id',
          pageBuilder: (context, state) {
            final productId = state.pathParameters['id'] ?? '';
            final existing = catalogManager?.findProductById(productId) ??
                mockProducts.firstWhere(
                  (p) => p.id == productId,
                  orElse: () => mockProducts.first,
                );

            return _buildSlideTransition(
              state: state,
              child: AdminProductFormScreen(existingProduct: existing),
            );
          },
        ),

        // Route: User Authentication & Account Screen
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) {
            return _buildSlideTransition(
              state: state,
              child: const LoginScreen(),
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
