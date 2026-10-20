import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/nickname_dialog.dart';
import '../widgets/pokeball_icon.dart';
import '../widgets/type_badge.dart';

/// Screen displaying comprehensive details of an individual Pokemon.
///
/// Refactored to Riverpod architecture:
/// - Reads selected Pokemon from [selectedPokemonProvider].
/// - Displays Pokeball favorite button with live toggle functionality.
/// - Shows nickname management card allowing adding, editing, or removing nicknames.
class PokemonDetailScreen extends ConsumerWidget {
  const PokemonDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemon = ref.watch(selectedPokemonProvider);

    if (pokemon == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Pokémon Details',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'No Pokémon selected in application state.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    final isFavorite = ref.watch(favoritesProvider).contains(pokemon.id);
    final nickname = ref.watch(nicknamesProvider)[pokemon.id];
    final hasNickname = nickname != null && nickname.isNotEmpty;

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          tooltip: 'Back to Pokédex',
          onPressed: () {
            ref.read(selectedPokemonProvider.notifier).clearSelection();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          hasNickname ? nickname : pokemon.displayName,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Remove Favorite' : 'Mark as Favorite',
            icon: PokeballIcon(isFavorite: isFavorite, size: 20),
            onPressed: () {
              ref.read(favoritesProvider.notifier).toggleFavorite(pokemon.id);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Artwork Card
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      // High-res sprite
                      SizedBox(
                        height: 190,
                        child: Center(
                          child: pokemon.imageUrl.isNotEmpty
                              ? Image.network(
                                  pokemon.imageUrl,
                                  fit: BoxFit.contain,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.broken_image_outlined,
                                      size: 64,
                                      color: Color(0xFF94A3B8),
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 64,
                                  color: Color(0xFF94A3B8),
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Monospace Dex Number
                      Text(
                        pokemon.formattedId,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Primary Title: Nickname/Name with inline pencil edit icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              hasNickname ? nickname : pokemon.displayName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_rounded,
                              size: 18,
                              color: Color(0xFF64748B),
                            ),
                            tooltip: hasNickname
                                ? 'Edit Nickname'
                                : 'Assign Nickname',
                            splashRadius: 18,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                            onPressed: () =>
                                NicknameDialog.show(context, pokemon),
                          ),
                        ],
                      ),

                      // Subtitle: Original species name if custom nickname is present
                      if (hasNickname) ...[
                        const SizedBox(height: 2),
                        Text(
                          pokemon.displayName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Elemental Type Badges
                      Wrap(
                        spacing: 6.0,
                        runSpacing: 6.0,
                        alignment: WrapAlignment.center,
                        children: pokemon.types
                            .map((type) => TypeBadge(typeName: type))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Metadata Card (Generation, Region, Dex Number)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        label: 'National Dex Number',
                        value: pokemon.id.toString(),
                      ),
                      const Divider(color: Color(0xFFF1F5F9), height: 20),
                      _buildInfoRow(
                        label: 'Generation',
                        value: 'Gen ${pokemon.generation}',
                      ),
                      const Divider(color: Color(0xFFF1F5F9), height: 20),
                      _buildInfoRow(
                        label: 'Origin Region',
                        value: pokemon.regionName,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
