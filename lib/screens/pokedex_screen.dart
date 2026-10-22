import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/error_view.dart';
import '../widgets/favorites_panel.dart';
import '../widgets/loading_view.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/type_filter_bar.dart';

/// Main Pokédex screen displaying starter Pokémon grouped by generation.
class PokedexScreen extends ConsumerStatefulWidget {
  const PokedexScreen({super.key});

  @override
  ConsumerState<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<PokedexScreen> {
  bool _isFavoritesPanelExpanded = false;
  bool _isTypeFilterExpanded = false;

  void _toggleFavoritesPanel() {
    setState(() {
      _isFavoritesPanelExpanded = !_isFavoritesPanelExpanded;
    });
  }

  void _toggleTypeFilter() {
    setState(() {
      _isTypeFilterExpanded = !_isTypeFilterExpanded;
    });
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}';
  }

  Widget _buildGenerationHeader(int gen, String region) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          const Expanded(
            child: Divider(
              color: Color(0xFFE2E8F0),
              thickness: 1.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Generation $gen • $region',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          const Expanded(
            child: Divider(
              color: Color(0xFFE2E8F0),
              thickness: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncPokemons = ref.watch(pokemonListProvider);
    final activeType = ref.watch(selectedTypeFilterProvider);
    final filteredPokemons = ref.watch(filteredPokemonsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1.0,
          ),
        ),
        title: const Text(
          'Starter Pokédex',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Color(0xFF475569), size: 20),
            tooltip: 'Refresh Pokémon',
            onPressed: () {
              ref
                  .read(pokemonListProvider.notifier)
                  .fetchPokemons(forceRefresh: true);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: asyncPokemons.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          errorMessage: err.toString().replaceFirst('Exception: ', ''),
          onRetry: () {
            ref
                .read(pokemonListProvider.notifier)
                .fetchPokemons(forceRefresh: true);
          },
        ),
        data: (_) {
          return RefreshIndicator(
            color: const Color(0xFF0F172A),
            backgroundColor: Colors.white,
            onRefresh: () => ref
                .read(pokemonListProvider.notifier)
                .fetchPokemons(forceRefresh: true),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                      top: 8.0, bottom: 28.0, left: 16.0, right: 16.0),
                  children: [
                    TypeFilterBar(
                      isExpanded: _isTypeFilterExpanded,
                      onToggle: _toggleTypeFilter,
                    ),
                    const SizedBox(height: 8),
                    FavoritesPanel(
                      isExpanded: _isFavoritesPanelExpanded,
                      onToggle: _toggleFavoritesPanel,
                    ),
                    const SizedBox(height: 12),
                    if (filteredPokemons.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 48, horizontal: 20),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.filter_list_off_rounded,
                                size: 40,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                activeType != null
                                    ? 'No Pokémon found matching type "${_capitalize(activeType)}".'
                                    : 'No Pokémon found.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  side: const BorderSide(
                                      color: Color(0xFFCBD5E1)),
                                ),
                                onPressed: () => ref
                                    .read(selectedTypeFilterProvider
                                        .notifier)
                                    .clearFilter(),
                                child: const Text('Clear Filter'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._buildPokemonSections(filteredPokemons),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildPokemonSections(List<Pokemon> pokemons) {
    final Map<int, List<Pokemon>> generationMap = {};
    for (final pokemon in pokemons) {
      generationMap.putIfAbsent(pokemon.generation, () => []).add(pokemon);
    }

    final sortedGens = generationMap.keys.toList()..sort();

    return sortedGens.map((gen) {
      final starters = generationMap[gen] ?? [];
      final region = starters.isNotEmpty ? starters.first.regionName : '';

      final rows = <List<Pokemon>>[];
      for (var i = 0; i < starters.length; i += 3) {
        final end = (i + 3 < starters.length) ? i + 3 : starters.length;
        rows.add(starters.sublist(i, end));
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 28.0),
        child: Column(
          children: [
            _buildGenerationHeader(gen, region),
            ...rows.map((row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < 3; i++)
                      Expanded(
                        child: i < row.length
                            ? PokemonCard(pokemon: row[i])
                            : const SizedBox.shrink(),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    }).toList();
  }
}
