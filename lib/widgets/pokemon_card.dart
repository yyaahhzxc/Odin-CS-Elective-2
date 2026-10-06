import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../screens/pokemon_detail_screen.dart';
import 'type_badge.dart';

/// A minimalist, borderless Pokémon component styled in the spirit of PokémonDB.
///
/// Features:
/// - Borderless, box-free presentation directly on the clean canvas.
/// - Centered high-resolution official artwork with loading & error fallbacks.
/// - Formatted National Pokédex ID (#0001) in muted monospace typography.
/// - Bold, legible name typography.
/// - Compact PokémonDB-style type pills.
/// - Interactive tap handling: dispatches selection to [PokemonProvider] and navigates to [PokemonDetailScreen].
class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCard({
    super.key,
    required this.pokemon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.read<PokemonProvider>().selectPokemon(pokemon);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const PokemonDetailScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          // 1. Centered High-Resolution Official Artwork Sprite
          SizedBox(
            height: 85,
            child: Center(
              child: pokemon.imageUrl.isNotEmpty
                  ? Image.network(
                      pokemon.imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9CA3AF)),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image_outlined,
                          size: 36,
                          color: Color(0xFF9CA3AF),
                        );
                      },
                    )
                  : const Icon(
                      Icons.image_not_supported_outlined,
                      size: 36,
                      color: Color(0xFF9CA3AF),
                    ),
            ),
          ),
          const SizedBox(height: 8),

          // 2. National Pokédex ID in muted monospace typography
          Text(
            pokemon.formattedId,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 2),

          // 3. Pokémon Display Name
          Text(
            pokemon.displayName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          // 4. Compact Elemental Type Badges
          Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.center,
            children: pokemon.types
                .map((type) => TypeBadge(typeName: type))
                .toList(),
          ),
        ],
      ),
    ),
  ),
);
  }
}
