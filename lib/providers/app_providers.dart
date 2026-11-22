import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../state/auth_state.dart';
import '../state/cart_state.dart';
import '../state/catalog_state.dart';
import '../state/order_state.dart';

/// Riverpod providers structuring the application into strict layers:
/// Screens -> Providers -> Services -> Supabase.

/// Provides the [SupabaseService] repository.
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

/// Provides the [AuthService] repository.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provides the application-wide light/dark theme mode.
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.light;
});

/// Provides reactive shopping cart state via [CartManager].
final cartProvider = ChangeNotifierProvider<CartManager>((ref) {
  return CartManager();
});

/// Provides reactive order placement, customer order history, and Admin order list state.
final orderProvider = ChangeNotifierProvider<OrderManager>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return OrderManager(service: service);
});

/// Provides reactive product catalog, search, filter, pagination, and Admin CRUD state.
///
/// Fetching is triggered only once the user passes the authentication gate.
final catalogProvider = ChangeNotifierProvider<CatalogManager>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return CatalogManager(service: service);
});

/// Provides reactive authentication and role state via [AuthManager].
///
/// Loads catalog data upon sign-in and clears cart, orders, and catalog on sign-out.
final authProvider = ChangeNotifierProvider<AuthManager>((ref) {
  final authService = ref.watch(authServiceProvider);
  final cartManager = ref.read(cartProvider);
  final orderManager = ref.read(orderProvider);
  final catalogManager = ref.read(catalogProvider);
  return AuthManager(
    service: authService,
    onSignedIn: () => catalogManager.fetchCatalog(),
    onSignedOut: () {
      cartManager.clearCart();
      orderManager.clearOrders();
      catalogManager.clearCatalog();
    },
  );
});

/// Provides the declarative [GoRouter] wired to [authProvider] for route-level auth gating.
final routerProvider = Provider<GoRouter>((ref) {
  final authManager = ref.read(authProvider);
  final catalogManager = ref.read(catalogProvider);
  final orderManager = ref.read(orderProvider);

  final router = AppRouter.createRouter(
    authManager: authManager,
    catalogManager: catalogManager,
    orderManager: orderManager,
  );
  ref.onDispose(router.dispose);
  return router;
});
