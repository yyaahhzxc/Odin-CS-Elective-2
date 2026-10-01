import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import 'type_badge.dart';

/// A clean, minimalist card widget styled in the spirit of PokémonDB.
///
/// Features:
/// - Crisp white card with a subtle 1px border and soft rounded corners.
/// - Formatted National Pokédex ID (#0001) in muted gray.
/// - Centered official artwork with loading & error fallback states.
/// - Bold, legible name typography.
/// - Compact PokémonDB-style type pills.
/// - Adheres strictly to the requirement: no navigation to a detail page.
class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCard({
    super.key,
    required this.pokemon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE5E7EB), // Neutral border
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000), // Subtle shadow
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Row: Generation indicator and National Pokédex ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gen ${pokemon.generation}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                Text(
                  pokemon.formattedId,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Centered High-Resolution Official Artwork Sprite
            Expanded(
              child: Center(
                child: pokemon.imageUrl.isNotEmpty
                    ? Image.network(
                        pokemon.imageUrl,
                        fit: BoxFit.contain,
                        // Progressive loading placeholder
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9CA3AF)),
                              ),
                            ),
                          );
                        },
                        // Fallback in case of network or image loading failure
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image_outlined,
                            size: 40,
                            color: Color(0xFF9CA3AF),
                          );
                        },
                      )
                    : const Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: Color(0xFF9CA3AF),
                      ),
              ),
            ),
            const SizedBox(height: 8),

            // Pokémon Display Name
            Text(
              pokemon.displayName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            // Elemental Type Badges (Row of compact badges)
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
    );
  }
}
