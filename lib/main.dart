import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/supabase_config.dart';
import 'router/app_router.dart';
import 'state/cart_state.dart';
import 'state/catalog_state.dart';
import 'theme/app_theme.dart';

/// Entry point of the CSShop Flutter application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase backend connection if configured
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      publishableKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  runApp(const CSShopApp());
}

/// Root widget of the application.
///
/// Implemented as a [StatefulWidget] to manage the global [ThemeMode]
/// (Light vs. Dark mode) dynamically across the entire application lifecycle,
/// while providing scoped state via [CatalogScope] and [CartScope].
class CSShopApp extends StatefulWidget {
  const CSShopApp({super.key});

  @override
  State<CSShopApp> createState() => _CSShopAppState();
}

class _CSShopAppState extends State<CSShopApp> {
  // Application-wide theme mode state
  ThemeMode _themeMode = ThemeMode.light;

  // Centralized shopping cart manager instance
  final CartManager _cartManager = CartManager();

  // Centralized product catalog & pagination manager instance
  final CatalogManager _catalogManager = CatalogManager();

  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    // Initial fetch of catalog products from Supabase
    _catalogManager.fetchCatalog();

    // Initialize Navigation 2.0 router with callback hooks and cart manager
    _router = AppRouter.createRouter(
      onToggleTheme: _toggleThemeMode,
      isDarkModeGetter: () => _themeMode == ThemeMode.dark,
      cartManager: _cartManager,
    );
  }

  @override
  void dispose() {
    _catalogManager.dispose();
    _cartManager.dispose();
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
          title: 'CSShop - CSSEC Merch',
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
