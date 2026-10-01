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
/// 2. **3-Starter Generation Row**: Each generation displays its 3 starters (Grass, Fire, Water)
///    cleanly across three columns in a single row.
/// 3. **Generation Separation & Headers**: Distinct generation divider headers with region tags
///    and generous vertical spacing separating each generation.
/// 4. **Minimalist Borderless Styling**: Clean presentation inspired by PokémonDB without
///    enclosing card boxes or shadows.
/// 5. **Scope Compliance**: Terminates at the grid/list view without detail page navigation.
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

  /// Builds a minimalist section header for each generation with region tag and divider line.
  Widget _buildGenerationHeader(int gen, String region) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Generation Title
          Text(
            'GENERATION $gen',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(width: 8),

          // Region pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              region.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Subtle hairline divider separating generation blocks
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFE5E7EB),
            height: 1.0,
          ),
        ),
        title: Row(
          children: [
            // Pokéball accent icon indicator
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444), // Pokémon red accent
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            // Title & Subtitle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Pokédex',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Starter Pokémon • Generations 1–9',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Total count chip
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Center(
                child: Text(
                  '27 Starters',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
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
                      padding: const EdgeInsets.only(bottom: 36.0), // Extra space between generations
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Generation Header with Region Tag and Divider Line
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
