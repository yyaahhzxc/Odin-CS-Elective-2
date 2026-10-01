import 'package:flutter/material.dart';
import 'screens/pokedex_screen.dart';

/// Application entry point.
void main() {
  runApp(const PokedexApp());
}

/// Root widget of the Pokédex application.
///
/// Configures a clean, minimalist Material 3 theme inspired by PokémonDB:
/// - Light neutral background canvas (#F9FAFB)
/// - Crisp typography and subtle gray borders
/// - Clean elevation and smooth card transitions
class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
          centerTitle: false,
        ),
      ),
      home: const PokedexScreen(),
    );
  }
}
