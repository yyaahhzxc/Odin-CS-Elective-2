import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/supabase_config.dart';
import 'providers/app_providers.dart';
import 'theme/app_theme.dart';

/// Entry point of the PokéMart Flutter application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

/// Root widget consuming Riverpod theme, auth, catalog, and router providers.
class PokeMartApp extends ConsumerWidget {
  const PokeMartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);
    final auth = ref.watch(authProvider);

    if (auth.isAuthenticated) {
      final catalog = ref.read(catalogProvider);
      if (!catalog.hasLoadedOnce &&
          !catalog.isLoading &&
          catalog.errorMessage == null) {
        Future.microtask(() => ref.read(catalogProvider).fetchCatalog());
      }
    }

    return MaterialApp.router(
      title: 'PokéMart Official Store',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
