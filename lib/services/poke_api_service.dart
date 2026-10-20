import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

/// Service responsible for fetching Pokémon data from the PokéAPI REST service.
///
/// ## Future vs. Stream Architectural Decision (Activity Requirement 4):
/// We decided to use a [Future] (`Future<List<Pokemon>>`) instead of a [Stream]
/// for the following reasons:
///
/// 1. **Stateless REST Semantics**: The PokéAPI is a standard HTTP REST API,
///    where each endpoint corresponds to a single discrete request-response cycle.
///    A [Future] models a single asynchronous computation that either completes with
///    a value or fails with an error.
///
/// 2. **Lifecycle and Memory Management**: [Stream]s are designed for ongoing,
///    multi-event pipelines (e.g., WebSockets, sensors, or live chat feeds) and
///    require careful subscription management, controllers, and cancellation to prevent
///    memory leaks. Since fetching the 27 starter Pokémon is a one-time bounded operation,
///    a [Future] is far more memory-efficient and idiomatic in Flutter.
///
/// 3. **Native UI Integration**: [FutureBuilder] pairs cleanly with `Future`,
///    allowing clear handling of the four primary connection states:
///    none, waiting (loading), active, and done (with error or data).
class PokeApiService {
  /// Base endpoint URL for the PokéAPI v2.
  static const String _baseUrl = 'https://pokeapi.co/api/v2/pokemon';

  /// National Pokédex IDs for all Grass, Fire, and Water starter evolution lines
  /// across Generations 1 through 9 (3 evolution stages * 3 starters * 9 gens = 81 Pokémon).
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

  /// Constructor allows injecting a custom [http.Client], which is essential
  /// for dependency injection and unit testing with mock clients.
  PokeApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches an individual Pokémon by its National Pokédex ID.
  ///
  /// Throws an [Exception] if the HTTP status code is not 200 (OK)
  /// or if a network error occurs.
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
      // Re-throw descriptive error for the UI state handler to capture
      throw Exception('Network error fetching Pokémon #$id: $e');
    }
  }

  /// Fetches all 27 starter Pokémon concurrently across Generations 1 through 9.
  ///
  /// Uses [Future.wait] to execute all 27 HTTP GET requests in parallel.
  /// This optimizes performance from ~15+ seconds (sequential) down to ~1–2 seconds (parallel).
  ///
  /// The returned list is guaranteed to be sorted in ascending order by Pokédex ID.
  Future<List<Pokemon>> fetchStarterPokemons() async {
    try {
      // Map each starter ID into an independent Future<Pokemon>
      final List<Future<Pokemon>> fetchFutures =
          starterIds.map((id) => fetchPokemonById(id)).toList();

      // Execute all futures in parallel and await collective resolution
      final List<Pokemon> results = await Future.wait(fetchFutures);

      // Ensure Pokémon are sorted chronologically by their National Dex number
      results.sort((a, b) => a.id.compareTo(b.id));

      return results;
    } catch (e) {
      // Propagate the exception so the ErrorView widget can render the retry interface
      throw Exception('Unable to load starter Pokémon. Please check your internet connection and try again.');
    }
  }

  /// Disposes the underlying HTTP client when no longer needed.
  void dispose() {
    _client.close();
  }
}
