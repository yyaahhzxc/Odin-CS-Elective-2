import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Entry point of the CSShop Flutter application.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CSShopApp());
}

/// Root widget of the application.
///
/// Implemented as a [StatefulWidget] to manage the global [ThemeMode]
/// (Light vs. Dark mode) dynamically across the entire application lifecycle.
class CSShopApp extends StatefulWidget {
  const CSShopApp({super.key});

  @override
  State<CSShopApp> createState() => _CSShopAppState();
}

class _CSShopAppState extends State<CSShopApp> {
  // Application-wide theme mode state
  ThemeMode _themeMode = ThemeMode.light;

  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    // Initialize Navigation 2.0 router with callback hooks for theme toggling
    _router = AppRouter.createRouter(
      onToggleTheme: _toggleThemeMode,
      isDarkModeGetter: () => _themeMode == ThemeMode.dark,
    );
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
    return MaterialApp.router(
      title: 'CSShop - CSSEC Merch',
      debugShowCheckedModeBanner: false,

      // Centralized Design Theming applied globally
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,

      // Navigation 2.0 configuration
      routerConfig: _router,
    );
  }
}
