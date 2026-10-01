import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/poke_api_service.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/pokemon_card.dart';

/// Main screen displaying the scrollable grid of starter Pokémon from Generation 1 to 9.
///
/// ## Key Architectural Features:
/// 1. **Stateful Lifecycle Management**: The [Future] instance is initialized in [initState],
///    not inside [build]. Creating the future in `build` is an anti-pattern because any parent
///    re-render would redundantly re-trigger network requests.
/// 2. **Pull-to-Refresh Capability**: Wrapped in a [RefreshIndicator] allowing the user
///    to trigger fresh network requests anytime.
/// 3. **Responsive Grid Layout**: Calculates column count adaptively based on available
///    screen width (mobile, tablet, desktop).
/// 4. **Four Core Async States**: Gracefully handles Loading, Error, Empty, and Success states.
/// 5. **Scope Compliance**: The screen strictly terminates at the grid view; no navigation
///    to a details view is implemented, as specified by activity instructions.
class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  /// Reference to the API service layer.
  final PokeApiService _apiService = PokeApiService();

  /// Cached Future reference storing the asynchronous network call.
  late Future<List<Pokemon>> _startersFuture;

  @override
  void initState() {
    super.initState();
    // Initialize data fetching once when the widget is inserted into the tree.
    _startersFuture = _apiService.fetchStarterPokemons();
  }

  /// Refreshes the dataset by re-executing the API request and triggering a rebuild.
  Future<void> _refreshData() async {
    setState(() {
      _startersFuture = _apiService.fetchStarterPokemons();
    });
    // Wait for the new future to complete so the RefreshIndicator's spinner syncs properly
    await _startersFuture;
  }

  @override
  void dispose() {
    // Clean up HTTP client resources when the screen is disposed
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Clean neutral canvas
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1.0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFE5E7EB),
            height: 1.0,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Pokédex Starters',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Generations 1 – 9 • 27 Pokémon',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4B5563)),
            tooltip: 'Refresh Pokémon',
            onPressed: _refreshData,
          ),
        ],
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: _startersFuture,
        builder: (context, snapshot) {
          // 1. Loading State: Connection is waiting for HTTP response
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }

          // 2. Error State: Network failure, timeout, or parsing error occurred
          if (snapshot.hasError) {
            return ErrorView(
              errorMessage: snapshot.error.toString().replaceFirst('Exception: ', ''),
              onRetry: _refreshData,
            );
          }

          // 3. Empty State: Network succeeded but zero items were returned
          final List<Pokemon>? pokemons = snapshot.data;
          if (pokemons == null || pokemons.isEmpty) {
            return const EmptyView();
          }

          // 4. Success State: Render responsive, scrollable grid
          return RefreshIndicator(
            color: const Color(0xFF2563EB),
            backgroundColor: Colors.white,
            onRefresh: _refreshData,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Adaptive column count depending on screen width
                final double width = constraints.maxWidth;
                final int crossAxisCount = width >= 1200
                    ? 6
                    : width >= 900
                        ? 4
                        : width >= 600
                            ? 3
                            : 2;

                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 0.78, // Proportional height for card content
                  ),
                  itemCount: pokemons.length,
                  itemBuilder: (context, index) {
                    final Pokemon pokemon = pokemons[index];
                    return PokemonCard(pokemon: pokemon);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
