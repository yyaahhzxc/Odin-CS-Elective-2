import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/poke_api_service.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/pokemon_card.dart';

/// Main screen displaying the 27 starter Pokémon from Generation 1 to 9.
///
/// ## Key Architectural Features:
/// 1. **Stateful Lifecycle Management**: The [Future] is initialized once in [initState]
///    to avoid redundant HTTP requests during widget rebuilds.
/// 2. **Centered Minimal Header**: Clean, centered app bar featuring the "Starter Pokédex" title.
/// 3. **Centered Generation Dividers**: Each generation block is separated by a simplified,
///    centered label ("Generation 1 • Kanto") flanked by subtle divider lines.
/// 4. **3-Starter Generation Row**: Starters are displayed side-by-side in a 3-item row per generation.
/// 5. **Borderless Pokémon Presentation**: Minimalist, card-free presentation styled after PokémonDB.
/// 6. **Scope Compliance**: Terminates strictly at the grid/list view without detail page navigation.
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
    _startersFuture = _apiService.fetchStarterPokemons();
  }

  /// Refreshes the dataset by re-executing the API request and triggering a rebuild.
  Future<void> _refreshData() async {
    setState(() {
      _startersFuture = _apiService.fetchStarterPokemons();
    });
    await _startersFuture;
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  /// Builds a simplified, centered generation section divider flanked by hairline lines.
  Widget _buildGenerationHeader(int gen, String region) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          // Left hairline divider
          const Expanded(
            child: Divider(
              color: Color(0xFFE5E7EB),
              thickness: 1.0,
            ),
          ),

          // Centered generation label: e.g., "Generation 1 • Kanto"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Generation $gen • $region',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: Color(0xFF6B7280),
              ),
            ),
          ),

          // Right hairline divider
          const Expanded(
            child: Divider(
              color: Color(0xFFE5E7EB),
              thickness: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Clean neutral canvas
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFE5E7EB),
            height: 1.0,
          ),
        ),
        title: const Text(
          'Starter Pokédex',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4B5563), size: 20),
            tooltip: 'Refresh Pokémon',
            onPressed: _refreshData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: _startersFuture,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }

          // 2. Error State
          if (snapshot.hasError) {
            return ErrorView(
              errorMessage: snapshot.error.toString().replaceFirst('Exception: ', ''),
              onRetry: _refreshData,
            );
          }

          // 3. Empty State
          final List<Pokemon>? pokemons = snapshot.data;
          if (pokemons == null || pokemons.isEmpty) {
            return const EmptyView();
          }

          // Group Pokémon by Generation (Generations 1 to 9)
          final Map<int, List<Pokemon>> generationMap = {};
          for (final pokemon in pokemons) {
            generationMap.putIfAbsent(pokemon.generation, () => []).add(pokemon);
          }

          final List<int> sortedGens = generationMap.keys.toList()..sort();

          // 4. Success State: Scrollable generation blocks with 3 starters per row
          return RefreshIndicator(
            color: const Color(0xFF2563EB),
            backgroundColor: Colors.white,
            onRefresh: _refreshData,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: sortedGens.length,
                  itemBuilder: (context, index) {
                    final int gen = sortedGens[index];
                    final List<Pokemon> starters = generationMap[gen] ?? [];
                    final String region = starters.isNotEmpty ? starters.first.regionName : '';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 36.0), // Generous space between generations
                      child: Column(
                        children: [
                          // Centered Generation Divider: "Generation X • Region"
                          _buildGenerationHeader(gen, region),

                          // 3 Starters displayed across a 3-item row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: starters.map((pokemon) {
                              return Expanded(
                                child: PokemonCard(pokemon: pokemon),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
