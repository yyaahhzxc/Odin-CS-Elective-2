import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/error_view.dart';
import '../widgets/favorites_panel.dart';
import '../widgets/loading_view.dart';
import '../widgets/pokeball_icon.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/type_filter_bar.dart';

/// Main screen displaying the 27 starter Pokemon across Generations 1 to 9.
///
/// Refactored to Riverpod architecture (Exam Requirement):
/// - Manages loading, error, and success states through [pokemonListProvider].
/// - Pull-to-refresh and AppBar refresh recall the existing [fetchPokemons] method.
/// - Integrated retractable Favorites Panel in the AppBar with live count badge.
/// - Type Filter Bar allowing selection and clearing of elemental types.
class PokedexScreen extends ConsumerStatefulWidget {
  const PokedexScreen({super.key});

  @override
  ConsumerState<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<PokedexScreen> {
  bool _isFavoritesPanelExpanded = false;

  void _toggleFavoritesPanel() {
    setState(() {
      _isFavoritesPanelExpanded = !_isFavoritesPanelExpanded;
    });
  }

  /// Builds a simplified, centered generation section divider flanked by hairline lines.
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
    final favorites = ref.watch(favoritesProvider);
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
        leading: Tooltip(
          message: _isFavoritesPanelExpanded
              ? 'Collapse Favorites'
              : 'Expand Favorites',
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _toggleFavoritesPanel,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  PokeballIcon(
                    isFavorite: favorites.isNotEmpty,
                    size: 20,
                  ),
                  if (favorites.isNotEmpty)
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '${favorites.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
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
      body: Column(
        children: [
          // 1. Retractable Favorites Panel (Collapsible)
          FavoritesPanel(
            isExpanded: _isFavoritesPanelExpanded,
            onToggle: _toggleFavoritesPanel,
          ),

          // 2. Main Content Area with Type Filter Bar and Pokemon Grid
          Expanded(
            child: asyncPokemons.when(
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
                          // Type Filter Bar
                          const TypeFilterBar(),
                          const SizedBox(height: 12),

                          // Empty filtered results check
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
                                          ? 'No Pokémon found matching type "$activeType".'
                                          : 'No Pokémon found.',
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
          ),
        ],
      ),
    );
  }

  /// Groups Pokemon by generation and returns structured generation blocks
  /// organized into a consistent 3-item row layout.
  List<Widget> _buildPokemonSections(List<Pokemon> pokemons) {
    final Map<int, List<Pokemon>> generationMap = {};
    for (final pokemon in pokemons) {
      generationMap.putIfAbsent(pokemon.generation, () => []).add(pokemon);
    }

    final sortedGens = generationMap.keys.toList()..sort();

    return sortedGens.map((gen) {
      final starters = generationMap[gen] ?? [];
      final region = starters.isNotEmpty ? starters.first.regionName : '';

      // Partition starters into rows of exactly 3
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
