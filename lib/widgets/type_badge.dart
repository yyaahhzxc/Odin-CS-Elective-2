import 'package:flutter/material.dart';

/// A minimalist badge component styled directly after PokémonDB's type tags.
///
/// Features:
/// - Exact hex colors used by PokémonDB for each of the 18 elemental types.
/// - Crisp rounded pill border (radius 4px).
/// - Clean uppercase typography with white contrast text.
class TypeBadge extends StatelessWidget {
  final String typeName;

  const TypeBadge({
    super.key,
    required this.typeName,
  });

  /// Maps elemental type names to their canonical PokémonDB hex colors.
  static Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'grass':
        return const Color(0xFF77CC55);
      case 'poison':
        return const Color(0xFFAA5599);
      case 'fire':
        return const Color(0xFFFF4422);
      case 'water':
        return const Color(0xFF3399FF);
      case 'flying':
        return const Color(0xFF8899FF);
      case 'bug':
        return const Color(0xFFAABB22);
      case 'normal':
        return const Color(0xFFAAAA99);
      case 'electric':
        return const Color(0xFFFFCC33);
      case 'ground':
        return const Color(0xFFDDBB77);
      case 'fairy':
        return const Color(0xFFEE99EE);
      case 'fighting':
        return const Color(0xFFBB5544);
      case 'psychic':
        return const Color(0xFFFF5599);
      case 'rock':
        return const Color(0xFFBBAA66);
      case 'steel':
        return const Color(0xFFAAAABB);
      case 'ice':
        return const Color(0xFF66CCFF);
      case 'ghost':
        return const Color(0xFF6666BB);
      case 'dragon':
        return const Color(0xFF7766EE);
      case 'dark':
        return const Color(0xFF775544);
      default:
        return const Color(0xFF888888);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = _getTypeColor(typeName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        typeName.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
