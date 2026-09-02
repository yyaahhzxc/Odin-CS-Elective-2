import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/product_data.dart';
import '../screens/home_screen.dart';
import '../screens/product_detail_screen.dart';

/// Navigation 2.0 router configuration utilizing [GoRouter].
///
/// Sets up declarative URL-based routing for the entire application,
/// fulfilling the Navigation 2.0 project requirement.
class AppRouter {
  AppRouter._();

  /// Constructs the application [GoRouter] instance with injected theme state handlers.
  static GoRouter createRouter({
    required VoidCallback onToggleTheme,
    required bool Function() isDarkModeGetter,
  }) {
    return GoRouter(
      initialLocation: '/',
      routes: [
        // Route: Home Screen (Product Catalog)
        GoRoute(
          path: '/',
          builder: (context, state) {
            return HomeScreen(
              onToggleTheme: onToggleTheme,
              isDarkMode: isDarkModeGetter(),
            );
          },
        ),

        // Route: Product Detail Screen (Reached via Navigation 2.0)
        GoRoute(
          path: '/product/:id',
          builder: (context, state) {
            final productId = state.pathParameters['id'];

            // Locate the product matching the route parameter
            final product = mockProducts.firstWhere(
              (p) => p.id == productId,
              orElse: () => mockProducts.first,
            );

            return ProductDetailScreen(product: product);
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
}
