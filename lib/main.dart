import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/supabase_config.dart';
import 'router/app_router.dart';
import 'state/cart_state.dart';
import 'state/catalog_state.dart';
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

  runApp(const PokeMartApp());
}

/// Root widget of the application.
///
/// Implemented as a [StatefulWidget] to manage the global [ThemeMode]
/// (Light vs. Dark mode) dynamically across the entire application lifecycle,
/// while providing scoped state via [CatalogScope] and [CartScope].
class PokeMartApp extends StatefulWidget {
  final CatalogManager? catalogManager;
  final CartManager? cartManager;

  const PokeMartApp({
    super.key,
    this.catalogManager,
    this.cartManager,
  });

  @override
  State<PokeMartApp> createState() => _PokeMartAppState();
}

class _PokeMartAppState extends State<PokeMartApp> {
  // Application-wide theme mode state
  ThemeMode _themeMode = ThemeMode.light;

  // Centralized shopping cart manager instance
  late final CartManager _cartManager;

  // Centralized product catalog & pagination manager instance
  late final CatalogManager _catalogManager;

  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _cartManager = widget.cartManager ?? CartManager();
    _catalogManager = widget.catalogManager ?? CatalogManager();

    // Initial fetch of catalog products from Supabase if not preloaded
    if (_catalogManager.products.isEmpty) {
      _catalogManager.fetchCatalog();
    }

    // Initialize Navigation 2.0 router with callback hooks and cart manager
    _router = AppRouter.createRouter(
      onToggleTheme: _toggleThemeMode,
      isDarkModeGetter: () => _themeMode == ThemeMode.dark,
      cartManager: _cartManager,
    );
  }

  @override
  void dispose() {
    if (widget.catalogManager == null) _catalogManager.dispose();
    if (widget.cartManager == null) _cartManager.dispose();
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
    return CatalogScope(
      manager: _catalogManager,
      child: CartScope(
        notifier: _cartManager,
        child: MaterialApp.router(
          title: 'PokéMart - Galar Region',
          debugShowCheckedModeBanner: false,

          // Centralized Design Theming applied globally
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeMode,

          // Navigation 2.0 configuration
          routerConfig: _router,
        ),
      ),
    );
  }
}
