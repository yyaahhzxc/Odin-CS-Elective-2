import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokeApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2/pokemon';

  static const List<int> starterIds = [
    // Generation 1 (Kanto)
    1, 2, 3, 4, 5, 6, 7, 8, 9,
    // Generation 2 (Johto)
    152, 153, 154, 155, 156, 157, 158, 159, 160,
    // Generation 3 (Hoenn)
    252, 253, 254, 255, 256, 257, 258, 259, 260,
    // Generation 4 (Sinnoh)
    387, 388, 389, 390, 391, 392, 393, 394, 395,
    // Generation 5 (Unova)
    495, 496, 497, 498, 499, 500, 501, 502, 503,
    // Generation 6 (Kalos)
    650, 651, 652, 653, 654, 655, 656, 657, 658,
    // Generation 7 (Alola)
    722, 723, 724, 725, 726, 727, 728, 729, 730,
    // Generation 8 (Galar)
    810, 811, 812, 813, 814, 815, 816, 817, 818,
    // Generation 9 (Paldea)
    906, 907, 908, 909, 910, 911, 912, 913, 914,
  ];

  final http.Client _client;

  PokeApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<Pokemon> fetchPokemonById(int id) async {
    final uri = Uri.parse('$_baseUrl/$id');

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        return Pokemon.fromJson(data);
      } else {
        throw Exception('Failed to load Pokémon #$id (HTTP Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error fetching Pokémon #$id: $e');
    }
  }

  Future<List<Pokemon>> fetchStarterPokemons() async {
    try {
      final List<Future<Pokemon>> fetchFutures =
          starterIds.map((id) => fetchPokemonById(id)).toList();

      final List<Pokemon> results = await Future.wait(fetchFutures);
      results.sort((a, b) => a.id.compareTo(b.id));

      return results;
    } catch (e) {
      throw Exception('Unable to load starter Pokémon. Please check your internet connection and try again.');
    }
  }

  void dispose() {
    _client.close();
  }
}
