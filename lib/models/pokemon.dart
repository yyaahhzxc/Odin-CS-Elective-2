/// Data model representing a Pokemon entity.
///
/// This class encapsulates the essential attributes needed for the Pokédex grid:
/// - [id]: The national Pokédex number.
/// - [name]: The lowercase identifier from PokéAPI (e.g., "bulbasaur").
/// - [imageUrl]: The direct URL to the high-resolution official artwork.
/// - [types]: List of elemental types associated with the Pokémon (e.g., ["grass", "poison"]).
class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;

  /// Const constructor ensures immutability and enables compile-time optimizations.
  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
  });

  /// Factory constructor to parse JSON data returned by the PokéAPI.
  ///
  /// Sample endpoint: https://pokeapi.co/api/v2/pokemon/{id}
  ///
  /// JSON Traversal Details:
  /// - `id`: Root level integer.
  /// - `name`: Root level string.
  /// - `sprites`: Navigates to `other -> official-artwork -> front_default`.
  ///   If official-artwork is unavailable, falls back to the default sprite.
  /// - `types`: Iterates over the `types` array, extracting each inner `type['name']`.
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    // 1. Extract official artwork sprite with null-safe fallbacks
    final dynamic rawSprites = json['sprites'];
    final Map<dynamic, dynamic>? sprites = rawSprites is Map ? rawSprites : null;

    final dynamic rawOther = sprites?['other'];
    final Map<dynamic, dynamic>? other = rawOther is Map ? rawOther : null;

    final dynamic rawArtwork = other?['official-artwork'];
    final Map<dynamic, dynamic>? officialArtwork = rawArtwork is Map ? rawArtwork : null;

    final dynamic rawUrl = officialArtwork?['front_default'] ?? sprites?['front_default'];
    final String extractedImageUrl = rawUrl != null ? rawUrl.toString() : '';

    // 2. Extract elemental types from the types array safely
    final dynamic rawTypes = json['types'];
    final List<dynamic> typesList = rawTypes is List ? rawTypes : [];
    final List<String> extractedTypes = typesList
        .map((entry) {
          if (entry is Map) {
            final dynamic typeObj = entry['type'];
            if (typeObj is Map && typeObj['name'] != null) {
              return typeObj['name'].toString();
            }
          }
          return '';
        })
        .where((type) => type.isNotEmpty)
        .toList();

    final dynamic idVal = json['id'];
    final int extractedId = idVal is num ? idVal.toInt() : int.tryParse(idVal?.toString() ?? '') ?? 0;

    return Pokemon(
      id: extractedId,
      name: json['name']?.toString() ?? 'Unknown',
      imageUrl: extractedImageUrl,
      types: extractedTypes,
    );
  }

  /// Formats the ID with leading zeros into standard Pokédex style: e.g., "#0001", "#0152".
  ///
  /// 4-digit zero-padding adheres to modern National Dex standards (Gen 9 exceeds 1,000).
  String get formattedId => '#${id.toString().padLeft(4, '0')}';

  /// Returns the Pokémon's name with the first letter capitalized for clean UI presentation.
  String get displayName {
    if (name.isEmpty) return '';
    return name[0].toUpperCase() + name.substring(1);
  }

  /// Determines the generation of the starter based on its National Pokédex ID.
  int get generation {
    if (id <= 151) return 1;
    if (id <= 251) return 2;
    if (id <= 386) return 3;
    if (id <= 493) return 4;
    if (id <= 649) return 5;
    if (id <= 721) return 6;
    if (id <= 809) return 7;
    if (id <= 905) return 8;
    return 9;
  }

  /// Returns the canonical region corresponding to the Pokémon's generation.
  String get regionName {
    switch (generation) {
      case 1:
        return 'Kanto';
      case 2:
        return 'Johto';
      case 3:
        return 'Hoenn';
      case 4:
        return 'Sinnoh';
      case 5:
        return 'Unova';
      case 6:
        return 'Kalos';
      case 7:
        return 'Alola';
      case 8:
        return 'Galar';
      case 9:
        return 'Paldea';
      default:
        return '';
    }
  }
}
