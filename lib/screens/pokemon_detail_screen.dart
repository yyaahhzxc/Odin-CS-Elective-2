import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/type_badge.dart';

/// Screen displaying comprehensive details of an individual Pokémon.
///
/// In strict accordance with requirements:
/// - Page contents (name, image, and ID) are sourced exclusively from [PokemonProvider] (Requirement 9).
/// - Operates without ephemeral route parameter dependencies, reading directly from App State (Requirement 8).
class PokemonDetailScreen extends StatelessWidget {
  const PokemonDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access active Pokémon from centralized App State
    final pokemon = context.watch<PokemonProvider>().selectedPokemon;

    if (pokemon == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF111827)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Pokémon Details',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'No Pokémon selected in application state.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF111827)),
          tooltip: 'Back to Pokédex',
          onPressed: () {
            context.read<PokemonProvider>().clearSelectedPokemon();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          pokemon.displayName,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Artwork Container with subtle border and neutral backdrop
                Container(
                  padding: const EdgeInsets.all(28.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      // Centered High-Resolution Sprite
                      SizedBox(
                        height: 200,
                        child: Center(
                          child: pokemon.imageUrl.isNotEmpty
                              ? Image.network(
                                  pokemon.imageUrl,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.broken_image_outlined,
                                      size: 64,
                                      color: Color(0xFF9CA3AF),
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 64,
                                  color: Color(0xFF9CA3AF),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Monospace Pokédex Number
                      Text(
                        pokemon.formattedId,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Prominent Pokémon Name
                      Text(
                        pokemon.displayName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                          letterSpacing: -0.5,
                        ),
                      ),
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

                // Metadata Card displaying Generation and Region info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        label: 'National Dex Number',
                        value: pokemon.id.toString(),
                      ),
                      const Divider(color: Color(0xFFF3F4F6), height: 20),
                      _buildInfoRow(
                        label: 'Generation',
                        value: 'Gen ${pokemon.generation}',
                      ),
                      const Divider(color: Color(0xFFF3F4F6), height: 20),
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

  /// Helper row widget for key-value pair attributes.
  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
