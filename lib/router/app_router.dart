import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/admin_product_form_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_confirmation_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/product_detail_screen.dart';
import '../state/auth_state.dart';
import '../state/catalog_state.dart';
import '../state/order_state.dart';

/// Navigation 2.0 router configuration utilizing [GoRouter].
///
/// Enforces the top-level authentication gate redirecting unauthenticated users
/// to `/login` and configures transitions across Customer and Admin screens.
class AppRouter {
  AppRouter._();

  /// Constructs the application [GoRouter] instance with auth-gate redirection.
  static GoRouter createRouter({
    required AuthManager authManager,
    required CatalogManager catalogManager,
    required OrderManager orderManager,
  }) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authManager,
      redirect: (context, state) {
        final isAuthenticated = authManager.isAuthenticated;
        final location = state.matchedLocation;

        if (!isAuthenticated && location != '/login') {
          return '/login';
        }
        if (isAuthenticated && location == '/login') {
          return '/';
        }
        return null;
      },
      routes: [
        // Route: Sign In & Sign Up Auth Gate (unauthenticated)
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) {
            return _buildFadeTransition(
              state: state,
              child: const LoginScreen(),
            );
          },
        ),

        // Route: Account Profile Screen (authenticated)
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) {
            return _buildFadeTransition(
              state: state,
              child: const LoginScreen(),
            );
          },
        ),

        // Route: Home Screen (Product Catalog - Customer & Admin Views)
        GoRoute(
          path: '/',
          pageBuilder: (context, state) {
            return _buildFadeTransition(
              state: state,
              child: const HomeScreen(),
            );
          },
        ),

        // Route: Product Details with slide transition (supports Hero image flight)
        GoRoute(
          path: '/product/:id',
          pageBuilder: (context, state) {
            final productId = state.pathParameters['id'] ?? '';
            final liveProduct = catalogManager.findProductById(productId);
            return _buildSlideFadeTransition(
              state: state,
              child: ProductDetailScreen(
                productId: productId,
                initialProduct: liveProduct,
              ),
            );
          },
        ),

        // Route: Shopping Cart Screen (Customer)
        GoRoute(
          path: '/cart',
          pageBuilder: (context, state) {
            return _buildFadeTransition(
              state: state,
              child: const CartScreen(),
            );
          },
        ),

        // Route: Checkout Confirmation Screen
        GoRoute(
          path: '/checkout',
          redirect: (context, state) {
            if (authManager.isAdmin) {
              return '/';
            }
            if (orderManager.lastPlacedOrder == null) {
              return '/cart';
            }
            return null;
          },
          pageBuilder: (context, state) {
            return _buildSlideFadeTransition(
              state: state,
              child: const CheckoutConfirmationScreen(),
            );
          },
        ),

        // Route: Customer Order History Screen
        GoRoute(
          path: '/orders',
          pageBuilder: (context, state) {
            return _buildSlideFadeTransition(
              state: state,
              child: const OrdersScreen(isAdminMode: false),
            );
          },
        ),

        // Route: Admin Order List Screen
        GoRoute(
          path: '/admin/orders',
          pageBuilder: (context, state) {
            return _buildFadeTransition(
              state: state,
              child: const OrdersScreen(isAdminMode: true),
            );
          },
        ),

        // Route: Admin Add Product Form
        GoRoute(
          path: '/admin/product/add',
          pageBuilder: (context, state) {
            return _buildSlideFadeTransition(
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
            final existing = catalogManager.findProductById(productId);
            return _buildSlideFadeTransition(
              state: state,
              child: AdminProductFormScreen(
                productId: productId,
                existingProduct: existing,
              ),
            );
          },
        ),
      ],
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

  static final Animatable<double> _fadeCurve = CurveTween(
    curve: Curves.easeOut,
  );

  static final Animatable<Offset> _slideTween = Tween<Offset>(
    begin: const Offset(1.0, 0.0),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeOutCubic));

  /// Cross-fade transition for top-level bottom navigation destinations.
  static CustomTransitionPage<void> _buildFadeTransition({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(_fadeCurve),
          child: child,
        );
      },
    );
  }

  /// Slide transition for hierarchical detail and form routes.
  static CustomTransitionPage<void> _buildSlideFadeTransition({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(_slideTween),
          child: child,
        );
      },
    );
  }
}
