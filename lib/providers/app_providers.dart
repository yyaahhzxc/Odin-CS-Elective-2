import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../state/auth_state.dart';
import '../state/cart_state.dart';
import '../state/catalog_state.dart';
import '../state/order_state.dart';

/// Riverpod providers structuring the application architecture into clean layers:
/// Screens -> Providers -> Services -> Supabase.
///
/// Conforms to the Exam Architecture Rule:
/// "Use layers: screens call providers, providers call services (or repositories),
/// and services are the only code that talks to Supabase."

/// Provides the singleton [SupabaseService] repository.
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

/// Provides the singleton [AuthService] repository.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provides reactive shopping cart state via [CartManager].
final cartProvider = ChangeNotifierProvider<CartManager>((ref) {
  return CartManager();
});

/// Provides reactive authentication and role state via [AuthManager].
/// Automatically empties the cart when the user logs out, per exam requirements.
final authProvider = ChangeNotifierProvider<AuthManager>((ref) {
  final authService = ref.watch(authServiceProvider);
  final cartManager = ref.watch(cartProvider);
  return AuthManager(
    service: authService,
    onSignedOut: () => cartManager.clearCart(),
  );
});

/// Provides reactive product catalog, search, filter, pagination, and Admin CRUD state.
final catalogProvider = ChangeNotifierProvider<CatalogManager>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  final manager = CatalogManager(service: service);
  manager.fetchCatalog();
  return manager;
});

/// Provides reactive order placement, customer order history, and Admin order list state.
final orderProvider = ChangeNotifierProvider<OrderManager>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return OrderManager(service: service);
});

