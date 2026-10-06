import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/pokemon_card.dart';

/// Main screen displaying the 27 starter Pokémon from Generations 1 to 9.
///
/// Refactored to adhere strictly to State Management specifications:
/// - Replaces ephemeral [FutureBuilder] state with centralized [PokemonProvider] App State.
/// - Handles Success, Loading, and Error states derived from [PokemonProvider] (Requirement 4).
/// - Triggers API calls through the provider method [PokemonProvider.fetchPokemons] (Requirement 6).
/// - Includes refresh functionality via [RefreshIndicator] and AppBar action (Requirement 7).
/// - All UI values derived from App State (Requirement 8).
class PokedexScreen extends StatelessWidget {
  const PokedexScreen({super.key});

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
    final provider = context.watch<PokemonProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
            onPressed: () => context.read<PokemonProvider>().fetchPokemons(forceRefresh: true),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, PokemonProvider provider) {
    // 1. Loading State
    if (provider.status == PokemonStateStatus.loading ||
        provider.status == PokemonStateStatus.initial) {
      return const LoadingView();
    }

    // 2. Error State
    if (provider.status == PokemonStateStatus.error) {
      return ErrorView(
        errorMessage: provider.errorMessage,
        onRetry: () => context.read<PokemonProvider>().fetchPokemons(forceRefresh: true),
      );
    }

    // 3. Empty State Check
    final List<Pokemon> pokemons = provider.pokemons;
    if (pokemons.isEmpty) {
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
      onRefresh: () => context.read<PokemonProvider>().fetchPokemons(forceRefresh: true),
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
                padding: const EdgeInsets.only(bottom: 36.0),
                child: Column(
                  children: [
                    // Centered Generation Divider
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
  }
}
