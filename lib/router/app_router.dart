import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/product_data.dart';
import '../screens/home_screen.dart';
import '../screens/product_detail_screen.dart';

/// Navigation 2.0 router configuration utilizing [GoRouter].
///
/// Sets up declarative URL-based routing for the application,
/// including a clean, native-feeling slide transition when navigating
/// between the catalog and product details.
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

        // Product details route with horizontal slide transition
        GoRoute(
          path: '/product/:id',
          pageBuilder: (context, state) {
            final productId = state.pathParameters['id'];

            // Locate the product matching the route parameter
            final product = mockProducts.firstWhere(
              (p) => p.id == productId,
              orElse: () => mockProducts.first,
            );

            return CustomTransitionPage(
              key: state.pageKey,
              child: ProductDetailScreen(product: product),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                // Natural right-to-left slide transition
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
