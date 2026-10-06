import 'package:flutter/foundation.dart';
import '../models/pokemon.dart';
import '../services/poke_api_service.dart';

/// Enumeration representing the discrete states of the Pokédex data lifecycle.
enum PokemonStateStatus {
  initial,
  loading,
  success,
  error,
}

/// Provider managing application-wide state for Pokémon data.
///
/// Encapsulates:
/// - Asynchronous state machine (initial, loading, success, error)
/// - List of fetched Pokémon entities
/// - Active Pokémon selection for the detail screen (App State)
/// - Network error messaging
///
/// Adheres strictly to requirements:
/// - States managed using Provider (Requirement 4)
/// - API call encapsulated as a method in the Provider (Requirement 6)
/// - All UI values derived from App State rather than ephemeral state (Requirement 8)
/// - Detail page contents provided via centralized state (Requirement 9)
class PokemonProvider extends ChangeNotifier {
  final PokeApiService _apiService;

  List<Pokemon> _pokemons = [];
  Pokemon? _selectedPokemon;
  PokemonStateStatus _status = PokemonStateStatus.initial;
  String _errorMessage = '';

  /// Constructor allows dependency injection of [PokeApiService] for testing.
  PokemonProvider({PokeApiService? apiService})
      : _apiService = apiService ?? PokeApiService();

  /// Unmodifiable view of the current Pokémon list.
  List<Pokemon> get pokemons => List.unmodifiable(_pokemons);

  /// Currently selected Pokémon entity stored in App State.
  Pokemon? get selectedPokemon => _selectedPokemon;

  /// Current lifecycle state status.
  PokemonStateStatus get status => _status;

  /// Human-readable error message populated during error state.
  String get errorMessage => _errorMessage;

  /// Helper boolean getter indicating an in-flight network request.
  bool get isLoading => _status == PokemonStateStatus.loading;

  /// Helper boolean getter indicating an error state.
  bool get hasError => _status == PokemonStateStatus.error;

  /// Helper boolean getter indicating successful data retrieval.
  bool get isSuccess => _status == PokemonStateStatus.success;

  /// Fetches the Pokémon dataset and manages state transitions.
  ///
  /// Can be forced to bypass cache when [forceRefresh] is set to true.
  Future<void> fetchPokemons({bool forceRefresh = false}) async {
    if (_status == PokemonStateStatus.loading) return;
    if (_status == PokemonStateStatus.success && _pokemons.isNotEmpty && !forceRefresh) {
      return;
    }

    _status = PokemonStateStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await _apiService.fetchStarterPokemons();
      _pokemons = results;
      _status = PokemonStateStatus.success;
      _errorMessage = '';
    } catch (e) {
      _status = PokemonStateStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  /// Sets the active Pokémon in App State for detail view rendering.
  void selectPokemon(Pokemon pokemon) {
    _selectedPokemon = pokemon;
    notifyListeners();
  }

  /// Clears the active Pokémon from App State upon navigating back.
  void clearSelectedPokemon() {
    _selectedPokemon = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
