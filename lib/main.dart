import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/supabase_config.dart';
import 'providers/app_providers.dart';
import 'router/app_router.dart';
import 'state/auth_state.dart';
import 'state/cart_state.dart';
import 'state/catalog_state.dart';
import 'state/order_state.dart';
import 'theme/app_theme.dart';

/// Entry point of the PokéMart Flutter application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase backend connection if configured
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      publishableKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  runApp(
    const ProviderScope(
      child: PokeMartApp(),
    ),
  );
}

/// Root widget of the application.
///
/// Wraps the application in Riverpod [ProviderScope] (if not already wrapped in tests)
/// and provides reactive state via Riverpod providers and scoped inherited notifiers
/// ([AuthScope], [CatalogScope], [CartScope], [OrderScope]).
class PokeMartApp extends StatefulWidget {
  final CatalogManager? catalogManager;
  final CartManager? cartManager;
  final AuthManager? authManager;
  final OrderManager? orderManager;

  const PokeMartApp({
    super.key,
    this.catalogManager,
    this.cartManager,
    this.authManager,
    this.orderManager,
  });

  @override
  State<PokeMartApp> createState() => _PokeMartAppState();
}

class _PokeMartAppState extends State<PokeMartApp> {
  // Application-wide theme mode state
  ThemeMode _themeMode = ThemeMode.light;

  late final AuthManager _authManager;
  late final CartManager _cartManager;
  late final CatalogManager _catalogManager;
  late final OrderManager _orderManager;

  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _cartManager = widget.cartManager ?? CartManager();
    _authManager = widget.authManager ??
        AuthManager(onSignedOut: () => _cartManager.clearCart());
    _catalogManager = widget.catalogManager ?? CatalogManager();
    _orderManager = widget.orderManager ?? OrderManager();

    // Initial fetch of catalog products from Supabase if not preloaded
    if (_catalogManager.products.isEmpty) {
      _catalogManager.fetchCatalog();
    }

    // Initialize Navigation 2.0 router with callback hooks and state managers
    _router = AppRouter.createRouter(
      onToggleTheme: _toggleThemeMode,
      isDarkModeGetter: () => _themeMode == ThemeMode.dark,
      cartManager: _cartManager,
      catalogManager: _catalogManager,
      orderManager: _orderManager,
    );
  }

  @override
  void dispose() {
    if (widget.authManager == null) _authManager.dispose();
    if (widget.catalogManager == null) _catalogManager.dispose();
    if (widget.cartManager == null) _cartManager.dispose();
    if (widget.orderManager == null) _orderManager.dispose();
    super.dispose();
  }

  /// Toggles between Light and Dark theme modes and triggers a rebuild.
  void _toggleThemeMode() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        cartProvider.overrideWith((ref) => _cartManager),
        authProvider.overrideWith((ref) => _authManager),
        catalogProvider.overrideWith((ref) => _catalogManager),
        orderProvider.overrideWith((ref) => _orderManager),
      ],
      child: AuthScope(
        manager: _authManager,
        child: CatalogScope(
          manager: _catalogManager,
          child: CartScope(
            notifier: _cartManager,
            child: OrderScope(
              manager: _orderManager,
              child: MaterialApp.router(
                title: 'PokéMart Official Store',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: _themeMode,
                routerConfig: _router,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
