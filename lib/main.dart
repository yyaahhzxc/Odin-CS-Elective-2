import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/pokemon_provider.dart';
import 'screens/pokedex_screen.dart';

/// Application entry point.
void main() {
  runApp(const PokedexApp());
}

/// Root widget of the Pokédex application.
///
/// Injects [PokemonProvider] into the widget hierarchy via [ChangeNotifierProvider].
/// Adheres to requirement 4 (Manage states using Provider) and requirement 8 (App State).
class PokedexApp extends StatelessWidget {
  final PokemonProvider? provider;

  const PokedexApp({super.key, this.provider});

  @override
  Widget build(BuildContext context) {
    final Widget app = MaterialApp(
      title: 'Pokédex Starters',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF111827),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const PokedexScreen(),
    );

    if (provider != null) {
      return ChangeNotifierProvider<PokemonProvider>.value(
        value: provider!,
        child: app,
      );
    }

    return ChangeNotifierProvider<PokemonProvider>(
      create: (_) => PokemonProvider()..fetchPokemons(),
      child: app,
    );
  }
}
